import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Auth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  
  Future<void> accederUsuario({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> crearUsuario({
    required String email,
    required String password,
    required String rol,
    required String usuario,
  }) async {
    try {
      final userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final databaseReference = FirebaseDatabase.instance.ref();
        await databaseReference
            .child('users')
            .child(userCredential.user!.uid)
            .update({'rol': rol, 'usuario': usuario});
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
