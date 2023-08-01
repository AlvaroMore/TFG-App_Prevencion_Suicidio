import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NuevoEnlace extends StatelessWidget {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController textoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Enlace'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: textoController,
              decoration: InputDecoration(
                labelText: 'Texto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String url = urlController.text;
                    String texto = textoController.text;
                    final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
                    databaseReference.child('links').push().set({
                      'url': url,
                      'texto': texto,
                    }).then((_) {                      
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Guardar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

