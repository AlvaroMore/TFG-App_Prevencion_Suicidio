import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class Videos extends StatefulWidget {
  @override
  _VideoFolderPageState createState() => _VideoFolderPageState();
}

class _VideoFolderPageState extends State<Videos> {
  List<String> videoUrls = [];
  List<Uint8List> videoThumbnails = [];

  @override
  void initState() {
    super.initState();
    loadVideosFromCloudStorage();
  }

  Future<void> loadVideosFromCloudStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final firebase_storage.ListResult result =
        await storage.ref().child('videos/${user?.uid}').listAll();

    final urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()),
    );

    final thumbnails = await Future.wait<Uint8List>(
      result.items.map((ref) => _generateThumbnail(ref)),
    );

    print('Video URLs: $urls');
    print('Thumbnails: $thumbnails');

    setState(() {
      videoUrls = urls;
      videoThumbnails = thumbnails;
    });
  }

  Future<Uint8List> _generateThumbnail(firebase_storage.Reference ref) async {
    final videoUrl = await ref.getDownloadURL();
    final thumbnailPath = 'thumbnails/${ref.name}.jpg';

    final ffmpeg = FlutterFFmpeg();
    final outputPath = firebase_storage.FirebaseStorage.instance.ref().fullPath + '/' + thumbnailPath;
    final arguments = '-i $videoUrl -ss 00:00:01 -vframes 1 -vf "scale=320:-1" $outputPath';
    final result = await ffmpeg.execute(arguments);

    if (result == 0) {
      final file = File(outputPath);
      final bytes = await file.readAsBytes();
      await file.delete();
      return bytes;
    } else {
      print('Error generating thumbnail for video: $videoUrl');
      return Uint8List(0);
    }
  }


  Future<void> uploadVideoToCloudStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    final imagePicker = ImagePicker();
    final pickedVideo = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final videoName = DateTime.now().microsecondsSinceEpoch.toString();
      final ref = storage.ref().child('videos/${user?.uid}/$videoName');
      final uploadTask = ref.putFile(
        File(pickedVideo.path),
        firebase_storage.SettableMetadata(contentType: 'video/*'),
      );

      try {
        await uploadTask.whenComplete(() async {
          final downloadUrl = await ref.getDownloadURL();
          final thumbnail = await _generateThumbnail(ref);
          setState(() {
            videoUrls.add(downloadUrl);
            videoThumbnails.add(thumbnail);
          });
        });
      } catch (error) {
        print('Error uploading video: $error');
      }
    }
  }

  void viewVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          final videoUrl = videoUrls[index];
          final thumbnailBytes = videoThumbnails[index];
          return GestureDetector(
            onTap: () => viewVideo(context, videoUrl),
            child: Hero(
              tag: videoUrl,
              child: Image.memory(
                thumbnailBytes,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadVideoToCloudStorage,
        child: Icon(Icons.add),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({required this.videoUrl});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: _showControls,
    );

    return Scaffold(
      body: GestureDetector(
        onTap: toggleControlsVisibility,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Chewie(
                controller: chewieController,
              ),
            ),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: EdgeInsets.all(8.0),
            ),
          ],
        ),
      ),
    );
  }
}










