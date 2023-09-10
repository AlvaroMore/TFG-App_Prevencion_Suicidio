import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';

class Video {
  final String videoUrl;
  final String videoNombre;
  Video({required this.videoUrl, required this.videoNombre});
}

class Videos extends StatefulWidget {
  const Videos({Key? key});

  @override
  VideosState createState() => VideosState();
}

class VideosState extends State<Videos> {
  List<Video> videoUrls = [];
  final baseDatos = FirebaseDatabase.instance;
  List<String> playedVideos = [];
  bool isPlayingVideo = false;
  Image videoMiniatura = Image.asset('recursos/videos.png');

  @override
  void initState() {
    super.initState();
    cargarVideos();
    cargarVideoMiniatura();
  }

  Future<void> cargarVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final List<firebase_storage.Reference> userItems =
        (await storage.ref().child('videos/${user?.uid}').listAll()).items;
    final List<Video> videosCargados = [];

    for (final item in userItems) {
      final itemName = item.name;
      final itemUrl = await item.getDownloadURL();
      final videoNombre = itemName.replaceAll('.mp4', '');
      final video = Video(
        videoUrl: itemUrl,
        videoNombre: videoNombre,
      );
      videosCargados.add(video);
    }
    setState(() {
      videoUrls = videosCargados;
    });
  }

  void cargarVideoMiniatura() {
    setState(() {
      videoMiniatura = Image.asset('recursos/videos.png');
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
      final carpeta = 'videos/${user?.uid}';
      String? videoNombre;

      // ignore: use_build_context_synchronously
      videoNombre = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nombre del video'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Nombre del video'),
              onChanged: (value) {
                videoNombre = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (videoNombre != null && videoNombre!.isNotEmpty) {
                    final archivoNombre = '$videoNombre.mp4';
                    final refVideo = storage.ref().child('$carpeta/$archivoNombre');
                    final archivoVideo = File(videoSeleccionado.path);
                    final uploadVideoTask = refVideo.putFile(
                      archivoVideo,
                      firebase_storage.SettableMetadata(contentType: 'video/*'),
                    );
                    try {
                      await uploadVideoTask.whenComplete(() async {
                        final conseguirUrl = await refVideo.getDownloadURL();
                        final nombreNoNulo = videoNombre!;
                        final video = Video(
                          videoUrl: conseguirUrl,
                          videoNombre: nombreNoNulo,
                        );
                        setState(() {
                          videoUrls.add(video);
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      });
                    // ignore: empty_catches
                    } catch (error) {}
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    }
  }

  void verVideo(BuildContext context, String videoUrl, String videoNombre) {
    if (!playedVideos.contains(videoUrl) && !isPlayingVideo) {
      isPlayingVideo = true;
      playedVideos.add(videoUrl);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayer(videoUrl: videoUrl, videoNombre: videoNombre),
        ),
      ).then((_) {
        isPlayingVideo = false;
        Navigator.pop(context);
      });
    }
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
    final index = videoUrls.indexWhere((item) => item.videoUrl == videoUrl);

    if (index != -1) {
      final videoItem = videoUrls[index];
      final refVideo = storage.refFromURL(videoItem.videoUrl);
      await refVideo.delete();
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
        padding: const EdgeInsets.all(9.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 10,
          ),
          itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          final videoItem = videoUrls[index];

          return GestureDetector(
            onTap: () => verVideo(context, videoItem.videoUrl, videoItem.videoNombre),
            onLongPress: () => mensajeEliminacion(context, videoItem.videoUrl),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                videoMiniatura,
                Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    videoItem.videoNombre,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
  final String videoNombre;

  const VideoPlayer({Key? key, required this.videoUrl, required this.videoNombre});

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
        controller.addListener(() {
          if (controller.value.position >= controller.value.duration) {
            controller.pause();
          }
        });
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
      looping: false,
      showControls: controles,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoNombre),
      ),
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

