import 'package:appbu_s/paginas/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:appbu_s/modelos/nuevaNota.dart';

class Notas extends StatefulWidget {
  const Notas({super.key});

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
      home: const blocNotas(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ignore: camel_case_types
class blocNotas extends StatefulWidget {
  const blocNotas({super.key});

  @override
  blocNotasState createState() => blocNotasState();
}

// ignore: camel_case_types
class blocNotasState extends State<blocNotas> {
  final baseDatos = FirebaseDatabase.instance;
  // ignore: prefer_typing_uninitialized_variables
  var dato;
  // ignore: prefer_typing_uninitialized_variables
  var valor;
  // ignore: prefer_typing_uninitialized_variables
  var key;
  // ignore: prefer_typing_uninitialized_variables
  var userRol;
  String usuarioSeleccionado = '';
  String usuarioSeleccionadoId = '';
  bool mostrarMenu = false;
  List<String> listaUsuarios = [];
  List<Map<dynamic, dynamic>> notasFiltradas = [];

  Future<String> conseguirRolUsuario(String userId) async {
    // ignore: deprecated_member_use
    final userRoleRef = baseDatos.reference().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
  }

  Future<String> conseguirUserId(String usuario) async {
    // ignore: deprecated_member_use
    final usersRef = baseDatos.reference().child('users');
    DatabaseEvent snapshot = await usersRef.once();
    Map<dynamic, dynamic> usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
    String userId = '';
    for (var entry in usersMap.entries) {
      Map<dynamic, dynamic> userData = entry.value as Map<dynamic, dynamic>;
      String usuarioActual = userData['usuario'] as String;
      if (usuarioActual == usuario) {
        userId = entry.key as String;
      }
    }
    return userId;
  }

  actualizar(String nuevoTitulo, String nuevoContenido, String userId) async {
    DatabaseReference datosGRef =
        // ignore: deprecated_member_use
        FirebaseDatabase.instance.reference().child("notas/$key");
    await datosGRef.update({
      "Titulo": nuevoTitulo,
      "Contenido": nuevoContenido,
      "UserId": userId,
    });
  }

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    DatabaseReference usersRef = baseDatos.reference().child('users');
      usersRef.once().then((DatabaseEvent snapshot) {
        Map<dynamic, dynamic> usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        listaUsuarios = usersMap.entries.map((e) => e.value['usuario']).toSet().toList().cast<String>();
        setState(() {
          usuarioSeleccionado = listaUsuarios.isNotEmpty ? listaUsuarios[0] : '';
        });
    });
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String rol = await conseguirRolUsuario(user.uid);
      setState(() {
        userRol = rol;
        mostrarMenu = (userRol == 'administrador');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final datosRef = baseDatos.reference().child('notas');

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Menu()));
          },
        ),
        actions: [
          if (mostrarMenu)
            DropdownButton<String>(
              value: usuarioSeleccionado,
              onChanged: (String? nuevoValor) {
                conseguirUserId(nuevoValor!).then((userId) {
                  setState(() {
                    usuarioSeleccionado = nuevoValor;
                    usuarioSeleccionadoId = userId;
                  });
                });
              },
              items: listaUsuarios.map((String usuario) {
                return DropdownMenuItem<String>(
                  value: usuario,
                  child: Text(usuario),
                );
              }).toList(),
              hint: const Text('Seleccione un usuario'),
              dropdownColor: Colors.white,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NuevaNota()));
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(),
          Expanded(
            child: FirebaseAnimatedList(
              query: datosRef,
              shrinkWrap: true,
              itemBuilder: (context, snapshot, animation, index) {
                final datosNota = snapshot.value as Map<dynamic, dynamic>;
                final idUsuarioNota = datosNota['UserId'] as String;

                if (userRol == 'administrador') {
                  if (usuarioSeleccionado.isEmpty || idUsuarioNota == usuarioSeleccionadoId) {            
            var valorString = datosNota.toString();
            valor = valorString.replaceAll(
                RegExp("{|}|Contenido: |Titulo: |FechaCreacion: |UserId: "), "");
            valor = valor.trim();
            dato = valor.split(',');
            notasFiltradas.add(datosNota);

            if (dato.length >= 2) {
              TextEditingController tituloEditar = TextEditingController(text: dato[2]);
              TextEditingController contenidoEditar = TextEditingController(text: dato[0]);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    key = snapshot.key;
                  });
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
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
                              decoration: const InputDecoration(
                                hintText: 'Titulo',
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: TextField(
                              controller: contenidoEditar,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
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
                          child: const Text(
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
                            // ignore: use_build_context_synchronously
                            Navigator.of(ctx).pop();
                          },
                          color: Colors.blue,
                          child: const Text(
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
                        side: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: const Color.fromARGB(171, 152, 209, 255),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 255, 85, 72),
                        ),
                        onPressed: () {
                          datosRef.child(snapshot.key!).remove();
                        },
                      ),
                      title: Text(
                        dato[2],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        dato[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
                  }
            } else if (idUsuarioNota == user?.uid) {
            var valorString = datosNota.toString();
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
                    key = snapshot.key;
                  });
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
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
                              decoration: const InputDecoration(
                                hintText: 'Titulo',
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: TextField(
                              controller: contenidoEditar,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
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
                          child: const Text(
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
                            // ignore: use_build_context_synchronously
                            Navigator.of(ctx).pop();
                          },
                          color: Colors.blue,
                          child: const Text(
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
                        side: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: const Color.fromARGB(171, 152, 209, 255),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 255, 85, 72),
                        ),
                        onPressed: () {
                          datosRef.child(snapshot.key!).remove();
                        },
                      ),
                      title: Text(
                        dato[2],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        dato[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return const SizedBox();
              }
            ),
      ),
        ],
          ),
    );
  }
}