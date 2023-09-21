import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:appbu_s/modelos/nuevoEnlace.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class Enlace extends StatefulWidget {
  @override
  EnlaceState createState() => EnlaceState();
}

class EnlaceState extends State<Enlace> {
  bool admin = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String rol = await conseguirRolUsuario(user.uid);
      setState(() {
        admin = rol == 'administrador';
      });
    }
  }

  Future<String> conseguirRolUsuario(String userId) async {
    final userRoleRef = FirebaseDatabase.instance.ref().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
  }

  void borrarLink(String linkKey) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('links');
    databaseReference.child(linkKey).remove().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Links a Internet'),
      ),
      floatingActionButton: admin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NuevoEnlace()));
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: listaEnlaces(),
      ),
    );
  }

Widget listaEnlaces() {
  final linksRef = FirebaseDatabase.instance.ref().child('links');
  return FirebaseAnimatedList(
    query: linksRef,
    itemBuilder: (context, snapshot, animation, index) {
      final linkData = snapshot.value as Map<dynamic, dynamic>;
      final linkKey = snapshot.key;
      final url = linkData['url'];
      final texto = linkData['texto'];
      return Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      await launchUrl(uri);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link),
                        SizedBox(width: 8),
                        Text(texto),
                      ],
                    ),
                  ),
                ),
                if (admin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => borrarLink(linkKey!),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    },
  );
}
}












