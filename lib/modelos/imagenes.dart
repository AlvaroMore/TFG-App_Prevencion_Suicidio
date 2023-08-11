import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class Imagenes extends StatefulWidget {
  const Imagenes({super.key});

  @override
  ImagenesState createState() => ImagenesState();
}

class ImagenesState extends State<Imagenes> {
  final List<String> imagenes = [];

  @override
  void initState() {
    super.initState();
    cargarImagenes();
  }

  Future<void> cargarImagenes() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final firebase_storage.ListResult result =
        await storage.ref().child('images/${user?.uid}').listAll();

    final urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()),
    );

    setState(() {
      imagenes.addAll(urls);
    });
  }

  Future<void> borrarImagen(String imagen) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage.refFromURL(imagen);

    await ref.delete();

    setState(() {
      imagenes.remove(imagen);
    });
  }

  void mensajeEliminacion(BuildContext context, String imagen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar imagen'),
          content: const Text('¿Estás seguro de que quieres eliminar esta imagen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await borrarImagen(imagen);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Imagen eliminada')),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> subirImagen() async {
    final user = FirebaseAuth.instance.currentUser;
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final ref = storage.ref().child('images/${user?.uid}/${pickedImage.name}');
      final i = ref.putFile(
        File(pickedImage.path),
        firebase_storage.SettableMetadata(contentType: 'image/*'),
      );

      await i.whenComplete(() {});

      final imagen = await ref.getDownloadURL();

      setState(() {
        imagenes.add(imagen);
      });
    }
  }

  void viewImage(BuildContext context, String imagen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagenPage(imagen: imagen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagenes'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: imagenes.length,
        itemBuilder: (context, index) {
          final imagen = imagenes[index];
          return GestureDetector(
            onTap: () => viewImage(context, imagen),
            onLongPress: () => mensajeEliminacion(context, imagen),
            child: Hero(
              tag: imagen,
              child: Image.network(
                imagen,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: subirImagen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ImagenPage extends StatelessWidget {
  final String imagen;

  const ImagenPage({super.key, required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imagen,
            child: Image.network(
              imagen,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
