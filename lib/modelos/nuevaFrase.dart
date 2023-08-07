import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class nuevaFrase extends StatefulWidget {
  @override
  nuevaFraseState createState() => nuevaFraseState();
}

class nuevaFraseState extends State<nuevaFrase> {
  final _databaseReference = FirebaseDatabase.instance.reference();
  final _auth = FirebaseAuth.instance; // Firebase Auth instance
  TextEditingController _fraseController = TextEditingController();

  void _guardarFrase() async {
    User? user = _auth.currentUser; // Get the currently authenticated user
    if (user != null) {
      String nuevaFrase = _fraseController.text.trim();
      if (nuevaFrase.isNotEmpty) {
        // Store the phrase along with the user's ID
        _databaseReference.child('frases').push().set({
          'userId': user.uid, // Store the user's ID
          'frase': nuevaFrase,
        });

        Navigator.pop(context); // Return to the previous screen
      }
    }
  }

  @override
  void dispose() {
    _fraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Frase'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fraseController,
              decoration: InputDecoration(
                labelText: 'Escribe una frase',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarFrase,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

