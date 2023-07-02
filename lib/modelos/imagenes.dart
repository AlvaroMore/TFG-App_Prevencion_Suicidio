import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class Imagenes extends StatefulWidget {
  @override
  _ImageFolderPageState createState() => _ImageFolderPageState();
}

class _ImageFolderPageState extends State<Imagenes> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImagesFromCloudStorage();
  }

  Future<void> loadImagesFromCloudStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = firebase_storage.FirebaseStorage.instance;
    final firebase_storage.ListResult result =
        await storage.ref().child('images/${user?.uid}').listAll();

    final urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()),
    );

    setState(() {
      imageUrls = urls;
    });
  }

  Future<void> uploadImageToCloudStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final ref = storage.ref().child('images/${user?.uid}/${pickedImage.name}');
      final uploadTask = ref.putFile(
        File(pickedImage.path),
        firebase_storage.SettableMetadata(contentType: 'image/*'),
      );

      await uploadTask.whenComplete(() {});

      final imageUrl = await ref.getDownloadURL();

      setState(() {
        imageUrls.add(imageUrl);
      });
    }
  }

  void viewImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageFullscreenPage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagenes'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () => viewImage(context, imageUrl),
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadImageToCloudStorage,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ImageFullscreenPage extends StatelessWidget {
  final String imageUrl;

  const ImageFullscreenPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
