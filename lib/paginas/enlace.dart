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
      String role = await conseguirRolUsuario(user.uid);
      setState(() {
        admin = role == 'administrador';
      });
    }
  }

  Future<String> conseguirRolUsuario(String userId) async {
    final userRoleRef = FirebaseDatabase.instance.ref().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
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
        child: _buildLinksList(),
      ),
    );
  }

  Widget _buildLinksList() {
    final linksReference = FirebaseDatabase.instance.ref().child('links');
    return FirebaseAnimatedList(
      query: linksReference,
      itemBuilder: (context, snapshot, animation, index) {
        final linkData = snapshot.value as Map<dynamic, dynamic>;
        final linkKey = snapshot.key;
        final url = linkData['url'];
        final texto = linkData['texto'];
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    await launchUrl(url);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(texto),
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
        );
      },
    );
  }

  void borrarLink(String linkKey) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('links');
    databaseReference.child(linkKey).remove().then((_) {});
  }
}










