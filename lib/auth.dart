import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String rol,
  }) async {
    try {
      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar el rol en Realtime Database
      if (userCredential.user != null) {
        final databaseReference = FirebaseDatabase.instance.reference();
        await databaseReference
            .child('users')
            .child(userCredential.user!.uid)
            .update({'rol': rol});
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}