import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/model/account.dart';
import 'package:immobile/model/role.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/rolevm.dart';
import 'package:get/get.dart';

class LoginAPI {
  Config config = Config();
    GlobalVM globalVM = Get.find();
Rolevm roleVM = Get.find();
  Future<dynamic> signIn({String email, String password, String token}) async {
    try {
      RequestWorkflow data = RequestWorkflow();
print(token);
      data.email = email;
      data.password = password;
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse('https://cpma.cp.co.id:3011/api/login'))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonLogin(data)));
      //print(toJsonInsertTrip(data));
      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();

      switch (response.statusCode) {
        case 200:
          var jsonData = Account.fromJson(jsonDecode(reply));
          // print(jsonDecode(response.body));
          if (jsonData.status == 1) {
            return 'GAGAL';
          } else {
            await saveuser(jsonData);
            roleVM.listrole().listen((roles) {
            // Handle roles data here or in the UI with StreamBuilder
            print("Roles data updated: $roles");
          });
            // await DatabaseHelper.db.openDb();
            // await DatabaseHelper.db.loginUser(jsonData, "true");
            // bool user = await fetchUserId(jsonData, token);
            // if (user) {
            //   GlobalVar.email = email;
            // } else {
            //   return 'NO USER';
            // }
          }
          return 'SUKSES';
        case 400:
          return 'Koneksi error';
        case 401:
          return 'NO USER';
        case 403:
          return 'Koneksi error';
        case 500:
        default:
          return 'Koneksi error';
      }
    } on TimeoutException catch (e) {
      print(e);
      return 'Koneksi error';
    } catch (e) {
      print(e);
      return 'Koneksi error';
    }
  }

  Future<void> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userid', userId);
}
   saveuser(Account data) async {
    try {
       await saveUserId(data.userid);
      globalVM.username.value = data.userid;
      await FirebaseFirestore.instance
          .collection('user')
          .doc(data.userid)
          .set({
            'userid': data.userid,
            'email': data.email,
            'name': data.name,
            'status': data.status
          })
          // return test;
          .then((result) => {print("Sukses")})
          .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }
}
