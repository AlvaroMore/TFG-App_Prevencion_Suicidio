import 'package:appbu_s/paginas/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'home_page.dart';
import 'dart:core';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  String? selectedRole;
  String? mensajeError = '';

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerContrasena = TextEditingController();
  final TextEditingController controllerUsuario = TextEditingController();
  final TextEditingController controllerRepetirContrasena = TextEditingController();

  Widget campoTexto(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      obscureText: title == 'Contraseña' || title == 'Repetir Contraseña',
    );
  }

  Widget errorMensaje() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            mensajeError == '' ? '' : '$mensajeError',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> crearUsuario() async {
    String error = '';

    if (controllerUsuario.text.isEmpty ||
        controllerEmail.text.isEmpty ||
        controllerContrasena.text.isEmpty) {
      error = 'Falta información en algún campo';
    } else if (controllerContrasena.text.length < 6) {
      error = 'La contraseña debe tener 6 o más caracteres';
    } else if(!correoValido(controllerEmail.text)) {
      error = 'Formato de correo no válido';
    } else if(controllerContrasena.text != controllerRepetirContrasena.text) {
      error = 'La contraseña no coincide';
    } else {
      try {
        await Auth().crearUsuario(
          usuario: controllerUsuario.text,
          email: controllerEmail.text,
          password: controllerContrasena.text,
          rol: selectedRole ?? 'usuario',
        );
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          error = 'El correo introducido ya está registrado';
        }
      } catch (e) {
        error = 'El correo introducido ya está registrado';
      }
    }
    setState(() {
      mensajeError = error;
    });
  }

  bool correoValido(String email) {
    // Use a regular expression to validate the email format
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  Widget botonRegistrarse() {
    return ElevatedButton(
      onPressed: crearUsuario,
      child: const Text('Registrarse'),
    );
  }

  Widget botonAcceder() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: const Text('Acceder'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APPBU-S'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            campoTexto('Usuario', controllerUsuario),
            campoTexto('Correo', controllerEmail),
            campoTexto('Contraseña', controllerContrasena),
            campoTexto('Repetir Contraseña', controllerRepetirContrasena),
            errorMensaje(),
            botonRegistrarse(),
            botonAcceder(),
          ],
        ),
      ),
    );
  }
}


