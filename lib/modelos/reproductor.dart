import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ReproductorMusica extends StatefulWidget {
  final String audioUrl;
  final String nombreCancion;

  const ReproductorMusica({super.key, 
    required this.audioUrl,
    required this.nombreCancion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReproductorMusicaState createState() => _ReproductorMusicaState();
}

class _ReproductorMusicaState extends State<ReproductorMusica> {
  final AudioPlayer player = AudioPlayer();
  bool reproduciendo = false;
  double valorBarra = 0.0;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    try {
      await player.setUrl(widget.audioUrl);
      player.playbackEventStream.listen((event) {
      });
    } catch (e) {}
  }

  Future<void> togglePlayback() async {
    if (reproduciendo) {
      await player.pause();
    } else {
      await player.play();
    }
    setState(() {
      reproduciendo = !reproduciendo;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreCancion),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.nombreCancion,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(reproduciendo ? Icons.pause : Icons.play_arrow),
              iconSize: 64,
              onPressed: togglePlayback,
            ),
            const SizedBox(height: 20),
            Slider(
              value: valorBarra,
              min: 0.0,
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

