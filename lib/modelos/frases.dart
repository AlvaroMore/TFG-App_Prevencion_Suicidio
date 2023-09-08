import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nuevaFrase.dart';

class Frases extends StatefulWidget {
  const Frases({super.key});

  @override
  FrasesState createState() => FrasesState();
}

class FrasesState extends State<Frases> {
  final baseDatos = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> listaFrases = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchFrases();
  }

  void fetchUserId() async {
    final usuarioActual = FirebaseAuth.instance.currentUser;
    if (usuarioActual != null) {
      setState(() {
        userId = usuarioActual.uid;
      });
    }
  }

  void fetchFrases() {
    baseDatos.child('frases').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> frasesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> frasesLista = [];
        frasesMap.forEach((key, value) {
          if (value['userId'] == userId) {
            frasesLista.add({
              'key': key,
              'frase': value['frase'],
            });
          }
        });

        setState(() {
          listaFrases = frasesLista;
        });
      }
    });
  }

  void borrarFrase(Map<String, dynamic> frase) {
    final fraseBaseDatos = baseDatos.child('frases');

    fraseBaseDatos.child(frase['key']).remove().then((_) {
      setState(() {
        listaFrases.remove(frase);
      });
    });
  }

  void mensajeEliminacion(BuildContext context, Map<String, dynamic> frase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Frase'),
          content: const Text('¿Seguro que quieres eliminar esta frase?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                borrarFrase(frase);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Frase eliminada')),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void editarFrase(Map<String, dynamic> frase) {
    TextEditingController fraseEditarController =
        TextEditingController(text: frase['frase']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Editar Frase'),
          contentPadding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: fraseEditarController,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Frase'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    actualizarFrase(frase, fraseEditarController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Frase actualizada')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void actualizarFrase(Map<String, dynamic> frase, String nuevaFrase) {
    final fraseBaseDatos = baseDatos.child('frases');

    fraseBaseDatos.child(frase['key']).update({
      'frase': nuevaFrase,
    }).then((_) {
      setState(() {
        frase['frase'] = nuevaFrase;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frases'),
      ),
      body: ListView.builder(
        itemCount: listaFrases.length,
        itemBuilder: (context, index) {
          final frase = listaFrases[index];
          return GestureDetector(
            onLongPress: () => mensajeEliminacion(context, frase),
            onTap: () => editarFrase(frase),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 169, 226, 252),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      frase['frase'],
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const nuevaFrase(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}






