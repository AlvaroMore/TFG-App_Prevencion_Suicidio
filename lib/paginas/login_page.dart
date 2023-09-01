import 'package:appbu_s/paginas/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String? mensajeError = '';
  bool isLogin = true;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerContrasena = TextEditingController();

  Widget errorMensaje() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        mensajeError == '' ? '' : '$mensajeError',
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Future<void> accederUsuario() async {
    String error = '';

    if (controllerEmail.text.isEmpty ||
        controllerContrasena.text.isEmpty) {
      error = 'Falta información en algún campo';
    } else {
      try {
        await Auth().accederUsuario(
          email: controllerEmail.text,
          password: controllerContrasena.text,
        );
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          error = 'El correo introducido no está registrado.';
        } else if (e.code == 'wrong-password') {
          error = 'Contraseña incorrecta.';
        }
      } catch (e) {
        error = 'Correo o contraseña incorrectos';
      }
    }
    setState(() {
      mensajeError = error;
    });
  }

  Widget campoTexto(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget botonAcceder() {
    return ElevatedButton(
      onPressed: accederUsuario,
      child: const Text('Entrar'),
    );
  }

  Widget botonRegistrarse() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: const Text('Registrarse'),
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
            campoTexto('Correo', controllerEmail),
            campoTexto('Contraseña', controllerContrasena),
            errorMensaje(),
            botonAcceder(),
            botonRegistrarse(),
          ],
        ),
      ),
    );
  }
}

