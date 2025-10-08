import 'package:immobile/page/homePage.dart';
import 'package:immobile/page/profilePage.dart';
import 'package:immobile/page/historyPage.dart';
import 'package:immobile/page/reportsPage.dart';
import 'package:immobile/page/pidPage.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/widget/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AppBottomNavigation extends StatefulWidget {
  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigation> {
  GlobalVM globalVM = Get.find();
  final List<Widget> pages = [
    HomePage(
      key: PageStorageKey('Page1'),
    ),
    // ReportsPage(
    //   key: PageStorageKey('Page2'),
    // ),
    // HistoryPage(
    //   key: PageStorageKey('Page3'),
    // ),
    ProfilePage(
      key: PageStorageKey('Page4'),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // GlobalVar.darkChecker(context);

    return Scaffold(
      //BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kGrey100Color,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            // if (index == 0) {
            //   globalVM.choicecategory.value = "AB";
            // }
            EasyLoading.dismiss();
          });
        },
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: kGreyColor,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.assignment_late_outlined), label: 'Reports'),
          // BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),

          // BottomNavigationBarItem(
          //     icon: Icon(Icons.qr_code_outlined), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: PageStorage(bucket: bucket, child: pages[_selectedIndex]),
    );
  }
}
