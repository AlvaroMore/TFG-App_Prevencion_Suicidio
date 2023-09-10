import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';

class ReproductorMusica extends StatefulWidget {
  final String audioUrl;
  final String nombreCancion;

  const ReproductorMusica({
    super.key,
    required this.audioUrl,
    required this.nombreCancion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReproductorMusicaState createState() => _ReproductorMusicaState();
}

class PositionData{
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}


class _ReproductorMusicaState extends State<ReproductorMusica> {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _audioPlayer.positionStream,
      _audioPlayer.bufferedPositionStream,
      _audioPlayer.durationStream,
      (position, bufferedPosition, duration) => PositionData(
        position, 
        bufferedPosition, 
        duration ?? Duration.zero,
      ),
    );

  @override
  void initState(){
    super.initState();
    _audioPlayer = AudioPlayer()..setUrl(widget.audioUrl);

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text('Reproductor'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF144771), Color(0xFF071A2C)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('recursos/musica.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 200),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.nombreCancion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  barHeight: 8,
                  baseBarColor: Colors.grey[600],
                  bufferedBarColor: Colors.grey,
                  progressBarColor: Colors.red,
                  thumbColor: Colors.red,
                  timeLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                );
              },
            ),
            const SizedBox(height: 30),
            Controles(audioPlayer: _audioPlayer)
          ],
        ),
      ),
    );
  }
}


class Controles extends StatelessWidget{
  const Controles({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot){
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (playing ?? false) {
          return IconButton(
            onPressed: audioPlayer.pause,
            iconSize: 80,
            color: Colors.white,
            icon: const Icon(Icons.pause_rounded),
          );
        }
        return IconButton(
          onPressed: audioPlayer.play,
          iconSize: 80,
          color: Colors.white,
          icon: const Icon(Icons.play_arrow_rounded),
        );
      },
    );
  }
}
