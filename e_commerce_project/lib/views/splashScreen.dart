import 'package:flutter/material.dart';
import 'package:e_commerce_project/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final bool redirectAfterGoogleSignIn;
  const SplashScreen({Key? key, this.redirectAfterGoogleSignIn = false}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.redirectAfterGoogleSignIn) {
      _handleGoogleSignIn();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await signInWithGoogle();
      if (userCredential != null) {
        Navigator.of(context).pop(true); // Başarılıysa loginPage'e true döndür
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ile giriş başarısız')),
        );
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google ile giriş hatası: $e')),
      );
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Giriş yapılıyor...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
