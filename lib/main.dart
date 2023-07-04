import 'package:demo/paginas/enlace.dart';
import 'package:demo/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:demo/paginas/calendario.dart';
import 'package:demo/paginas/enlace.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> backgroundHandler(RemoteMessage message) async{
  String? title = message.notification!.title;
  String? body = message.notification!.body;

}

Future<void> main() async{
  

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

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
        '/calendario':(context) => Calendario(),
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