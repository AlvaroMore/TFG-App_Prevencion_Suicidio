import 'package:appbu_s/paginas/enlace.dart';
import 'package:appbu_s/paginas/login_page.dart';
import 'package:appbu_s/paginas/media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appbu_s/auth.dart';
import 'package:flutter/material.dart';
import 'package:appbu_s/paginas/calendario.dart';
import 'package:appbu_s/paginas/notas.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';


class Menu extends StatefulWidget{
  const Menu({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  final User? usuario = Auth().currentUser;

  Future<void> tokenDispositivo() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    final String deviceToken = (await firebaseMessaging.getToken())!;
    final DatabaseReference deviceTokenRef =
        FirebaseDatabase.instance.ref().child('users/${usuario?.uid}/token');
    deviceTokenRef.set(deviceToken);
  }

  @override
  void initState() {
    super.initState();
    tokenDispositivo();
  }

  Future<void> signOut() async {
    try {
      await Auth().signOut();
      exit(0);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Widget userId(){
    return Text(usuario?.email ?? 'Usuario');
  }

  Widget calendario(BuildContext context) {
    return ElevatedButton(
      child: const Text('Calendario'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Calendario()),
        );
      }
    );
  }
  Widget media(BuildContext context) {
    return ElevatedButton(
      child: const Text('Media'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Media()),
        );
      }
    );
  }
  Widget enlace(BuildContext context) {
    return ElevatedButton(
      child: const Text('URL'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Enlace()),
        );
      }
    );
  }

  Widget notas(BuildContext context) {
    return ElevatedButton(
      child: const Text('Notas'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Notas()),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('APPBU-S'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      
      body: Container(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 10,
          left: 10,
          right: 10
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const Calendario()),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(253, 229, 9, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
                        child: const Icon(Icons.calendar_today, size: 60, color: Colors.black),
                      ),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Media()),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 31, 161, 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
                        child: const Icon(Icons.play_arrow, size: 80, color: Colors.black),
                      ),
                    )
                  
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: const <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: const <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Enlace()),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 30, 154, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
                        child: const Icon(Icons.travel_explore, size: 60, color: Colors.black),
                      ),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const Notas()),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 145, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
                        child: const Icon(Icons.edit_note, size: 70, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: const <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: const <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red  ,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
                        child: const Icon(Icons.logout, size: 50, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
        ),
      );
  }
}

