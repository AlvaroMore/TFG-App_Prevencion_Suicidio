import 'package:demo/paginas/enlace.dart';
import 'package:demo/paginas/ajustes.dart';
import 'package:demo/paginas/media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo/auth.dart';
import 'package:flutter/material.dart';
import 'package:demo/paginas/calendario.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ajustes()),
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
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
            _calendario(context),
            _URL(context),
            _ajustes(context),
            _media(context),
          ],
        )
      ),
    );
  }
}

