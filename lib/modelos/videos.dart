import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';


class Videos extends StatefulWidget {
  @override
  _VideoFolderPageState createState() => _VideoFolderPageState();
}

class _VideoFolderPageState extends State<Videos> {
  List<String> videoUrls = [];
  List<String> videoTitles = [];
  final baseDatos = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    loadVideosFromCloudStorage();
    loadVideoTitlesFromDatabase();
  }

  Future<void> loadVideosFromCloudStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final firebase_storage.ListResult result =
        await storage.ref().child('videos/${user?.uid}').listAll();

    final urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()),
    );

    setState(() {
      videoUrls = urls;
    });
  }

  Future<void> loadVideoTitlesFromDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    final videosRef = baseDatos.reference().child('videos/${user?.uid}');
    final dataSnapshot = await videosRef.once();

    final titles = <String>[];
    if (dataSnapshot.snapshot.value != null) {
      final videosData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      videosData.forEach((key, value) {
        final videoTitle = value['title'] as String;
        titles.add(videoTitle);
      });
    }

    setState(() {
      videoTitles = titles;
    });
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
        final titleController = TextEditingController();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter Video Title'),
              content: TextField(
                controller: titleController,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    Navigator.of(context).pop(titleController.text);
                  },
                ),
              ],
            );
          },
        );

        if (titleController.text.isNotEmpty) {
          await uploadTask.whenComplete(() async {
            final downloadUrl = await ref.getDownloadURL();
            final videoId = baseDatos.reference().child('videos/${user?.uid}').push().key;
            final videoData = {
              'url': downloadUrl,
              'title': titleController.text,
            };
            await baseDatos.reference().child('videos/${user?.uid}/$videoId').set(videoData);

            setState(() {
              videoUrls.add(downloadUrl);
              videoTitles.add(titleController.text);
            });
          });
        }
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
      body: Padding(
        padding: EdgeInsets.only(top: 16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: videoUrls.length,
          itemBuilder: (context, index) {
            final videoUrl = videoUrls[index];
            final videoTitle = videoTitles.length > index ? videoTitles[index] : '';
            return GestureDetector(
              onTap: () => viewVideo(context, videoUrl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 48),
                  SizedBox(height: 8),
                  Text(videoTitle),
                ],
              ),
            );
          },
        ),
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












