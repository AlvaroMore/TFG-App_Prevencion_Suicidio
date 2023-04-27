import 'package:demo/paginas/enlace.dart';
import 'package:demo/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:demo/paginas/calendario.dart';
import 'package:demo/paginas/enlace.dart';
import 'package:demo/paginas/login_register_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      routes: {
        '/calendario':(context) => calendario(),
        '/URL':(context) => enlace(),
        //'/Cerar_Sesion':(context) => ,


      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
    );
  }
}