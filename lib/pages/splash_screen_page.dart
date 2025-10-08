import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan import ini

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key}); // Tambahkan constructor

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation; // Tambahkan late
  late AnimationController controller; // Tambahkan late

  // Comment sementara karena class ini tidak didefinisikan
  // final GlobalVM globalVM = Get.find();
  // final Rolevm roleVM = Get.find();

  @override
  void initState() {
    super.initState();

    // Animation setup
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    animation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(curve); // Tambahkan tipe double
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();
    startSplashScreen();
  }

  // Future<void> _showMyDialog() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Connection Time Out'),
  //         backgroundColor: Colors.black54,
  //         content: const SingleChildScrollView(
  //           child: ListBody(children: <Widget>[Text('Please Try Again.')]),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<String?> getUserId() async {
    // Ubah return type menjadi String?
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userid');
  }

  void toLogin() async {
    var userid = await getUserId();

    if (userid == null) {
      // Navigate to login if no user is logged in
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage(),
          ), // Tambahkan const
        );
      }
    } else {
      // globalVM.username.value = userid; // Comment sementara

      // Using FutureBuilder untuk data yang tidak real-time
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userid) // Gunakan userid langsung
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    Logger().e('User document not found');
                    return const Center(child: Text('User document not found'));
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>?;
                  var hasLogin = userData?['status'];

                  if (hasLogin != null && hasLogin != 'null') {
                    // Navigate to AppBottomNavigation if user is logged in
                    return const AppBottomNavigation();
                  } else {
                    return const LoginPage();
                  }
                },
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startSplashScreen() {
    var duration = const Duration(seconds: 3);
    Timer(duration, () {
      if (mounted) {
        toLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: animation,
              child: SizedBox(
                // Ganti Container dengan SizedBox untuk performance
                width: 200,
                child: Text(
                  'IM',
                  style: TextStyle(
                    color: Colors.blue, // Ganti dengan warna yang sesuai
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Sesuaikan ukuran font
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: animation,
              child: SizedBox(
                width: 200,
                child: Text(
                  'MOBILE',
                  style: TextStyle(
                    color: Colors.blue, // Ganti dengan warna yang sesuai
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // Sesuaikan ukuran font
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder classes untuk compile - ganti dengan implementasi asli
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Login Page')));
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Main App')));
  }
}

// Class untuk menyimpan global variables
class GlobalVar {
  static double height = 0;
  static double width = 0;
}
