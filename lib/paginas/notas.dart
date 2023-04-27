import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:demo/modelos/nuevaNota.dart';

class notas extends StatefulWidget {
  @override
  notasState createState() => notasState();
}

class notasState extends State<notas> {
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
  final base_datos = FirebaseDatabase.instance;
  TextEditingController titulo = TextEditingController();
  TextEditingController contenido = TextEditingController();
  var dato;
  var valor;
  var key_;
  
  @override
  Widget build(BuildContext context) {
    final datos_ref = base_datos.ref().child('notas');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => nuevaNota(),
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
        query: datos_ref,
        shrinkWrap: true,
        itemBuilder: (context, snapshot, animation, index) {
          var valorString = snapshot.value.toString();
          valor = valorString.replaceAll(
              RegExp("{|}|Contenido: |Titulo: "), ""
              );
          valor.trim();
          dato = valor.split(',');
          return GestureDetector(
            onTap: () {
              setState(() {
                key_ = snapshot.key;
              });
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextField(
                      controller: titulo,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Titulo',
                      ),
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextField(
                      controller: contenido,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Contenido',
                      ),
                    ),
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
                        await actualizar();
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
                      datos_ref.child(snapshot.key!).remove();
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
        },
      ),
    );
  }

  actualizar() async {
    DatabaseReference datosG_ref = FirebaseDatabase.instance.ref("notas/$key_");
    await datosG_ref.update({
      "Titulo": titulo.text,
      "Contenido": contenido.text,
    });
    titulo.clear();
    contenido.clear();
  }
}