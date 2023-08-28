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
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();

  Widget _errorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        errorMessage == '' ? '' : '$errorMessage',
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    String errorMessage = '';

    if (controllerEmail.text.isEmpty ||
        controllerPassword.text.isEmpty) {
      errorMessage = 'Falta información en algún campo';
    } else {
      try {
        await Auth().signInWithEmailAndPassword(
          email: controllerEmail.text,
          password: controllerPassword.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorMessage = 'El correo introducido no está registrado.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta.';
        }
      } catch (e) {
        errorMessage = 'Correo o contraseña incorrectos';
      }
    }
    setState(() {
      this.errorMessage = errorMessage;
    });
  }



  Widget _title() {
    return const Text('APPBU-S');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: signInWithEmailAndPassword,
      child: const Text('Entrar'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: Text('Registrarse'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
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
            _entryField('Correo', controllerEmail),
            _entryField('Contraseña', controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}

