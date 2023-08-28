import 'package:appbu_s/auth.dart';
import 'package:appbu_s/paginas/home_page.dart';
import 'package:appbu_s/paginas/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                return Menu();
              } else {
                return const LoginPage();
              }
            },
          );
  }
}