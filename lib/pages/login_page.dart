import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:immobile_app_fixed/pages/app_bottom_navigation_page.dart';
import 'package:immobile_app_fixed/view_models/category_view_model.dart';
import 'package:immobile_app_fixed/view_models/login_api_view_model.dart';
import 'package:immobile_app_fixed/widgets/button_widget.dart';
import 'package:immobile_app_fixed/widgets/text_field_widget.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _username, _password;
  String? token;
  final LoginAPI loginService = LoginAPI();
  final CategoryVM categoryvm = CategoryVM();
  final _usernameFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
    _getFirebaseToken();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _getFirebaseToken() async {
    try {
      token = await _firebaseMessaging.getToken();
      Logger().e("Firebase Token: $token");
    } catch (e) {
      Logger().e("Error getting Firebase token: $e");
    }
  }

  Future<bool> checkConnectivity() async {
    return true;
  }

  void loginFunc() async {
    final hasConnection = await checkConnectivity();

    if (!hasConnection) {
      _showSnackbar('Check your internet connection');
      return;
    }

    try {
      EasyLoading.showProgress(0.0, status: 'Loading Login');

      final result = await loginService.signIn(
        email: _username?.toLowerCase().trim() ?? '',
        password: _password?.trim() ?? '',
        token: token ?? '',
      );

      if (result == 'SUKSES') {
        // String userid = await DatabaseHelper.db.checkuserid();
        // await categoryvm.getcategory(userid, "");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppBottomNavigation()),
        );
      } else {
        _showSnackbar(
          result == 'NO USER'
              ? 'No User, Please Contact Admin'
              : 'Login failed, check your email and password.',
        );
      }
    } catch (e) {
      _showSnackbar('An error occurred during login');
      Logger().e('Login error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            decoration: const BoxDecoration(
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
                    const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage('data/images/logo_login.png'),
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
                    const SizedBox(height: 20),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
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
                              color: const Color(0xFFF44236),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFieldWidget(
                                  fieldKey: _usernameFieldKey,
                                  keyboardType: TextInputType.emailAddress,
                                  isPasswordField: false,
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: 'Username',
                                  validator: (input) => input?.isEmpty == true
                                      ? 'Username cannot be empty'
                                      : null,
                                  onSaved: (input) => _username = input,
                                ),
                                const SizedBox(height: 10),
                                TextFieldWidget(
                                  fieldKey: _passwordFieldKey,
                                  isPasswordField: true,
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Password',
                                  validator: (input) => input?.isEmpty == true
                                      ? 'Password cannot be empty'
                                      : null,
                                  onSaved: (input) => _password = input,
                                ),
                                const SizedBox(height: 20),
                                BtnWidget(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ==
                                        true) {
                                      _formKey.currentState?.save();
                                      loginFunc();
                                    }
                                  },
                                  buttonText: 'LOGIN',
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _packageInfo.version,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
