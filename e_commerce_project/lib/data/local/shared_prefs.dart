import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _keyUid = 'uid';
  static const String _keyEmail = 'email';
  static const String _keyName = 'name';
  static const String _keyPhotoUrl = 'photoUrl';
  static const String _keyToken = 'token';
  static const String _keyRole = 'role';

  static Future<void> saveUser({
    required String uid,
    required String email,
    required String name,
    required String photoUrl,
    required String token,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_keyUid, uid),
      prefs.setString(_keyEmail, email),
      prefs.setString(_keyName, name),
      prefs.setString(_keyPhotoUrl, photoUrl),
      prefs.setString(_keyToken, token),
      prefs.setString(_keyRole, role),
    ]);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString(_keyUid),
      'email': prefs.getString(_keyEmail),
      'name': prefs.getString(_keyName),
      'photoUrl': prefs.getString(_keyPhotoUrl),
      'token': prefs.getString(_keyToken),
      'role': prefs.getString(_keyRole),
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyUid),
      prefs.remove(_keyEmail),
      prefs.remove(_keyName),
      prefs.remove(_keyPhotoUrl),
      prefs.remove(_keyToken),
      prefs.remove(_keyRole),
    ]);
  }
}

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
    print("JWT Token: $idToken");

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