import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'nuevaFrase.dart';

class Frases extends StatefulWidget {
  @override
  _FrasesState createState() => _FrasesState();
}

class _FrasesState extends State<Frases> {
  final _databaseReference = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _phrases = []; // List to store fetched phrases

  @override
  void initState() {
    super.initState();
    _fetchPhrases(); // Fetch phrases when the widget initializes
  }

  void _fetchPhrases() {
    _databaseReference.child('frases').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> phrasesMap = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> phrasesList = [];

        phrasesMap.forEach((key, value) {
          phrasesList.add({
            'frase': value['frase'],
          });
        });

        setState(() {
          _phrases = phrasesList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frases'),
      ),
      body: ListView.builder(
        itemCount: _phrases.length,
        itemBuilder: (context, index) {
          final phrase = _phrases[index];
          return ListTile(
            title: Text(phrase['frase']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => nuevaFrase(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

