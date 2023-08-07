import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Musica extends StatefulWidget {
  @override
  MusicaState createState() => MusicaState();
}

class MusicaState extends State<Musica> {
  late AudioPlayer _audioPlayer;
  String _filePath = '';
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _uploadFile(String filePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final selectedFile = result.files.single;

      // Subir archivo a Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child(selectedFile.name);
      UploadTask uploadTask = storageReference.putData(selectedFile.bytes!);
      await uploadTask.whenComplete(() => null);

      setState(() {
        _filePath = selectedFile.name;
        _isPlaying = false;
      });
    }
  }

  void _playPauseMusic() {
    if (_filePath.isNotEmpty) {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play(_filePath as Source);
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_filePath.isNotEmpty)
              Text(
                'Selected Music: $_filePath',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 16),
            IconButton(
              onPressed: _playPauseMusic,
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 48,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _uploadFile(_filePath),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

