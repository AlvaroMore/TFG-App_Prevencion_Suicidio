import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  String? selectedRole;
  String? errorMessage = '';
  bool isLogin = true;
  bool isAdminMode = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Widget _roleDropdown() {
    if (!isAdminMode){
      return SizedBox.shrink();
    }
    return DropdownButton<String>(
      value: selectedRole,
      onChanged: (String? newValue) {
        setState(() {
          selectedRole = newValue;
        });
      },
      items: <String>[
        'usuario',
        'administrador',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _adminButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isAdminMode = true;
        });
      },
      child: Text('Modo Administrador'),
    );
  }

  Future<void> signInWithEmailAndPassword() async{
    try{
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text,
        );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUsersWithEmailAndPassword() async{
    try{
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text,
        rol: selectedRole ?? 'usuario',
        );
    } on FirebaseAuthException catch (e){
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title(){
    
    return const Text('APPBU-S');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage(){
    return Text(errorMessage == ''?'':'Humm ? $errorMessage');
  }
  
  Widget _submitButton(){
    return ElevatedButton(
      onPressed: 
          isLogin ? signInWithEmailAndPassword:createUsersWithEmailAndPassword,
      child: Text(isLogin ? 'Entrar':'Registrarse')
      );
  }

  Widget _loginOrRegisterButton(){
    return TextButton(
      onPressed: (){
        setState(() {
          isLogin = !isLogin;
        });
      }, 
      child: Text(isLogin? 'Registrarse':'Entrar'),
      );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('Usuario', _controllerEmail),
            _entryField('Contraseña', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        )
      )
    );
  }
}