import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/recent.dart';
import 'package:immobile/widget/recentsr.dart';
import 'package:immobile/page/loginpage.dart';
import 'package:immobile/page/outPage.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:immobile/viewmodel/webordervm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  int idPeriodSelected = 1;
  List<ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  WeborderVM weborderVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  GlobalKey srKey = GlobalKey();
    GlobalVM globalVM = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> deleteUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userid'); // Deletes the 'userid' key-value pair
}

  Future<String> getName() async {
  try {
    // Replace 'users' with your Firestore collection name
    // Replace 'USER_ID' with the user's unique ID or use FirebaseAuth to get the current user ID dynamically
    var document = await FirebaseFirestore.instance.collection('user').doc(globalVM.username.value).get();

    // Check if the document exists and fetch the name field
    if (document.exists) {
      return document.data()['name'];
    } else {
      print("User document not found");
      return null;
    }
  } catch (e) {
    print("Failed to get user name: $e");
    return null;
  }
}


  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: double.infinity,
                  child: Container(
                    // profilepagegsu (7:572)
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // autogroupas5hng3 (UM5k5JmDurFFAbChX4AS5h)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 24 * fem),
                          width: double.infinity,
                          height: 345 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // backrgroundredtDH (7:588)
                                left: 0 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 360 * fem,
                                    height: 260 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xfff44236),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // imageZqD (7:589)
                                left: 98 * fem,
                                top: 182 * fem,
                                child: Container(
                                  width: 163 * fem,
                                  height: 163 * fem,
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.circular(81.5 * fem),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        // imageframezvX (7:591)
                                        left: 7 * fem,
                                        top: 7 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 148 * fem,
                                            height: 148 * fem,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        74 * fem),
                                                color: Color(0xfff44236),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        // imageplaceholdertFD (7:592)
                                        left: 54 * fem,
                                        top: 51 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 55 * fem,
                                            height: 59 * fem,
                                            child: Text(
                                              globalVM.username.value[0].toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: SafeGoogleFont(
                                                'Montserrat',
                                                fontSize: 48 * ffem,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2175 * ffem / fem,
                                                color: Color(0xffffffff),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                // profileiEF (7:597)
                                left: 96 * fem,
                                top: 73 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 169 * fem,
                                    height: 49 * fem,
                                    child: FutureBuilder(
                                      future: getName(),
                                      builder: (context, name) {
                                        if (name.data == null) {
                                          return Text("");
                                        } else {
                                          return Text(
                                            'Profile \n${name.data}',
                                            textAlign: TextAlign.center,
                                            style: SafeGoogleFont(
                                              'Montserrat',
                                              fontSize: 20 * ffem,
                                              fontWeight: FontWeight.w600,
                                              height: 1.2175 * ffem / fem,
                                              color: Color(0xffffffff),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // logoutbuttonanF (7:593)
                          margin: EdgeInsets.fromLTRB(
                              17 * fem, 0 * fem, 18 * fem, 171 * fem),
                          child: TextButton(
                            onPressed: () async {
                              deleteUserId();
                              Get.offAll(LoginPage());
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  16 * fem, 15 * fem, 13 * fem, 15 * fem),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x3f000000),
                                    offset: Offset(0 * fem, 4 * fem),
                                    blurRadius: 2 * fem,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    // logouta9y (7:595)
                                    margin: EdgeInsets.fromLTRB(
                                        0 * fem, 0 * fem, 198 * fem, 0 * fem),
                                    child: Text(
                                      'Log Out',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 20 * ffem,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xfff44236),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // vectorUFM (7:596)
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
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
