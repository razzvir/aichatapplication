import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // User Registration Method
  static Future<User?> registerUser(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Create user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      // Save user details in Firestore
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': DateTime.now(),
        });

        // Try to update display name separately
        try {
          await user.updateDisplayName(username);
        } catch (e) {
          print("Warning: Failed to update display name: $e");
          // Don't return null — this isn't critical
        }

        return user;
      }
      return null;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // User Login Method
  static Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Sign out Method
  static Future<void> signOut() async {
    await auth.signOut();
  }
}
