import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key});

  @override
  VideosState createState() => VideosState();
}

class VideosState extends State<Videos> {
  List<String> videoUrls = [];
  List<String> videoMiniaturas = [];
  final baseDatos = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    cargarVideos();
  }

  Future<void> cargarVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final firebase_storage.ListResult resultado =
        await storage.ref().child('videos/${user?.uid}').listAll();
    final urls = await Future.wait(
      resultado.items.map((ref) => ref.getDownloadURL()),
    );
    setState(() {
      videoUrls = urls;
      cargarMiniaturas();
    });
  }

  Future<void> cargarMiniaturas() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final thumbnails = await Future.wait(
      videoUrls.map((url) async {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 120,
          quality: 25,
        );
        return thumbnailPath;
      }),
    );
    setState(() {
      videoMiniaturas = thumbnails.where((thumbnail) => thumbnail != null).map((thumbnail) => thumbnail!).toList();
    });
  }

  Future<void> subirVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    final imagePicker = ImagePicker();
    final videoSeleccionado = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (videoSeleccionado != null) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final nombreVideo = DateTime.now().microsecondsSinceEpoch.toString();
      final ref = storage.ref().child('videos/${user?.uid}/$nombreVideo');
      final i = ref.putFile(
        File(videoSeleccionado.path),
        firebase_storage.SettableMetadata(contentType: 'video/*'),
      );
      try {
        await i.whenComplete(() async {
          final downloadUrl = await ref.getDownloadURL();
          setState(() {
            videoUrls.add(downloadUrl);
          });
        });
      } catch (error) {}
    }
  }

  void verVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayer(videoUrl: videoUrl),
      ),
    );
  }

  void mensajeEliminacion(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar video'),
          content: const Text('¿Estás seguro de que quieres eliminar el video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await borrarVideo(videoUrl);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video eliminado')),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> borrarVideo(String videoUrl) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage.refFromURL(videoUrl);
    await ref.delete();

    final index = videoUrls.indexOf(videoUrl);
    if (index != -1) {
      setState(() {
        videoUrls.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: videoUrls.length,
          itemBuilder: (context, index) {
            final videoUrl = videoUrls[index];
            final videoThumbnail = videoMiniaturas.length > index ? videoMiniaturas[index] : '';
            return GestureDetector(
              onTap: () => verVideo(context, videoUrl),
              onLongPress: () => mensajeEliminacion(context, videoUrl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  videoThumbnail.isNotEmpty
                      ? Image.file(
                          File(videoThumbnail),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.video_library, size: 48),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: subirVideo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoPlayer({Key? key, required this.videoUrl});

  @override
  VideoPlayerState createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  late VideoPlayerController controller;
  bool controles = true;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void mostrarControles() {
    setState(() {
      controles = !controles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
      showControls: controles,
    );

    return Scaffold(
      body: GestureDetector(
        onTap: mostrarControles,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Chewie(
                controller: chewieController,
              ),
            ),
            VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              padding: const EdgeInsets.all(8.0),
            ),
          ],
        ),
      ),
    );
  }
}













