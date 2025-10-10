import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/pages/login_page.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/widgets/out_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalVM _globalVM = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double baseWidth = 360;
    final double fem = MediaQuery.of(context).size.width / baseWidth;
    final double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(fem, ffem),
                const SizedBox(height: 24),
                _buildLogoutButton(fem, ffem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double fem, double ffem) {
    return SizedBox(
      width: double.infinity,
      height: 345 * fem,
      child: Stack(
        children: [
          Container(
            width: 360 * fem,
            height: 260 * fem,
            color: const Color(0xfff44236),
          ),
          Positioned(
            left: 98 * fem,
            top: 182 * fem,
            child: Container(
              width: 163 * fem,
              height: 163 * fem,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(81.5 * fem),
              ),
              child: Stack(
                children: [
                  // Image Frame
                  Positioned(
                    left: 7 * fem,
                    top: 7 * fem,
                    child: Container(
                      width: 148 * fem,
                      height: 148 * fem,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(74 * fem),
                        color: const Color(0xfff44236),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 54 * fem,
                    top: 51 * fem,
                    child: Text(
                      _globalVM.username.value.isNotEmpty
                          ? _globalVM.username.value[0].toUpperCase()
                          : 'U',
                      textAlign: TextAlign.center,
                      style: safeGoogleFont(
                        'Montserrat',
                        fontSize: 48 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.2175 * ffem / fem,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Title
          Positioned(
            left: 96 * fem,
            top: 73 * fem,
            child: SizedBox(
              width: 169 * fem,
              height: 49 * fem,
              child: FutureBuilder<String?>(
                future: _getUserName(),
                builder: (context, snapshot) {
                  final String name = snapshot.data ?? 'User';
                  return Text(
                    'Profile\n$name',
                    textAlign: TextAlign.center,
                    style: safeGoogleFont(
                      'Montserrat',
                      fontSize: 20 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.2175 * ffem / fem,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(double fem, double ffem) {
    return Container(
      margin: EdgeInsets.fromLTRB(17 * fem, 0, 18 * fem, 171 * fem),
      child: TextButton(
        onPressed: _handleLogout,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Container(
          padding: EdgeInsets.fromLTRB(16 * fem, 15 * fem, 13 * fem, 15 * fem),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0x3f000000),
                offset: Offset(0 * fem, 4 * fem),
                blurRadius: 2 * fem,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Log Out',
                  style: safeGoogleFont(
                    'Roboto',
                    fontSize: 20 * ffem,
                    fontWeight: FontWeight.w600,
                    height: 1.1725 * ffem / fem,
                    color: const Color(0xfff44236),
                  ),
                ),
              ),
              SizedBox(
                width: 27 * fem,
                height: 24 * fem,
                child: Image.asset(
                  'data/images/vector-9DD.png',
                  width: 27 * fem,
                  height: 24 * fem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getUserName() async {
    try {
      final DocumentSnapshot document = await _firestore
          .collection('user')
          .doc(_globalVM.username.value)
          .get();

      if (document.exists) {
        return document.get('name') as String?;
      } else {
        debugPrint("User document not found");
        return null;
      }
    } catch (e) {
      debugPrint("Failed to get user name: $e");
      return null;
    }
  }

  Future<void> _handleLogout() async {
    await _deleteUserId();
    Get.offAll(const LoginPage());
  }

  Future<void> _deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userid');
  }
}
