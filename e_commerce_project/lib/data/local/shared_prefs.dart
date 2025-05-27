
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için
import '../data/local/shared_prefs.dart'; // SharedPrefs importu eklendi

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Google hesabı seç
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // kullanıcı iptal etti

    // Tokenları al
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Firebase credential oluştur
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase ile giriş yap
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;

    // JWT Token işlemleri
    final idToken = await user?.getIdToken();
    print("JWT Token: $idToken");

    // Kullanıcı bilgilerini Firestore'a kaydet/güncelle
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'Seller', // Varsayılan rol
      }, SetOptions(merge: true));

      // Kullanıcı verilerini SharedPrefs ile kaydet
      await SharedPrefs.saveUser(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        token: idToken ?? '',
        role: 'Seller', // Varsayılan rol
      );
    }

    return userCredential;
  } catch (e, stack) {
    print('Google sign-in error: $e');
    print(stack);
    rethrow; // hatayı tekrar fırlat
  }
}