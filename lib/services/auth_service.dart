import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user profile data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          return docSnapshot.data();
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }
    return null;
  }

  // Get current user name
  Future<String> getCurrentUserName() async {
    final userData = await getCurrentUserData();
    if (userData != null && userData.containsKey('name')) {
      return userData['name'];
    }
    return 'User'; // Default name if not found
  }

  // Sign up with email and password
  Future<UserCredential> signUp(
    String email,
    String password, {
    String? name,
    String? phoneNumber,
    String? country,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!.uid, {
          'email': email,
          'name': name ?? '',
          'phoneNumber': phoneNumber ?? '',
          'country': country ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
