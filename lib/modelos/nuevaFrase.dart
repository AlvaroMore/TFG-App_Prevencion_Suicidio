import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: camel_case_types
class nuevaFrase extends StatefulWidget {
  const nuevaFrase({super.key});

  @override
  nuevaFraseState createState() => nuevaFraseState();
}

// ignore: camel_case_types
class nuevaFraseState extends State<nuevaFrase> {
  // ignore: deprecated_member_use
  final baseDatos = FirebaseDatabase.instance.reference();
  final auth = FirebaseAuth.instance;
  final TextEditingController fraseController = TextEditingController();

  void guardarFrase() async {
    User? user = auth.currentUser;
    if (user != null) {
      String nuevaFrase = fraseController.text.trim();
      if (nuevaFrase.isNotEmpty) {
        baseDatos.child('frases').push().set({
          'userId': user.uid,
          'frase': nuevaFrase,
        });
        Navigator.pop(context);
      }
    }
  }

  void mayusculaPrimeraLetra(String input) {
    if (input.isNotEmpty) {
      final posicionCursor = fraseController.selection.start;
      fraseController.text =
          input[0].toUpperCase() + (input.length > 1 ? input.substring(1) : '');
      fraseController.selection = TextSelection.fromPosition(
        TextPosition(offset: posicionCursor),
      );
    }
  }

  @override
  void dispose() {
    fraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Frase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: fraseController,
              decoration: const InputDecoration(
                labelText: 'Escribe una frase',
              ),
              onChanged: mayusculaPrimeraLetra,
              maxLength: 100,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: guardarFrase,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

