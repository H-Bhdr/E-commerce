import 'package:e_commerce_project/views/add_product.dart';
import 'package:e_commerce_project/views/favorites_view.dart';
import 'package:e_commerce_project/views/home.dart';
import 'package:e_commerce_project/components/nav_bar.dart';
import 'package:e_commerce_project/components/app_bar.dart';
import 'package:e_commerce_project/views/loginPage.dart';
import 'package:e_commerce_project/core/utils.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          background: AppColors.backgroundColor,
          onBackground: AppColors.textColor,
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
        cardTheme: const CardTheme(
          color: AppColors.cardColor,
          elevation: 2,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
            foregroundColor: WidgetStateProperty.all(AppColors.buttonTextColor),
          ),
        ),
      ),
      
      title: 'Material App',
      home: LoginPage(),
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
  ];

  static const List<String> _titles = [
    'Ana Sayfa',
    'Favoriler',
    'Ekle',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Use the defined background color
      appBar: MyAppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: MyDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

      ),
    );
    
  }
}