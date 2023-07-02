import 'dart:async';
import 'package:demo/modelos/imagenes.dart';
import 'package:demo/modelos/videos.dart';
import 'package:demo/paginas/home_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class media extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multimedia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FolderButton(
              title: 'IMAGENES',
              image: AssetImage('assets/imagenes.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Imagenes(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            FolderButton(
              title: 'VIDEOS',
              image: AssetImage('assets/imagenes.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Videos(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FolderButton extends StatelessWidget {
  final String title;
  final ImageProvider<Object> image;
  final VoidCallback onPressed;
  final double buttonWidth; // Nuevo parámetro para el ancho del botón
  final double buttonHeight; // Nuevo parámetro para el alto del botón

  const FolderButton({
    required this.title,
    required this.image,
    required this.onPressed,
    this.buttonWidth = 330, // Valor predeterminado del ancho del botón
    this.buttonHeight = 300, // Valor predeterminado del alto del botón
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Colors.black54,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}







