import 'package:appbu_s/modelos/imagenes.dart';
import 'package:appbu_s/modelos/videos.dart';
import 'package:flutter/material.dart';
import 'package:appbu_s/modelos/musica.dart';
import 'package:appbu_s/modelos/frases.dart';

class media extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multimedia'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FolderButton(
                    title: 'IMAGENES',
                    image: AssetImage('recursos/imagenes.png'),
                    width: 250,
                    height: 280,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Imagenes(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FolderButton(
                    title: 'VIDEOS',
                    image: AssetImage('recursos/videos.png'),
                    width: 250,
                    height: 280,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Videos(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FolderButton(
                    title: 'MUSICA',
                    image: AssetImage('recursos/musica.png'),
                    width: 250,
                    height: 280,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Musica(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FolderButton(
                    title: 'FRASES',
                    image: AssetImage('recursos/frases.png'),
                    width: 250,
                    height: 280,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Frases(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FolderButton extends StatelessWidget {
  final String title;
  final ImageProvider<Object> image;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const FolderButton({
    required this.title,
    required this.image,
    required this.onPressed,
    this.width = 150, // Default width
    this.height = 150, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Ink(
        width: width,
        height: height,
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
    );
  }
}









