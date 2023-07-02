import 'dart:math';
import 'package:demo/paginas/notas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:demo/modelos/nota.dart';

class NuevaNota extends StatefulWidget {
  @override
  NuevaNotaState createState() => NuevaNotaState();
}

class NuevaNotaState extends State<NuevaNota> {
  TextEditingController titulo = TextEditingController();
  TextEditingController contenido = TextEditingController();

  final baseDatos = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var key_ = rng.nextInt(10000);
    final datosRef = baseDatos.reference().child('notas/$key_');

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Nota'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Notas())
              );
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
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
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: TextField(
                controller: contenido,
                decoration: InputDecoration(
                  hintText: 'Contenido',
                ),
                maxLines: null,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                var nuevaNota = Nota(
                  titulo: titulo.text,
                  contenido: contenido.text,
                  fechaCreacion: DateTime.now(),
                  userId: user?.uid ?? '',
                );
                datosRef.set({
                  "Titulo": nuevaNota.titulo,
                  "Contenido": nuevaNota.contenido,
                  "FechaCreacion": nuevaNota.fechaCreacion.toString(),
                  "UserId": nuevaNota.userId,
                }).asStream();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Notas()));
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
