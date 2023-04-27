import 'dart:math';

import 'package:demo/paginas/notas.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class nuevaNota extends StatefulWidget {
  @override
  nuevaNotaState createState() => nuevaNotaState();
}

class nuevaNotaState extends State<nuevaNota> {
  TextEditingController titulo = TextEditingController();
  TextEditingController contenido = TextEditingController();

  final baseDatos = FirebaseDatabase.instance;
  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var key_ = rng.nextInt(10000);
    final datosRef = baseDatos.ref().child('notas/$key_');

    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva Nota"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10
              ),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: TextField(
                controller: titulo,
                decoration: InputDecoration(
                  hintText: 'Titulo',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10
              ),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: TextField(
                controller: contenido,
                decoration: InputDecoration(
                  hintText: 'Contenido',
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                datosRef.set({
                  "Titulo": titulo.text,
                  "Contenido": contenido.text,
                }).asStream();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => notas()));
              },
              child: Text(
                "Guardar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}