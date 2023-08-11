import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';


class Videos extends StatefulWidget {
  const Videos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  VideosState createState() => VideosState();
}

class VideosState extends State<Videos> {
  List<String> videoUrls = [];
  List<String> videoTitulos = [];
  final baseDatos = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    cargarVideos();
    cargarTitulos();
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
    });
  }

  Future<void> cargarTitulos() async {
    final user = FirebaseAuth.instance.currentUser;
    // ignore: deprecated_member_use
    final videosRef = baseDatos.reference().child('videos/${user?.uid}');
    final dataSnapshot = await videosRef.once();

    final titulos = <String>[];
    if (dataSnapshot.snapshot.value != null) {
      final videosData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      videosData.forEach((key, value) {
        final videoTitulo = value['titulo'] as String;
        titulos.add(videoTitulo);
      });
    }

    setState(() {
      videoTitulos = titulos;
    });
  }

  Future<void> subirVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    final imagePicker = ImagePicker();
    final pickedVideo = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final nombreVideo = DateTime.now().microsecondsSinceEpoch.toString();
      final ref = storage.ref().child('videos/${user?.uid}/$nombreVideo');
      final i = ref.putFile(
        File(pickedVideo.path),
        firebase_storage.SettableMetadata(contentType: 'video/*'),
      );

      try {
        final tituloController = TextEditingController();
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Escribe el titulo del video'),
              content: TextField(
                controller: tituloController,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    Navigator.of(context).pop(tituloController.text);
                  },
                ),
              ],
            );
          },
        );

        if (tituloController.text.isNotEmpty) {
          await i.whenComplete(() async {
            final downloadUrl = await ref.getDownloadURL();
            // ignore: deprecated_member_use
            final videoId = baseDatos.reference().child('videos/${user?.uid}').push().key;
            final videoData = {
              'url': downloadUrl,
              'title': tituloController.text,
            };
            // ignore: deprecated_member_use
            await baseDatos.reference().child('videos/${user?.uid}/$videoId').set(videoData);

            setState(() {
              videoUrls.add(downloadUrl);
              videoTitulos.add(tituloController.text);
            });
          });
        }
      // ignore: empty_catches
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

  void mensajeEliminacion(BuildContext context, String videoUrl, String videoTitulo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar video'),
          content: Text('¿Estás seguro de que quieres eliminar el video "$videoTitulo"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await borrarVideo(videoUrl, videoTitulo);
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

  Future<void> borrarVideo(String videoUrl, String videoTitulo) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage.refFromURL(videoUrl);

    await ref.delete();

    final index = videoUrls.indexOf(videoUrl);
    if (index != -1) {
      setState(() {
        videoUrls.removeAt(index);
        videoTitulos.removeAt(index);
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
            final videoTitulo = videoTitulos.length > index ? videoTitulos[index] : '';
            return GestureDetector(
              onTap: () => verVideo(context, videoUrl),
              onLongPress: () => mensajeEliminacion(context, videoUrl, videoTitulo),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library, size: 48),
                  const SizedBox(height: 8),
                  Text(videoTitulo),
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

  const VideoPlayer({super.key, required this.videoUrl});

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












