import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;

    final idToken = await user?.getIdToken();

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'Seller',
      }, SetOptions(merge: true));

      await SharedPrefs.saveUser(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        token: idToken ?? '',
        role: 'Seller',
      );
    }

    return userCredential;
  } catch (e, stack) {
    print('Google sign-in error: $e');
    print(stack);
    rethrow;
  }
}

class SharedPrefs {
  static Future<void> saveUser({
    required String uid,
    required String email,
    required String name,
    required String photoUrl,
    required String token,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('photoUrl', photoUrl);
    await prefs.setString('token', token);
    await prefs.setString('role', role);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('photoUrl');
    await prefs.remove('token');
    await prefs.remove('role');
  }
}