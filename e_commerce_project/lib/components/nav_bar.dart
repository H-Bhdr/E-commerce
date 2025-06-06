import 'package:flutter/material.dart';
import 'package:e_commerce_project/core/utils.dart';

class MyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyNavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.backgroundColor,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primaryColor, // Use blue for selected items
      unselectedItemColor: Colors.grey, // Grey for unselected items
      type: BottomNavigationBarType.fixed, // Prevents shifting behavior
      items: const [ 
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoriler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Ekle',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
