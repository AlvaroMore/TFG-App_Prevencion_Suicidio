import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:demo/modelos/nuevaNota.dart';

class notas extends StatefulWidget {
  @override
  NotasState createState() => NotasState();
}

class NotasState extends State<notas> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notas",
      theme: ThemeData(
        primaryColor: Colors.greenAccent[700],
      ),
      home: inicio(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class inicio extends StatefulWidget {
  @override
  _inicioState createState() => _inicioState();
}

class _inicioState extends State<inicio> {
  final baseDatos = FirebaseDatabase.instance;
  var dato;
  var valor;
  var key_;

  @override
  Widget build(BuildContext context) {
    final datosRef = baseDatos.reference().child('notas');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaNota(),
            ),
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Notas',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FirebaseAnimatedList(
        query: datosRef,
        shrinkWrap: true,
        itemBuilder: (context, snapshot, animation, index) {
          var valorString = snapshot.value.toString();
          valor = valorString.replaceAll(RegExp("{|}|Contenido: |Titulo: |FechaCreacion: "), "");
          valor = valor.trim();
          dato = valor.split(',');
          if (dato.length >= 2) {
            TextEditingController tituloEditar = TextEditingController(text: dato[1]);
            TextEditingController contenidoEditar = TextEditingController(text: dato[0]);

            return GestureDetector(
              onTap: () {
                setState(() {
                  key_ = snapshot.key;
                });
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Editar Nota",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: TextField(
                            controller: tituloEditar,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Titulo',
                            ),
                            maxLines: null,  // Expandable multiline text field
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: TextField(
                            controller: contenidoEditar,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Contenido',
                            ),
                            maxLines: null,  // Expandable multiline text field
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        color: Colors.blue,
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await actualizar(
                            tituloEditar.text,
                            contenidoEditar.text,
                          );
                          Navigator.of(ctx).pop();
                        },
                        color: Colors.blue,
                        child: Text(
                          "Aceptar",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Color.fromARGB(171, 152, 209, 255),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 255, 85, 72),
                      ),
                      onPressed: () {
                        datosRef.child(snapshot.key!).remove();
                      },
                    ),
                    title: Text(
                      dato[1],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      dato[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  actualizar(String nuevoTitulo, String nuevoContenido) async {
    DatabaseReference datosGRef = FirebaseDatabase.instance.reference().child("notas/$key_");
    await datosGRef.update({
      "Titulo": nuevoTitulo,
      "Contenido": nuevoContenido,
    });
  }
}