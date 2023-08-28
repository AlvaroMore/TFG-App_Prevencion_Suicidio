import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Musica extends StatefulWidget {
  const Musica({super.key});

  @override
  MusicaState createState() => MusicaState();
}

class MusicaState extends State<Musica> {
  late AudioPlayer audioPlayer;
  String filePath = '';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  Future<void> subirMusica() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final archivo = result.files.single;

      Reference baseDatos = FirebaseStorage.instance.ref().child(archivo.name);
      UploadTask uploadTask = baseDatos.putData(archivo.bytes!);
      await uploadTask.whenComplete(() => null);

      setState(() {
        filePath = archivo.name;
        isPlaying = false;
      });
    }
  }

  Future<void> borrarMusica(String filePath) async {
    Reference baseDatos= FirebaseStorage.instance.ref().child(filePath);
    await baseDatos.delete();

    setState(() {
      if (isPlaying) {
        audioPlayer.stop();
        isPlaying = false;
      }
      filePath = '';
    });
  }

  void reproducirMusica() {
    if (filePath.isNotEmpty) {
      if (isPlaying) {
        audioPlayer.pause();
      } else {
        audioPlayer.play(filePath as Source);
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  Future<void> mensajeEliminacion(BuildContext context) async {
    if (filePath.isNotEmpty) {
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar canción'),
            content: const Text('¿Estás seguro de que quieres eliminar esta canción?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        borrarMusica(filePath);
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musica'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filePath.isNotEmpty)
              Text(
                'Musica seleccionada: $filePath',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPress: () {
                mensajeEliminacion(context);
              },
              child: IconButton(
                onPressed: reproducirMusica,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: subirMusica,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}



