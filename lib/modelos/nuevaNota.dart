import 'dart:convert';
import 'dart:math';
import 'package:appbu_s/paginas/notas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:appbu_s/modelos/nota.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NuevaNota extends StatefulWidget {
  const NuevaNota({super.key});

  @override
  NuevaNotaState createState() => NuevaNotaState();
}

class NuevaNotaState extends State<NuevaNota> {
  TextEditingController titulo = TextEditingController();
  TextEditingController contenido = TextEditingController();
  final baseDatos = FirebaseDatabase.instance;
  String? adminToken;

  @override
  initState() {
    super.initState();
    fetchAdminToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
    });
  }

  Future<void> fetchAdminToken() async {
    final usersRef = baseDatos.ref().child('users');
    final DatabaseEvent dataSnapshot = await usersRef.once();
    final usuarios = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    String? adminUserId;
    
    usuarios.forEach((userId, userData) {
      final rol = userData['rol'] as String?;
      if (rol == 'administrador') {
        adminUserId = userId;
        return;
      }
    });
    if (adminUserId != null) {
      final adminTokenRef = baseDatos.ref().child('users/$adminUserId/token');
      final DatabaseEvent tokenSnapshot = await adminTokenRef.once();
      adminToken = tokenSnapshot.snapshot.value as String?;
    }
    setState(() {});
  }

  void mayusculaPrimeraLetraTitulo(String input) {
    if (input.isNotEmpty) {
      titulo.text =
          input[0].toUpperCase() + (input.length > 1 ? input.substring(1).toLowerCase() : '');

      titulo.selection = TextSelection.fromPosition(
        TextPosition(offset: titulo.text.length),
      );
    }
  }

  void mayusculaPrimeraLetraContenido(String input) {
    if (input.isNotEmpty) {
      // Save the current cursor position
      final cursorPosition = contenido.selection.start;

      contenido.text =
          input[0].toUpperCase() + (input.length > 1 ? input.substring(1) : '');

      contenido.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var key_ = rng.nextInt(10000);
    final datosRef = baseDatos.ref().child('notas/$key_');
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Nota'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Notas()),
            );
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: TextField(
                controller: titulo,
                decoration: const InputDecoration(
                  hintText: 'Titulo',
                ),
                onChanged: mayusculaPrimeraLetraTitulo,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: TextField(
                controller: contenido,
                decoration: const InputDecoration(
                  hintText: 'Contenido',
                ),
                maxLines: 6,
                maxLength: 150,
                onChanged: mayusculaPrimeraLetraContenido,
              ),
            ),
            const SizedBox(
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
                sendPushNotification();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Notas()));
              },
              child: const Text(
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

  Future<void> sendPushNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAwExjmR0:APA91bGDItwHFI6kNHxmcHM9cCrUwcEhKnjWOCYhllfHXiUZY-RklTRMr-ieHciAKvWiRoephqgNGtCaOwSQ896IZJOj2wce-_IM9oDSApNg6Xx_3f1hV8sIrj7aiTtprwX4VVVSIn6R',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Se ha creado una nueva nota",
              'title': 'Nueva nota',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': adminToken,
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}

