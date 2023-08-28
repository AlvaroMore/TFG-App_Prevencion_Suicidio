import 'package:appbu_s/paginas/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedRole;
  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerUsuario = TextEditingController();  
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

  Future<void> createUsersWithEmailAndPassword() async {
    String errorMessage = '';

    if (_controllerUsuario.text.isEmpty ||
        _controllerEmail.text.isEmpty ||
        _controllerPassword.text.isEmpty) {
      errorMessage = 'Falta información en algún campo';
    } else if (_controllerPassword.text.length < 6) {
      errorMessage = 'La contraseña debe tener 6 o más caracteres';
    } else {
      try {
        await Auth().createUserWithEmailAndPassword(
          usuario: _controllerUsuario.text,
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          rol: selectedRole ?? 'usuario',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'El correo introducido ya está registrado';
        }
      } catch (e) {
        errorMessage = 'El correo introducido ya está registrado';
      }
    }
    setState(() {
      this.errorMessage = errorMessage;
    });
  }


  Widget _submitButton() {
    return ElevatedButton(
      onPressed: createUsersWithEmailAndPassword,
      child: const Text('Registrarse'),
    );
  }

  Widget _loginOrRegisterButton() {
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
            _entryField('Usuario', _controllerUsuario),
            _entryField('Correo', _controllerEmail),
            _entryField('Contraseña', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}


