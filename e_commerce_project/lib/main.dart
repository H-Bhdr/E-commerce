import 'dart:async';
import 'dart:ui';
import 'package:e_commerce_project/views/add_product.dart';
import 'package:e_commerce_project/views/favorites_view.dart';
import 'package:e_commerce_project/views/home.dart';
import 'package:e_commerce_project/components/nav_bar.dart';
import 'package:e_commerce_project/components/app_bar.dart';
import 'package:e_commerce_project/views/loginPage.dart';
import 'package:e_commerce_project/core/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:e_commerce_project/views/profile.dart';
import 'package:e_commerce_project/data/local/shared_prefs.dart';
import 'package:e_commerce_project/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize(); // <-- notification servisini başlat
  } catch (e) {
    print('Firebase initialize error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListenerWidget(
      child: MaterialApp(
        navigatorKey: NotificationService.navigatorKey, // <--- Bunu ekle
        theme: ThemeData(
          // Use a comprehensive ColorScheme based on our custom colors
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            secondary: AppColors.secondaryColor,
            onSecondary: Colors.white,
            error: AppColors.errorColor,
            onError: Colors.white,
            surface: AppColors.surfaceColor,
            onSurface: AppColors.textColor,
          ),

          // Basic theme settings
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: AppColors.backgroundColor,

          // Component themes
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),

          iconTheme: const IconThemeData(color: AppColors.primaryColor),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
              foregroundColor: WidgetStateProperty.all(AppColors.buttonTextColor),
            ),
          ),
        ),

        title: 'Material App',
        home: const StartScreen(),
      ),
    );
  }
}

// Bildirimleri dinleyen widget
class NotificationListenerWidget extends StatefulWidget {
  final Widget child;
  const NotificationListenerWidget({required this.child, super.key});

  @override
  State<NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  @override
  void initState() {
    super.initState();
    NotificationService.priceChangeNotifier.addListener(_onPriceChange);
  }

  @override
  void dispose() {
    NotificationService.priceChangeNotifier.removeListener(_onPriceChange);
    super.dispose();
  }

  void _onPriceChange() {
    final product = NotificationService.priceChangeNotifier.value;
    if (product != null && mounted) {
      final context = NotificationService.navigatorKey.currentContext ?? this.context;
      final oldPrice = product.oldPrice;
      final newPrice = product.price;
      String priceText = (oldPrice != null)
          ? 'Favori ürününüzün fiyatı değişti: ${product.title}\nEski: ${oldPrice.toStringAsFixed(2)} ₺  Yeni: ${newPrice.toStringAsFixed(2)} ₺'
          : 'Favori ürününüzün fiyatı değişti: ${product.title} → ${newPrice.toStringAsFixed(2)} ₺';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(priceText),
          duration: const Duration(seconds: 4),
        ),
      );
      // Notifier'ı sıfırla ki tekrar tetiklenebilsin
      NotificationService.priceChangeNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Token kontrolü yapan başlangıç widget'ı
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<bool> _hasToken() async {
    final token = await SharedPrefs.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return const MainNavigation();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    FavoritesView(), // Favoriler
    AddProductPage(), // Ekle
    ProfilePage(),    // Profil
  ];

  static const List<String> _titles = ['Ana Sayfa', 'Favoriler', 'Ekle', 'Profil'];

  void _onItemTapped(int index) async {
    // Eğer "Ekle" sekmesine tıklanıyorsa (index 2)
    if (index == 2) {
      final userData = await SharedPrefs.getUserData();
      final role = userData['role'] ?? '';
      if (role.toLowerCase() == 'customer') {
        // ProfilePage'deki fonksiyon ile daha güzel uyarı ve yönlendirme
        if (mounted) {
          await ProfilePage.showSellerAccessDenied(context, () {
            setState(() {
              _selectedIndex = 3; // Profil sekmesine yönlendir
            });
          });
        }
        return; // Sayfa değişimini engelle
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Güvenlik: index aralığını kontrol et
    final int safeIndex = (_selectedIndex >= 0 && _selectedIndex < _pages.length) ? _selectedIndex : 0;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: MyAppBar(title: Text(_titles[safeIndex])),
      drawer: MyDrawer(),
      body: _pages[safeIndex],
      bottomNavigationBar: MyNavBar(
        currentIndex: safeIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}