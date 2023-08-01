import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:appbu_s/modelos/nuevoEnlace.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class enlace extends StatefulWidget {
  @override
  _EnlaceState createState() => _EnlaceState();
}

class _EnlaceState extends State<enlace> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String role = await getUserRole(user.uid);
      setState(() {
        _isAdmin = role == 'administrador';
      });
    }
  }

  Future<String> getUserRole(String userId) async {
    final userRoleRef = FirebaseDatabase.instance.reference().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Links a Internet'),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NuevoEnlace()));
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: _buildLinksList(),
      ),
    );
  }

  Widget _buildLinksList() {
    final linksReference = FirebaseDatabase.instance.reference().child('links');
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
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    await launch(url);
                  },
                  child: Text(texto),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (_isAdmin)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
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
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('links');
    databaseReference.child(linkKey).remove().then((_) {});
  }
}










