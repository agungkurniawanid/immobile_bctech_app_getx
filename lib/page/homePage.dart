import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/recentsr.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:immobile/widget/outcard.dart';
import 'package:immobile/widget/recentin.dart';
import 'package:immobile/widget/card.dart';
import 'package:immobile/page/inpage.dart';
import 'package:immobile/page/outPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:immobile/page/indetailPage.dart';
import 'package:immobile/page/StockTakePage.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/itemchoicemodel.dart' as model;
import 'package:immobile/viewmodel/webordervm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:immobile/viewmodel/stockcheckvm.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/reportsvm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:immobile/page/outdetailPage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int idPeriodSelected = 1;
  List<model.ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  List<Category> listforin = [];
  WeborderVM weborderVM = Get.find();
  StockCheckVM stockcheckVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();
  GlobalVM globalVM = Get.find();
  InVM inVM = Get.find();
  ReportsVM reportsVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  GlobalKey srKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  RemoteConfig _remoteConfig;
  String name;

  @override
  void initState() {
    super.initState();

    getchoicechip();
    getName();
    // getnamehistory();
    _initPackageInfo();
    // _initializeRemoteConfig();
    // String welcomeMessage = _remoteConfig.getString('collectionsr');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        GlobalVar.newDataCount++;
        debugPrint('onMessage: $message');
        if (Platform.isAndroid) {
          EasyLoading.showInfo(
              message['data']['title'] + '\n' + message['data']['message'],
              duration: Duration(seconds: 3));
        } else if (Platform.isIOS) {
          EasyLoading.showInfo(message['title'] + '\n' + message['message'],
              duration: Duration(seconds: 3));
        }
        print('masukk notif');
        setState(() {
          // setVisibility();
          // GlobalVar.refreshBadgeData();
        });
      },
      onBackgroundMessage: Platform.isIOS ? null : onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch: $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true),
    );
  }

  // Future<void> _initializeRemoteConfig() async {
  //   try {
  //     _remoteConfig = await RemoteConfig.instance;
  //     await _fetchRemoteConfig();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activateFetched();
      setState(() {}); // Update the UI with the new values
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      String name = '';
      String doctype = '';
      String documentno = '';
      if (Platform.isIOS) {
        name = message['name'];
        doctype = message['doctype'];
        documentno = message['documentno'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        name = data['name'];
        doctype = data['doctype'];
        documentno = data['documentno'];
      }
      debugPrint('onBackgroundMessage: name: $name & $doctype $documentno');
    }
    return null;
  }

  void getnamehistory() async {
    var username2 = await DatabaseHelper.db.getUser();
    globalVM.username.value = username2;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      globalVM.version.value = _packageInfo.version;
    });
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

  // Future<String> getName() async {
  //   return await DatabaseHelper.db.getUser();
  // }

  void getchoicechip() async {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
      listforin = await DatabaseHelper.db.getCategorywithrole("IN");
      if (listforin.length != 0) {
        for (int i = 0; i < listforin.length; i++) {
          if (listforin[i].inventory_group_name == "Others") {
            listforin.removeWhere((element) =>
                element.inventory_group_id == listforin[i].inventory_group_id);
          }
          if (listcategory.any((element) =>
              element.inventory_group_id == listforin[i].inventory_group_id)) {
            listcategory.removeWhere((element) =>
                element.inventory_group_id == listforin[i].inventory_group_id);
            listcategory.add(listforin[i]);
          } else {
            listcategory.add(listforin[i]);
          }
        }
      }
      print(listcategory);
      setState(() {
        model.ItemChoice choiceforall;
        if (listcategory.length == 1) {
          model.ItemChoice choicelocal = model.ItemChoice(
              id: listchoice.length + 1,
              label: listcategory[0].inventory_group_id,
              labelname: listcategory[0].inventory_group_name);
          listchoice.add(choicelocal);
        } else {
          for (int i = 0; i < listcategory.length; i++) {
            if (listcategory[i].inventory_group_name == "All") {
              model.ItemChoice choicelocal = model.ItemChoice(
                  id: 10,
                  label: listcategory[i].inventory_group_id,
                  labelname: listcategory[i].inventory_group_name);
              choiceforall = choicelocal;
              // listchoice.add(choiceforall);
            } else {
              model.ItemChoice choicelocal = model.ItemChoice(
                  id: listchoice.length + 1,
                  label: listcategory[i].inventory_group_id,
                  labelname: listcategory[i].inventory_group_name);
              listchoice.add(choicelocal);
            }
          }
        }
        if (choiceforall == null) {
        } else {
          listchoice.add(choiceforall);
        }
        globalVM.choicecategory.value = listchoice[0].label;
        GlobalVar.choicecategory = listchoice[0].label;
        weborderVM.choiceWO.value = listchoice[0].label;
        stockrequestVM.choicesr.value = listchoice[0].label;
        // weborderVM.onReady();
        // stockcheckVM.onReady();
        if (listforin.length != 0) {
          inVM.onReady();
        }

        inVM.isLoading.value = false;
        if (listcategory.length != 0) {
          // var h1 = DateTime(DateTime.now().year, DateTime.now().month,
          //     DateTime.now().day - 1);
          // String h1string = DateFormat('yyyy-MM-dd').format(h1);
          // stockrequestVM.choicedate = h1string;
          stockrequestVM.onReady();
        }

        stockrequestVM.isLoading.value = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget modalBottomSheet() {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      // moreoverlayYGj (13:1001)
      // padding: EdgeInsets.fromLTRB(1 * fem, 6 * fem, 0 * fem, 199 * fem),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: GlobalVar.height * 0.50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * fem),
          topRight: Radius.circular(24 * fem),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // autogroupsqq3yN3 (UM7RQqug6wipjYJiH6SQQ3)
            width: double.infinity,
            height: 4 * fem,

            child: Stack(
              children: [
                Positioned(
                  // rectangle15EYs (13:1004)
                  left: 1 * fem,
                  top: 0 * fem,
                  child: Align(
                    child: SizedBox(
                      width: 42 * fem,
                      height: 4 * fem,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 * fem),
                          color: Color(0xffd9d9d9),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  // rectangle16VDu (13:1005)
                  left: 0 * fem,
                  top: 0 * fem,
                  child: Align(
                    child: SizedBox(
                      width: 42 * fem,
                      height: 4 * fem,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 * fem),
                          color: Color(0xffd9d9d9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // morePq5 (13:1003)
            margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 36 * fem),
            child: Text(
              'More',
              textAlign: TextAlign.center,
              style: SafeGoogleFont(
                'Roboto',
                fontSize: 20 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.1725 * ffem / fem,
                color: Color(0xff363636),
              ),
            ),
          ),
          Container(
            // featuresbuttonpfV (13:1133)
            margin: EdgeInsets.fromLTRB(37 * fem, 0 * fem, 0 * fem, 48 * fem),
            height: 68 * fem,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  // inbuttonjnT (I13:1133;4:405)
                  onPressed: () {
                    Get.to(InPage());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 6.97 * fem),
                    width: 68 * fem,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(5 * fem),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3f000000),
                          offset: Offset(0 * fem, 8 * fem),
                          blurRadius: 4 * fem,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // autogrouppjj9BeT (UM7SAjpCemwaR7U9nqpjj9)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 7.32 * fem),
                          padding: EdgeInsets.fromLTRB(
                              17.78 * fem, 3.14 * fem, 18.83 * fem, 4.18 * fem),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xffebebeb),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5 * fem),
                              topRight: Radius.circular(5 * fem),
                            ),
                          ),
                          child: Center(
                            // loginDr3 (I13:1133;4:409)
                            child: SizedBox(
                              width: 31.38 * fem,
                              height: 31.38 * fem,
                              child: Image.asset(
                                'data/images/login-qfZ.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // in7Rd (I13:1133;4:408)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 0 * fem),
                          child: Text(
                            'In',
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont(
                              'Roboto',
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.2175 * ffem / fem,
                              color: Color(0xff202020),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 40 * fem,
                ),
                TextButton(
                  // outbuttonXET (I13:1133;4:410)
                  onPressed: () {
                    Get.to(OutPage());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 6.97 * fem),
                    width: 68 * fem,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(5 * fem),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3f000000),
                          offset: Offset(0 * fem, 8 * fem),
                          blurRadius: 4 * fem,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // autogroup4dpxayR (UM7SLKNaHYh5ebBAxR4dpX)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 7.32 * fem),
                          padding: EdgeInsets.fromLTRB(
                              19 * fem, 3 * fem, 17.62 * fem, 4.33 * fem),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xffebebeb),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5 * fem),
                              topRight: Radius.circular(5 * fem),
                            ),
                          ),
                          child: Center(
                            // logoutroundedt2w (I13:1133;4:414)
                            child: SizedBox(
                              width: 31.38 * fem,
                              height: 31.38 * fem,
                              child: Image.asset(
                                'data/images/logout-rounded-GRH.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // outEW7 (I13:1133;4:413)
                          margin: EdgeInsets.fromLTRB(
                              1.05 * fem, 0 * fem, 0 * fem, 0 * fem),
                          child: Text(
                            'Out',
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont(
                              'Roboto',
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff363636),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20 * fem,
                ),
                Container(
                  // autogrouppgbm3M5 (UM7ReAroWNA3fbYuz9pGBM)
                  width: 116 * fem,
                  height: double.infinity,
                  child: TextButton(
                    // stockadjustmentbuttonjDu (I13:1133;4:415)
                    onPressed: () {
                      Get.to(StockTickPage());
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 3.29 * fem),
                      width: 68 * fem,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(5 * fem),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3f000000),
                            offset: Offset(0 * fem, 8 * fem),
                            blurRadius: 4 * fem,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            // autogroupgb3r4J7 (UM7RnVxFtFgJzt5YJZgB3R)
                            padding: EdgeInsets.fromLTRB(
                                19 * fem, 3 * fem, 17.62 * fem, 4.33 * fem),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xffebebeb),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5 * fem),
                                topRight: Radius.circular(5 * fem),
                              ),
                            ),
                            child: Center(
                              // adjustrzf (I13:1133;4:419)
                              child: SizedBox(
                                width: 31.38 * fem,
                                height: 31.38 * fem,
                                child: Image.asset(
                                  'data/images/adjust-ziP.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            // stockcheckHKH (I13:1133;4:418)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 1.05 * fem, 0 * fem),
                            constraints: BoxConstraints(
                              maxWidth: 31 * fem,
                            ),
                            child: Text(
                              'Stock\nTake',
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont(
                                'Roboto',
                                fontSize: 11 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xff363636),
                              ),
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
          Container(
            // line1i3D (13:1002)
            width: 360 * fem,
            height: 1 * fem,
            decoration: BoxDecoration(
              color: Color(0xffa8a8a8),
            ),
          ),
        ],
      ),
    );
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
                  width: GlobalVar.width,
                  child: Container(
                    // homepageambienttQb (4:387)
                    width: GlobalVar.width,
                    decoration: BoxDecoration(
                      color: Color(0xfff2f2f2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // autogroupe3cxP6T (UM5EELA8XLnYgkPL7HE3CX)
                          // margin: EdgeInsets.fromLTRB(
                          //     0 * fem, 0 * fem, 0 * fem, 6 * fem),
                          padding: EdgeInsets.fromLTRB(
                              14 * fem, 8 * fem, 14 * fem, 19 * fem),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                'data/images/background-red-dcw.png',
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // headerSKd (4:444)
                                margin: EdgeInsets.fromLTRB(
                                    3 * fem, 0 * fem, 3 * fem, 14 * fem),
                                padding: EdgeInsets.fromLTRB(
                                    16 * fem, 8 * fem, 7 * fem, 10 * fem),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(16 * fem),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      // autogrouprv4xtxK (UM5EUpjyuBqKvas6jxRV4X)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 11 * fem),
                                      width: double.infinity,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // goodmorningmrwarehouse1Aew (4:446)
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 89 * fem, 0 * fem),
                                            constraints: BoxConstraints(
                                              maxWidth: 169 * fem,
                                            ),
                                            child: FutureBuilder(
                                              future: getName(),
                                              builder: (context, name) {
                                                if (name.data == null) {
                                                  return Text("");
                                                } else {
                                                  return Text(
                                                    'Hello, \n${name.data}',
                                                    style: SafeGoogleFont(
                                                      'Montserrat',
                                                      fontSize: 20 * ffem,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height:
                                                          1.2175 * ffem / fem,
                                                      color: Color(0xff000000),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),

                                          // Expanded(
                                          //   child: Padding(
                                          //       padding: EdgeInsets.all(8),
                                          //       child: Container(
                                          //         // syncbuttonohu (4:449)
                                          //         width: 45 * fem,
                                          //         height: 25 * fem,
                                          //         child: Image.asset(
                                          //           'data/images/vector-xZ3.png',
                                          //           width: 45 * fem,
                                          //           height: 45 * fem,
                                          //         ),
                                          //       )),
                                          // ),
                                          // Expanded(
                                          //   child: Container(
                                          //     // syncbuttonohu (4:449)
                                          //     width: 45 * fem,
                                          //     height: 45 * fem,
                                          //     child: Image.asset(
                                          //       'data/images/sync-button.png',
                                          //       width: 45 * fem,
                                          //       height: 45 * fem,
                                          //     ),
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // autogroupfob17Th (UM5EcQMgiwpSv9tHkUFob1)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 7 * fem, 0 * fem),
                                      width: double.infinity,
                                      height: 15 * fem,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            // autogroupj8npnpj (UM5EjZpR8Qj9wfBM9GJ8NP)
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 47 * fem, 0 * fem),
                                            height: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  // appversion100AKV (4:448)
                                                  'App Version: ${_packageInfo.version}',
                                                  style: SafeGoogleFont(
                                                    'Roboto',
                                                    fontSize: 12 * ffem,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.1725 * ffem / fem,
                                                    color: Color(0xffa8a8a8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // TextButton(
                                          //   // circlenotificationssUo (7:759)
                                          //   onPressed: () {},
                                          //   style: TextButton.styleFrom(
                                          //     padding: EdgeInsets.zero,
                                          //   ),
                                          //   child: Container(
                                          //     width: 30 * fem,
                                          //     height: 30 * fem,
                                          //     child: Image.asset(
                                          //       'data/images/circle-notifications.png',
                                          //       width: 30 * fem,
                                          //       height: 30 * fem,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // featuresbuttonjX1 (4:452)
                                width: double.infinity,
                                height: 68 * fem,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // GestureDetector(
                                    //   onTap: () => Get.to(() => InPage()),
                                    //   child:
                                    TextButton(
                                      // inbutton3nb (I4:452;4:405)
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InPage()));
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 6.97 * fem),
                                        width: 68 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                              BorderRadius.circular(5 * fem),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f000000),
                                              offset: Offset(0 * fem, 8 * fem),
                                              blurRadius: 4 * fem,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // autogroupposq4Bu (UM5FFYxTHcCuYHUoV9Posq)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  7.32 * fem),
                                              padding: EdgeInsets.fromLTRB(
                                                  17.78 * fem,
                                                  3.14 * fem,
                                                  18.83 * fem,
                                                  4.18 * fem),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xffebebeb),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(5 * fem),
                                                  topRight:
                                                      Radius.circular(5 * fem),
                                                ),
                                              ),
                                              child: Center(
                                                // logintgj (I4:452;4:409)
                                                child: SizedBox(
                                                  width: 31.38 * fem,
                                                  height: 31.38 * fem,
                                                  child: Image.asset(
                                                    'data/images/login.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              // inBQw (I4:452;4:408)
                                              'In',
                                              textAlign: TextAlign.center,
                                              style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 12 * ffem,
                                                fontWeight: FontWeight.w600,
                                                height: 1.1725 * ffem / fem,
                                                color: Color(0xff363636),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ),
                                    SizedBox(
                                      width: 20 * fem,
                                    ),
                                    TextButton(
                                      // outbuttonsYf (I4:452;4:410)
                                      onPressed: () {
                                        Get.to(OutPage());
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 6.97 * fem),
                                        width: 68 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                              BorderRadius.circular(5 * fem),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f000000),
                                              offset: Offset(0 * fem, 8 * fem),
                                              blurRadius: 4 * fem,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // autogroup3hy7Wbd (UM5FT8TVjPio1fseon3HY7)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  7.32 * fem),
                                              padding: EdgeInsets.fromLTRB(
                                                  19 * fem,
                                                  3 * fem,
                                                  17.62 * fem,
                                                  4.33 * fem),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xffebebeb),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(5 * fem),
                                                  topRight:
                                                      Radius.circular(5 * fem),
                                                ),
                                              ),
                                              child: Center(
                                                // logoutroundedmGf (I4:452;4:414)
                                                child: SizedBox(
                                                  width: 31.38 * fem,
                                                  height: 31.38 * fem,
                                                  child: Image.asset(
                                                    'data/images/logout-rounded-Npj.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // outfsq (I4:452;4:413)
                                              margin: EdgeInsets.fromLTRB(
                                                  1.05 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem),
                                              child: Text(
                                                'Out',
                                                textAlign: TextAlign.center,
                                                style: SafeGoogleFont(
                                                  'Roboto',
                                                  fontSize: 12 * ffem,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.1725 * ffem / fem,
                                                  color: Color(0xff363636),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20 * fem,
                                    ),
                                    TextButton(
                                      // stockadjustmentbuttonYgj (I4:452;4:415)
                                      onPressed: () {
                                        Get.to(()=>StockTickPage());
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 3.29 * fem),
                                        width: 68 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                              BorderRadius.circular(5 * fem),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f000000),
                                              offset: Offset(0 * fem, 8 * fem),
                                              blurRadius: 4 * fem,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // autogroupjmy5nqy (UM5FdTVcvJ1Sas67HFJmy5)
                                              padding: EdgeInsets.fromLTRB(
                                                  19 * fem,
                                                  3 * fem,
                                                  17.62 * fem,
                                                  4.33 * fem),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xffebebeb),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(5 * fem),
                                                  topRight:
                                                      Radius.circular(5 * fem),
                                                ),
                                              ),
                                              child: Center(
                                                // adjustpXm (I4:452;4:419)
                                                child: SizedBox(
                                                  width: 31.38 * fem,
                                                  height: 31.38 * fem,
                                                  child: Image.asset(
                                                    'data/images/adjust.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // stockcheck8YT (I4:452;4:418)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  1.05 * fem,
                                                  0 * fem),
                                              constraints: BoxConstraints(
                                                maxWidth: 31 * fem,
                                              ),
                                              child: Text(
                                                'Stock\nTake',
                                                textAlign: TextAlign.center,
                                                style: SafeGoogleFont(
                                                  'Roboto',
                                                  fontSize: 11 * ffem,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.1725 * ffem / fem,
                                                  color: Color(0xff363636),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20 * fem,
                                    ),
                                    TextButton(
                                      // morebuttonNxb (I4:452;4:420)
                                      onPressed: () {
                                        return showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              modalBottomSheet(),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 8.02 * fem),
                                        width: 68 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xffffffff),
                                          borderRadius:
                                              BorderRadius.circular(5 * fem),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f000000),
                                              offset: Offset(0 * fem, 8 * fem),
                                              blurRadius: 4 * fem,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // autogroupk5tyBv3 (UM5FnhjDREJDSh1pkeK5Ty)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  6.28 * fem),
                                              padding: EdgeInsets.fromLTRB(
                                                  19 * fem,
                                                  3 * fem,
                                                  17.62 * fem,
                                                  4.33 * fem),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xffebebeb),
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(5 * fem),
                                                  topRight:
                                                      Radius.circular(5 * fem),
                                                ),
                                              ),
                                              child: Center(
                                                // viewmoredX9 (I4:452;4:424)
                                                child: SizedBox(
                                                  width: 31.38 * fem,
                                                  height: 31.38 * fem,
                                                  child: Image.asset(
                                                    'data/images/view-more-Zsy.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              // moreXsR (I4:452;4:423)
                                              margin: EdgeInsets.fromLTRB(
                                                  1.05 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem),
                                              child: Text(
                                                'More',
                                                textAlign: TextAlign.center,
                                                style: SafeGoogleFont(
                                                  'Roboto',
                                                  fontSize: 12 * ffem,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.1725 * ffem / fem,
                                                  color: Color(0xff363636),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // stockrequestcategory1nb (4:635)
                          // margin: EdgeInsets.fromLTRB(
                          //     18 * fem, 0 * fem, 18 * fem, 11 * fem),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // recentstockrequestfMM (I4:635;4:426)
                                // margin: EdgeInsets.fromLTRB(
                                //     0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                child: Text(
                                  'Recent Stock Request',
                                  style: SafeGoogleFont(
                                    'Montserrat',
                                    fontSize: 17 * ffem,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2175 * ffem / fem,
                                    color: Color(0xff202020),
                                  ),
                                ),
                              ),
                              _buildCategory(context)
                            ],
                          ),
                        ),
                        // inVM.isLoading.value == false ||
                        //         stockrequestVM.isLoading.value == false
                        //     ?
                        Container(
                          // weborderambientMTy (4:812)
                          // padding: EdgeInsets.fromLTRB(
                          //     7 * fem, 6 * fem, 0 * fem, 6 * fem),
                          width: GlobalVar.width,
                          height: GlobalVar.height * 0.20,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Container(
                              //   // webordercuh (4:814)
                              //   // margin: EdgeInsets.fromLTRB(
                              //   //     0 * fem, 0 * fem, 0 * fem, 6 * fem),
                              //   child: Text(
                              //     ' Stock Request',
                              //     style: SafeGoogleFont(
                              //       'Montserrat',
                              //       fontSize: 16 * ffem,
                              //       fontWeight: FontWeight.w400,
                              //       height: 1.2175 * ffem / fem,
                              //       color: Color(0xfff44236),
                              //     ),
                              //   ),
                              // ),

                              Container(
                                height: GlobalVar.height * 0.30,
                                width: GlobalVar.width,
                                child: Obx(() {
                                  print(stockrequestVM.tolistsrout.length);
                                  // var h1 = DateTime(
                                  //     DateTime.now().year,
                                  //     DateTime.now().month,
                                  //     DateTime.now().day - 1);
                                  // String h1string =
                                  //     DateFormat('yyyy-MM-dd').format(h1);
                                  // stockrequestVM.choicedate.value =
                                  //     h1string;
                                  // if (GlobalVar.choicecategory == "ALL") {
                                  //   stockrequestVM.tolistsrout.sort(
                                  //       (a, b) =>
                                  //           b.flag.compareTo(a.flag));
                                  // } else {
                                  //   stockrequestVM.tolistsrout.sort(
                                  //       (a, b) => b.delivery_date
                                  //           .compareTo(a.delivery_date));
                                  // }

                                  return GridView.builder(
                                      padding: const EdgeInsets.all(8),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1),
                                      itemCount: stockrequestVM
                                                  .tolistsrout.length <=
                                              10
                                          ? stockrequestVM.tolistsrout.length
                                          : 10,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: Container(
                                                key: index == 0 ? srKey : null,
                                                // height: Get.height * 0.24,
                                                child: Column(
                                                  children: [
                                                    RecentSR(
                                                      index: index,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          onTap: () async {
                                            Get.to(OutDetailPage(
                                                index,
                                                "SR",
                                                "outpage",
                                                stockrequestVM.tolistsrout
                                                    .value[index].documentno));
                                          },
                                        );
                                      });
                                }),
                              ),
                            ],
                          ),
                        ),
                        // :
                        // Shimmer.fromColors(
                        //     baseColor: Colors.grey[500],
                        //     highlightColor: Colors.white12,
                        //     period: Duration(milliseconds: 1500),
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Padding(
                        //         padding: EdgeInsets.only(bottom: 5),
                        //         child: CardWidget(
                        //           text: '',
                        //           icon: Icons.tag,
                        //           height: Get.height * 0.5,
                        //         ),
                        //       ),
                        //     ),
                        //   ),

                        Container(
                          // autogroupmqfmFF1 (UM5FusBwphCvUCJt9SMQFM)
                          width: GlobalVar.width,
                          height: GlobalVar.height * 0.30+10,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                          ),
                          child: Container(
                            width: GlobalVar.width,
                            height: GlobalVar.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Container(
                                //   // weborderambientMTy (4:812)
                                //   // padding: EdgeInsets.fromLTRB(
                                //   //     7 * fem, 6 * fem, 0 * fem, 6 * fem),
                                //   width: GlobalVar.width,
                                //   decoration: BoxDecoration(
                                //     color: Color(0xffffffff),
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.center,
                                //     children: [
                                //       // Container(
                                //       //   // recentstockrequestfMM (I4:635;4:426)
                                //       //   margin: EdgeInsets.fromLTRB(
                                //       //       0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                //       //   child: Text(
                                //       //     'IN',
                                //       //     style: SafeGoogleFont(
                                //       //       'Montserrat',
                                //       //       fontSize: 18 * ffem,
                                //       //       fontWeight: FontWeight.w600,
                                //       //       height: 1.2175 * ffem / fem,
                                //       //       color: Color(0xff202020),
                                //       //     ),
                                //       //   ),
                                //       // ),

                                //       // // Container(
                                //       //   // webordercuh (4:814)
                                //       //   // margin: EdgeInsets.fromLTRB(0 * fem,
                                //       //   //     0 * fem, 0 * fem, 6 * fem),
                                //       //   child: Text(
                                //       //     ' WebOrder',
                                //       //     style: SafeGoogleFont(
                                //       //       'Montserrat',
                                //       //       fontSize: 16 * ffem,
                                //       //       fontWeight: FontWeight.w400,
                                //       //       height: 1.2175 * ffem / fem,
                                //       //       color: Color(0xfff44236),
                                //       //     ),
                                //       //   ),
                                //       // ),
                                //     ],
                                //   ),
                                // ),
                                Container(
                                    child: Align(
                                  child: Text(
                                    ' Recent Purchase Order',
                                    style: SafeGoogleFont(
                                      'Montserrat',
                                      fontSize: 16 * ffem,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2175 * ffem / fem,
                                      color: Color(0xff202020),
                                    ),
                                  ),
                                )),
                                Container(
                                  height: GlobalVar.height * 0.30,
                                  width: GlobalVar.width,
                                  child: Obx(() {
                                    // inVM.tolistPO.sort((a, b) =>
                                    //     b.aedat.compareTo(a.aedat));
                                    return GridView.builder(
                                        padding: const EdgeInsets.all(8),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1),
                                        itemCount: inVM.tolistPO.length <= 10
                                            ? inVM.tolistPO.length
                                            : 10,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 5),
                                              child: Container(
                                                  key:
                                                      index == 0 ? p4Key : null,
                                                  // height: Get.height * 0.24,
                                                  child: Column(
                                                    children: [
                                                      RecentIn(index: index)
                                                    ],
                                                  )),
                                            ),
                                            onTap: () async {
                                              Get.to(InDetailPage(
                                                  index, "home", null));
                                            },
                                          );
                                        });
                                  }),
                                ),

                                // Container(
                                //   height: GlobalVar.height * 0.30,
                                //   width: GlobalVar.width,
                                //   child: Obx(() {
                                //     return GridView.builder(
                                //         padding: const EdgeInsets.all(8),
                                //         scrollDirection: Axis.horizontal,
                                //         shrinkWrap: true,
                                //         gridDelegate:
                                //             SliverGridDelegateWithFixedCrossAxisCount(
                                //                 crossAxisCount: 1),
                                //         itemCount:
                                //             weborderVM.tolistwoout.length <= 10
                                //                 ? weborderVM.tolistwoout.length
                                //                 : 10,
                                //         itemBuilder:
                                //             (BuildContext context, int index) {
                                //           return GestureDetector(
                                //             child: Padding(
                                //               padding:
                                //                   EdgeInsets.only(bottom: 5),
                                //               child: Container(
                                //                   key:
                                //                       index == 0 ? p4Key : null,
                                //                   // height: Get.height * 0.24,
                                //                   child: Column(
                                //                     children: [
                                //                       RecentWidget(index: index)
                                //                     ],
                                //                   )),
                                //             ),
                                //             onTap: () async {
                                //               Get.to(
                                //                   OutDetailPage(index, "WO"));
                                //             },
                                //           );
                                //         });
                                //   }),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  Widget _buildCategory(BuildContext context) {
    return Container(
      // width: 500,
      child: Wrap(
        children: listchoice
            .map((e) => ChoiceChip(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  labelStyle:
                      (Theme.of(context).backgroundColor == Colors.grey[100]
                          ? (idPeriodSelected == e.id
                              ? TextStyle(color: Colors.white)
                              : TextStyle(color: Colors.white))
                          : (idPeriodSelected == e.id
                              ? TextStyle(color: Colors.white)
                              : TextStyle(color: Colors.white))),
                  backgroundColor:
                      Theme.of(context).backgroundColor == Colors.grey[100]
                          ? Colors.grey
                          : Colors.grey,
                  label: Text(
                    e.labelname,
                  ),
                  selected: idPeriodSelected == e.id,
                  onSelected: (_) {
                    try {
                      setState(() {
                        // stockrequestVM.onClose();

                        idPeriodSelected = e.id;
                        if (e.id == 10) {
                          GlobalVar.choicecategory = "ALL";
                          globalVM.choicecategory.value = "ALL";
                        } else {
                          int choice = idPeriodSelected - 1;
                          GlobalVar.choicecategory = listchoice[choice].label;
                          globalVM.choicecategory.value =
                              listchoice[choice].label;
                        }
                        // globalVM.choicecategory.value =
                        //     GlobalVar.choicecategory;

                        stockrequestVM.choicesr.value =
                            globalVM.choicecategory.value;
                        // weborderVM.choiceWO.value = GlobalVar.choicecategory;
                        stockrequestVM.tolistsrout.value = stockrequestVM
                            .tolistsrbackup
                            .where((element) => element.inventory_group
                                .contains(GlobalVar.choicecategory))
                            .toList();

                        // stockrequestVM.isClosed;
                        if (listcategory.length != 0) {
                          // var h1 = DateTime(DateTime.now().year,
                          //     DateTime.now().month, DateTime.now().day - 1);
                          // String h1string = DateFormat('yyyy-MM-dd').format(h1);
                          // stockrequestVM.choicedate = h1string;
                          stockrequestVM.onReady();
                        }

                        stockrequestVM.isLoading.value = false;
                        inVM.isLoading.value = false;
                        // if (GlobalVar.choicecategory == "ALL") {
                        //   inVM.onRecent();
                        // } else {
                        if (listforin.length != 0) {
                          inVM.onReady();
                        }

                        // }
                      });
                      // changeSelectedId('Period', e.id);

                    } catch (e) {
                      print(e);
                    }
                  },
                  selectedColor:
                      Theme.of(context).backgroundColor == Colors.grey[100]
                          ? Colors.white
                          : globalVM.choicecategory.value == "FZ"
                              ? Colors.blue
                              : globalVM.choicecategory.value == "CH"
                                  ? Colors.green
                                  : globalVM.choicecategory.value == "ALL"
                                      ? Colors.orange
                                      : Color(0xfff44236),
                  elevation: 10,
                ))
            .toList(),
        spacing: 10,
      ),
    );
  }
}
