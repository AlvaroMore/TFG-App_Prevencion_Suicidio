import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:appbu_s/modelos/reproductor.dart';

class Musica extends StatefulWidget {
  const Musica({Key? key});

  @override
  MusicaState createState() => MusicaState();
}

class MusicaState extends State<Musica> {
  String ruta = '';
  bool reproduciendo = false;
  Map<String, String> cancionesInfoMap = {};
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    cargarCancionesYMostrar();
  }

Future<void> subirMusica() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3'],
  );

  if (result != null) {
    final archivo = File(result.files.single.path!);
    if (archivo.existsSync()) {
      final bytes = await archivo.readAsBytes();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference baseDatos = FirebaseStorage.instance
            .ref()
            .child('musica/${user.uid}/${archivo.path.split('/').last}');
        UploadTask uploadTask = baseDatos.putData(bytes);
        await uploadTask.whenComplete(() async {
          final url = await baseDatos.getDownloadURL();
          setState(() {
            ruta = archivo.path;
            reproduciendo = false;
            cancionesInfoMap[baseDatos.fullPath] = url; // Agregar la nueva canción al mapa
          });
        });
      }
    }
  }
}


  Future<List<String>> cargarCanciones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final List<String> canciones = [];
        Reference directorioUsuario = FirebaseStorage.instance.ref().child('musica/${user.uid}');
        final ListResult result = await directorioUsuario.list();
        for (final Reference ref in result.items) {
          canciones.add(ref.fullPath);
        }
        return canciones;
      } catch (e) {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<void> cargarCancionesYMostrar() async {
    final canciones = await cargarCanciones();
    if (canciones.isNotEmpty) {
      final Map<String, String> infoMap = {};
      for (final cancion in canciones) {
        final ref = FirebaseStorage.instance.ref().child(cancion);
        final url = await ref.getDownloadURL();
        infoMap[cancion] = url;
      }
      setState(() {
        cancionesInfoMap = infoMap;
      });
    }
  }

  void reproducirCancion(String url) async {
    await player.setUrl(url);
    player.play();
  }

  Future<void> borrarMusica(String rutaArchivo) async {
    Reference baseDatos = FirebaseStorage.instance.ref().child(rutaArchivo);
    await baseDatos.delete();
    setState(() {
      rutaArchivo = '';
    });
    await cargarCancionesYMostrar();
  }

  Future<void> mensajeEliminacion(BuildContext context, String cancion) async {
    final resultado = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar canción'),
          content: const Text('¿Estás seguro de que quieres eliminar esta canción?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await borrarMusica(cancion);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cancion eliminada')),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Música'),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (cancionesInfoMap.isNotEmpty)
            Column(
              children: cancionesInfoMap.entries.map((entry) {
                final cancion = entry.key;
                final url = entry.value;
                return GestureDetector(
                  onLongPress: () {
                    mensajeEliminacion(context, cancion);
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReproductorMusica(
                            audioUrl: url,
                            nombreCancion: cancion.split('/').last,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      cancion.split('/').last,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
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






