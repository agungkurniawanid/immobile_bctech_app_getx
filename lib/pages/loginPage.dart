import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:immobile/widget/text_field.dart';
import 'package:immobile/widget/button.dart';
import 'package:immobile/page/appBottomNavigation.dart';
import 'package:immobile/viewmodel/loginapi.dart';
import 'package:immobile/viewmodel/categoryvm.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/config/database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _username, _password;
  String token;
  LoginAPI loginService = LoginAPI();
  CategoryVM categoryvm = CategoryVM();
  final _usernameFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _firebaseMessaging.getToken().then((value) {
      token = value;
      print("Firebase Token: $token");
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<bool> check() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  void loginFunc() async {
    check().then((internet) async {
      if (internet) {
        EasyLoading.showProgress(0.0, status: 'Loading Login');
        loginService.signIn(
          email: _username.toLowerCase().trim(),
          password: _password.trim(),
          token: token,
        ).then((value) async {
          if (value == 'SUKSES') {
            // String userid = await DatabaseHelper.db.checkuserid();
            // await categoryvm.getcategory(userid, "");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AppBottomNavigation()),
            );
          } else {
            _showSnackbar(value == 'NO USER'
                ? 'No User, Please Contact Admin'
                : 'Login failed, check your email and password.');
          }
          EasyLoading.dismiss();
        });
      } else {
        _showSnackbar('Check your internet connection');
      }
    });
  }

  void _showSnackbar(String message) {
    final snackbar = SnackBar(content: Text(message), backgroundColor: Colors.red);
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF44236), Colors.white],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'data/images/logo_login.png', // Update path to your logo
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'POKPHAND',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002366),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Form Container
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'IM MOBILE',
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF44236),
                            ),
                          ),
                          SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFieldWidget(
                                  fieldKey: _usernameFieldKey,
                                  keyboardType: TextInputType.emailAddress,
                                  isPasswordField: false,
                                  prefixIcon: Icon(Icons.person),
                                  labelText: 'Username',
                                  validator: (input) => input.isEmpty ? 'Username cannot be empty' : null,
                                  onSaved: (input) => _username = input,
                                ),
                                SizedBox(height: 10),
                                TextFieldWidget(
                                  isPasswordField: true,
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: 'Password',
                                  validator: (input) => input.isEmpty ? 'Password cannot be empty' : null,
                                  onSaved: (input) => _password = input,
                                        fieldKey: _passwordFieldKey),
                                
                                SizedBox(height: 20),
                                BtnWidget(
                                  onPress: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      loginFunc();
                                    }
                                  },
                                  btnText: 'LOGIN',
                                  // Removed backgroundColor parameter
                                ),
                                SizedBox(height: 20),
                                Text(
                                  _packageInfo.version ?? '1.0.0',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
