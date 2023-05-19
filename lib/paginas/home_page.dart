import 'package:demo/paginas/enlace.dart';
import 'package:demo/paginas/ajustes.dart';
import 'package:demo/paginas/media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo/auth.dart';
import 'package:flutter/material.dart';
import 'package:demo/paginas/calendario.dart';
import 'package:app_settings/app_settings.dart';
import 'package:demo/paginas/notas.dart';

class HomePage extends StatelessWidget{
  HomePage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  Future<void> signOut() async{
    await Auth().signOut();
  }
  Widget _title(){
    return const Text('Inicio');
  }
  Widget _userUid(){
    return Text(user?.email ?? 'Usuario');
  }
  Widget _signOutButton(){
    return ElevatedButton(
      onPressed: signOut, 
      child: const Text('Salir'),
      );
  }
  Widget _calendario(BuildContext context) {
    return ElevatedButton(
      child: const Text('Calendario'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => calendario()),
        );
      }
    );
  }
  Widget _media(BuildContext context) {
    return ElevatedButton(
      child: const Text('Media'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => media()),
        );
      }
    );
  }
  Widget _URL(BuildContext context) {
    return ElevatedButton(
      child: const Text('URL'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => enlace()),
        );
      }
    );
  }
  Widget _ajustes(BuildContext context) {
    return ElevatedButton(
      child: const Text('Ajustes'),
      onPressed: () {
        AppSettings.openDeviceSettings();
        //Navigator.push(
          //context,
          //MaterialPageRoute(builder: (context) => ajustes()),
        //);
      }
    );
  }
  Widget _notas(BuildContext context) {
    return ElevatedButton(
      child: const Text('Notas'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => notas()),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        
      ),
      // ignore: avoid_unnecessary_containers
      body: Container(
        padding: const EdgeInsets.only(
          top: 75,
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
                            MaterialPageRoute(builder: (context) => calendario()),
                            );
                        },
                        child: Icon(Icons.calendar_today, size: 60, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(253, 229, 9, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
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
                            MaterialPageRoute(builder: (context) => media()),
                            );
                        },
                        child: Icon(Icons.play_arrow, size: 80, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 31, 161, 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
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
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: <Widget>[
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
                            MaterialPageRoute(builder: (context) => enlace()),
                            );
                        },
                        child: Icon(Icons.travel_explore, size: 60, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 30, 154, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
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
                            MaterialPageRoute(builder: (context) => notas()),
                            );
                        },
                        child: Icon(Icons.edit_note, size: 70, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 145, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
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
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: <Widget>[
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
                        onPressed: signOut,
                        child: Icon(Icons.logout, size: 50, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red  ,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75)
                          )
                        ),
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

