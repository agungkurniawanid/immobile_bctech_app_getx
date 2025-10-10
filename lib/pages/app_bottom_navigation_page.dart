import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/constants/theme_constant.dart';
import 'package:immobile_app_fixed/pages/home_page.dart';
import 'package:immobile_app_fixed/pages/profilePage.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({super.key});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigation> {
  final GlobalVM globalVM = Get.find<GlobalVM>();
  final PageStorageBucket _bucket = PageStorageBucket();

  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(key: PageStorageKey('Page1')),
    const ProfilePage(key: PageStorageKey('Page2')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kGrey100Color,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: kGreyColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
