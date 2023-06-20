import 'package:demo/paginas/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:demo/modelos/nuevaNota.dart';

class Notas extends StatefulWidget {
  @override
  NotasState createState() => NotasState();
}

class NotasState extends State<Notas> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notas",
      theme: ThemeData(
        primaryColor: Colors.greenAccent[700],
      ),
      home: Inicio(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final baseDatos = FirebaseDatabase.instance; //Acceso a la base de datos
  var dato;
  var valor;
  var key_;
  var userRole;

  Future<String> getUserRole(String userId) async { //Obtener el rol del usuario
    final userRoleRef = baseDatos.reference().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
  }


  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  void fetchUserRole() async { //Establecer el rol del usuario actual
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String role = await getUserRole(user.uid);
      setState(() {
        userRole = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final datosRef = baseDatos.reference().child('notas');//Referencia a la base de datos

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage())
              );
          },
        ),
      ),
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
      
      body: FirebaseAnimatedList(
        query: datosRef,
        shrinkWrap: true,
        itemBuilder: (context, snapshot, animation, index) {
          final noteData = snapshot.value as Map<dynamic, dynamic>;//Se establece los datos de la nota
          final noteUserId = noteData['UserId'] as String;//Obtengo el userId de la nota

          if (userRole == "administrador" || noteUserId == user?.uid) {//Si el usuario el administrador o tiene el mismo userId
            var valorString = noteData.toString();
            valor = valorString.replaceAll(
                RegExp("{|}|Contenido: |Titulo: |FechaCreacion: |UserId: "), "");
            valor = valor.trim();
            dato = valor.split(',');

            if (dato.length >= 2) {
              TextEditingController tituloEditar = TextEditingController(text: dato[2]);
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
                              maxLines: null,
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
                              maxLines: null,
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
                              user!.uid,
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
                        dato[2],
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
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  actualizar(String nuevoTitulo, String nuevoContenido, String userId) async {
    DatabaseReference datosGRef =
        FirebaseDatabase.instance.reference().child("notas/$key_");
    await datosGRef.update({
      "Titulo": nuevoTitulo,
      "Contenido": nuevoContenido,
      "UserId": userId,
    });
  }
}





