import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:immobile/config/config.dart';
import 'package:immobile/model/stockcheck.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:immobile/config/database.dart';
import 'package:xml2json/xml2json.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PidVM extends GetxController {
  Config config = Config();
  var tolistforscan = List<StockModel>().obs;
  var tolistpid = List<StockModel>().obs;
  var toliststockhistory = List<StockModel>().obs;
  var stockhistory = List<StockModel>().obs;

  Rx<List<StockModel>> stocklist = Rx<List<StockModel>>([]);
  List<StockModel> StockModellocal = [];
  List<StockModel> StockModellocalout = [];
  List<StockModel> stockforhistory = [];

  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var choicesr = "".obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var isSearch = true.obs;
  var isIconSearchint = 0.obs;
  var isIconSearch = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  String username;
  var countedstring = "".obs;

  @override
  void onReady() async {
    username = await DatabaseHelper.db.getUser();
    stocklist.bindStream(listPID());
  }

  Stream<List<StockModel>> listPID() {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      return FirebaseFirestore.instance
          .collection('PID')
          // .doc(today)
          // .collection('header')
          .snapshots()
          .map((QuerySnapshot query) {
        StockModellocal = [];
        StockModellocalout = [];
        stockforhistory = [];
        tolistforscan.value = [];
        tolistpid.value = [];
        toliststockhistory.value = [];
        for (var stock in query.docs) {
          final returnstock =
              StockModel.fromDocumentSnapshot(documentSnapshot: stock);

          if (returnstock.isapprove == "Counted") {
            StockModellocal.add(returnstock);
          } else {
            StockModellocalout.add(returnstock);
          }

          // if(returnstock.detail.where((element) => element.approvename == username).toList().length > 0){
          //   stockfor
          // }

          // tolistSPPA.removeWhere((element) =>
          //     element.documentnosppa == sppa.data()['documentnosppa']);

        }
        for (int i = 0; i < StockModellocal.length; i++) {
          StockModellocalout.add(StockModellocal[i]);
        }

        for (var stock in StockModellocalout) {
          stock.detail.sort((a, b) => b.stock_total.compareTo(a.stock_total));
        }
        StockModellocalout.sort((a, b) => b.updated_at.compareTo(a.updated_at));
        // tolistforscan.assignAll(StockModellocal);
        tolistpid.assignAll(StockModellocalout);
        isLoading.value = false;
        return tolistpid;
      });
    } catch (e) {
      print(e);
    }
  }

  sendtohistory(StockModel stockModel, List<Map<String, dynamic>> tdata) async {
    try {
      var today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      String todayString = DateFormat('yyyy-MM-dd').format(today);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(username)
          .collection(todayString)
          .doc(stockModel.recordid)
          .set({
        'recordid': stockModel.recordid,
        'color': stockModel.color,
        'created': stockModel.created,
        'createdby': stockModel.createdby,
        'orgid': stockModel.orgid,
        'updated': formattedDate,
        'updatedby': stockModel.updatedby,
        'location': stockModel.location,
        'formatted_updated_at': stockModel.formatted_updated_at,
        'isapprove': stockModel.isapprove,
        'location_name': stockModel.location_name,
        'updated_at': stockModel.updated_at,
        'clientid': stockModel.clientid,
        'sync': stockModel.issync,
        'doctype': stockModel.doctype,
        'detail': tdata,
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

  dynamic refreshstock(StockModel stockmodel) async {
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = stockmodel.location;

      EasyLoading.showProgress(0.3,
          status: 'Call WS', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('getrefreshpid')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonRefreshStock(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      EasyLoading.showProgress(0.5,
          status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          EasyLoading.dismiss();
          if (reply.isNotEmpty) {
          } else {
            return false;
          }
          return true;
        case 400:
          return "Approval Gagal Error 400";
        case 401:
          return "Approval Gagal Error 401";
        case 403:
          return "Approval Gagal Error 403";
        case 504:
          return "Approval Gagal Error 504";
        case 500:
          return "Approval Gagal Error 500";
        default:
          return "Approval Gagal";
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      EasyLoading.dismiss();
      print(e);
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      return false;
    }
  }

  approveall(StockModel stockModel, String flag,
      List<Map<String, dynamic>> tdata) async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await FirebaseFirestore.instance
          .collection('PID')
          // .doc(today)
          // .collection('header')
          .doc(stockModel.recordid)
          .set({
            'recordid': stockModel.recordid,
            'color': stockModel.color,
            'created': stockModel.created,
            'createdby': stockModel.createdby,
            'orgid': stockModel.orgid,
            'updated': today,
            'updatedby': stockModel.updatedby,
            'location': stockModel.location,
            'formatted_updated_at': stockModel.formatted_updated_at,
            'isapprove': stockModel.isapprove,
            'location_name': stockModel.location_name,
            'updated_at': stockModel.updated_at,
            'clientid': stockModel.clientid,
            'sync': stockModel.issync,
            'doctype': stockModel.doctype,
            'detail': tdata,
          })
          // return test;
          .then((result) => {print("Sukses")})
          .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

  // void counted() async {
  //   String year = DateFormat('yyyy').format(DateTime.now()) + "-";
  //   DocumentSnapshot query = await FirebaseFirestore.instance
  //       .collection('COUNTED') // Replace with your collection name
  //       .doc(year) // Replace with your document ID
  //       .get();

  //   if (query.exists) {
  //     Map<String, dynamic> data = query.data();
  //     // Access the data fields from the document
  //     // For example:
  //     String documentno = data['documentno'];
  //     int documentint =
  //         int.parse(documentno.substring(5, documentno.length)) + 1;
  //     String convertdocument = year + documentint.toString();
  //     countedstring.value = convertdocument;
  //     // return  countedstring.value;
  //     // Rest of your code...

  //     // return countedstring
  //     // .value; // Return a value in the case where the document exists
  //   } else {
  //     String documentno = year + "100000001";
  //     countedstring.value = documentno;

  //     // Document does not exist
  //     // Handle the case accordingly

  //     // return countedstring
  //     // .value; // Return a value in the case where the document does not exist
  //   }
  //   // return  countedstring.value;
  // }

  Future<String> counted() async {
    String year = DateFormat('yyyy').format(DateTime.now()) + "-";
    DocumentSnapshot query = await FirebaseFirestore.instance
        .collection('COUNTED') // Replace with your collection name
        .doc(year) // Replace with your document ID
        .get();

    if (query.exists) {
      Map<String, dynamic> data = query.data();
      // Access the data fields from the document
      // For example:
      String documentno = data['documentno'];
      if (documentno == "") {
        String documentno = year + "100000001";
        countedstring.value = documentno;
        return countedstring.value;
      } else {
        int documentint =
            int.parse(documentno.substring(5, documentno.length)) + 1;
        String convertdocument = year + documentint.toString();
        countedstring.value = convertdocument;
        return countedstring.value;
      }
      // int documentint =
      //     int.parse(documentno.substring(5, documentno.length)) + 1;
      // String convertdocument = year + documentint.toString();
      // countedstring.value = convertdocument;
      // return countedstring.value;
    } else {
      String documentno = year + "100000001";
      countedstring.value = documentno;
      return countedstring.value;
    }
  }

  sendcounted(String documentno) async {
    try {
      String year = DateFormat('yyyy').format(DateTime.now()) + "-";

      await FirebaseFirestore.instance
          .collection('COUNTED')
          .doc(year)
          .set({
            'documentno': documentno,
          })
          // return test;
          .then((result) => {print("Sukses")})
          .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

  approvestock(StockModel stockModel, List<Map<String, dynamic>> tdata) async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await FirebaseFirestore.instance
          .collection('PID')
          // .doc(today)
          // .collection('header')
          .doc(stockModel.recordid)
          .set({
            'recordid': stockModel.recordid,
            'color': stockModel.color,
            'created': stockModel.created,
            'createdby': stockModel.createdby,
            'orgid': stockModel.orgid,
            'updated': today,
            'updatedby': stockModel.updatedby,
            'location': stockModel.location,
            'formatted_updated_at': stockModel.formatted_updated_at,
            'isapprove': stockModel.isapprove,
            'location_name': stockModel.location_name,
            'updated_at': stockModel.updated_at,
            'clientid': stockModel.clientid,
            'sync': stockModel.issync,
            'doctype': stockModel.doctype,
            'detail': tdata,
          })
          // return test;
          .then((result) => {print("Sukses")})
          .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

  dateToString(String date) {
    final format = DateFormat('dd-MM-yyyy');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }
}
