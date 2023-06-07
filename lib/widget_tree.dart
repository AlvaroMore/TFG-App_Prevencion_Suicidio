import 'package:demo/auth.dart';
import 'package:demo/paginas/home_page.dart';
import 'package:demo/paginas/login_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth para tener acceso al tipo User
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late Stream<User?> _authStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authStream = Auth().authStateChanges;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : StreamBuilder<User?>(
            stream: _authStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return HomePage();
              } else {
                return const LoginPage();
              }
            },
          );
  }
}