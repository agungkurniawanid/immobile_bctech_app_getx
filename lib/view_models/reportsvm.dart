import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/model/stockcheck.dart';
import 'package:immobile/model/reportsmodel.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xml2json/xml2json.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/model/category.dart';
import 'package:async/async.dart';

class ReportsVM extends GetxController {
  Config config = Config();
  var tolisthistory = List<ReportsModel>().obs;
  var tolisthistoryin = List<ReportsModel>().obs;
  var tolisthistoryout = List<ReportsModel>().obs;
  var tolisthistorysc = List<ReportsModel>().obs;
  var tolisthistoryfortotal = List<ReportsModel>().obs;

  Rx<List<ReportsModel>> stocklist = Rx<List<ReportsModel>>([]);
  GlobalVM globalvm = Get.find();
  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var choicedate = "".obs;
  var choice = "".obs;
  var choicechip = "".obs;
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
  List<Category> listcategory = [];

  // @override
  // void onReady() {
  //   stocklist.bindStream(history());
  // }

  @override
  void onReady() {
    stocklist.bindStream(reports());
  }

  Stream<List<ReportsModel>> reports() {
    if (choice.value == "OT") {
      return FirebaseFirestore.instance
          .collection('HISTORY')
          .doc("AB")
          .collection(choicedate.value)
          .snapshots()
          .asyncMap((QuerySnapshot query) async {
        Set<String> uniqueKeys = Set(); // To store unique keys
        List<ReportsModel> result = [];

        // tolisthistoryout.clear();

        for (var doc in query.docs) {
          String doctype = doc.data()['doctype'];
          String key = doc.data()['documentno']; // Unique identifier field

          // Check if this key has already been added
          // if (!uniqueKeys.contains(key)) {
          //   uniqueKeys.add(key);

          ReportsModel ReportsModellocal;

          if (doctype == "IN") {
            ReportsModellocal =
                ReportsModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
            if (ReportsModellocal.T_DATA
                .any((element) => element.maktx.contains("Pallet"))) {
              result.add(ReportsModellocal);
            }
          }
        }
        QuerySnapshot query2 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("CH")
            .collection(choicedate.value)
            .get();

        // int calculate = 0;
        if (query2.docs.isNotEmpty) {
          for (var doc in query2.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
              if (ReportsModellocal.T_DATA
                  .any((element) => element.maktx.contains("Pallet"))) {
                result.add(ReportsModellocal);
              }
              // if (result
              //     .any((element) => element.ebeln == ReportsModellocal.ebeln)) {
              //   // if (calculate == 1) {
              //   //   calculate = calculate + 1;
              //   result.removeWhere(
              //       (element) => element.ebeln == ReportsModellocal.ebeln);
              //   // }

              //   ReportsModellocal.flag = "Y";
              //   result.add(ReportsModellocal);
              // }
            }
          }
        }

        QuerySnapshot query3 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("FZ")
            .collection(choicedate.value)
            .get();
        // int calculate = 0;
        if (query3.docs.isNotEmpty) {
          for (var doc in query3.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
              if (ReportsModellocal.T_DATA
                  .any((element) => element.maktx.contains("Pallet"))) {
                result.add(ReportsModellocal);
              }
            }
          }
        }

        // }

        // Now, fetch data from the 'ALL' collection
        QuerySnapshot query4 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("ALL")
            .collection(choicedate.value)
            .get();
        int calculate = 0;
        if (query4.docs.isNotEmpty) {
          for (var doc in query4.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
              if (result
                  .any((element) => element.ebeln == ReportsModellocal.ebeln)) {
                // if (calculate == 1) {
                //   calculate = calculate + 1;
                result.removeWhere((element) =>
                    element.ebeln == ReportsModellocal.ebeln &&
                    element.mblnr == null);
                // }

                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              }
            }
            // else if (doctype == "SR") {
            //   ReportsModellocal =
            //       ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            //   if (result.any((element) =>
            //       element.documentno == ReportsModellocal.documentno)) {
            //     result.removeWhere((element) =>
            //         element.documentno == ReportsModellocal.documentno);
            //     ReportsModellocal.flag = "Y";
            //     result.add(ReportsModellocal);
            //   }
            // } else {
            //   ReportsModellocal =
            //       ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            //   if (result.any((element) =>
            //       element.documentno == ReportsModellocal.documentno)) {
            //     result.removeWhere((element) =>
            //         element.documentno == ReportsModellocal.documentno);
            //     ReportsModellocal.flag = "Y";
            //     result.add(ReportsModellocal);
            //   }
            // }

            // if (ReportsModellocal.isapprove == "Y") {
            //   result.add(ReportsModellocal);
            // } else {
            //   result.add(ReportsModellocal);
            // }
          }
        }

        // result.removeWhere((element) => element.doctype == "SR");
        // result.removeWhere((element) => element.T_DATA
        //     .every((subElement) => !subElement.maktx.contains("Pallet")));
        // Other processing logic...
        tolisthistory.assignAll(result);
        isLoading.value = false;
        return result;
      });
    } else if (choice.value == "ALL") {
      return FirebaseFirestore.instance
          .collection('HISTORY')
          .doc("AB")
          .collection(choicedate.value)
          .snapshots()
          .asyncMap((QuerySnapshot query) async {
        Set<String> uniqueKeys = Set(); // To store unique keys
        List<ReportsModel> result = [];

        for (var doc in query.docs) {
          String doctype = doc.data()['doctype'];
          String key = doc.data()['documentno']; // Unique identifier field

          // Check if this key has already been added
          // if (!uniqueKeys.contains(key)) {
          //   uniqueKeys.add(key);

          ReportsModel ReportsModellocal;

          if (doctype == "IN") {
            ReportsModellocal =
                ReportsModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
          } else if (doctype == "SR") {
            ReportsModellocal =
                ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
          } else {
            ReportsModellocal =
                ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
          }

          if (ReportsModellocal.isapprove == "Y") {
            result.add(ReportsModellocal);
          } else {
            result.add(ReportsModellocal);
          }
        }
        QuerySnapshot query2 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("CH")
            .collection(choicedate.value)
            .get();

        // int calculate = 0;
        if (query2.docs.isNotEmpty) {
          for (var doc in query2.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
            } else if (doctype == "SR") {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            } else {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            }

            if (ReportsModellocal.isapprove == "Y") {
              result.add(ReportsModellocal);
            } else {
              result.add(ReportsModellocal);
            }
          }
        }

        QuerySnapshot query3 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("FZ")
            .collection(choicedate.value)
            .get();
        // int calculate = 0;
        if (query3.docs.isNotEmpty) {
          for (var doc in query3.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
            } else if (doctype == "SR") {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            } else {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            }

            if (ReportsModellocal.isapprove == "Y") {
              result.add(ReportsModellocal);
            } else {
              result.add(ReportsModellocal);
            }
          }
        }

        // }

        // Now, fetch data from the 'ALL' collection
        QuerySnapshot query4 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("ALL")
            .collection(choicedate.value)
            .get();
        int calculate = 0;
        if (query4.docs.isNotEmpty) {
          for (var doc in query4.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
              if (result
                  .any((element) => element.ebeln == ReportsModellocal.ebeln)) {
                if (calculate == 1) {
                  calculate = calculate + 1;
                  result.removeWhere(
                      (element) => element.ebeln == ReportsModellocal.ebeln);
                }

                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              }
            } else if (doctype == "SR") {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
              if (result.any((element) =>
                  element.documentno == ReportsModellocal.documentno)) {
                // if (calculate == 0) {
                //   calculate = calculate + 1;
                // result.removeWhere((element) =>
                //     element.documentno == ReportsModellocal.documentno &&
                //     element.mblnr == null);
                // }

                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              } else {
                // for (int i = 0; i < listcategory.length; i++) {
                if (ReportsModellocal.detail
                    .any((element) => element.inventory_group == "AB")) {
                  result.removeWhere((element) =>
                      element.documentno == ReportsModellocal.documentno);
                  ReportsModellocal.flag = "Y";
                  result.add(ReportsModellocal);
                } else if (ReportsModellocal.detail
                    .any((element) => element.inventory_group == "AB")) {
                  result.removeWhere((element) =>
                      element.documentno == ReportsModellocal.documentno);
                  ReportsModellocal.flag = "Y";
                  result.add(ReportsModellocal);
                } else if (ReportsModellocal.detail
                    .any((element) => element.inventory_group == "FZ")) {
                  result.removeWhere((element) =>
                      element.documentno == ReportsModellocal.documentno);
                  ReportsModellocal.flag = "Y";
                  result.add(ReportsModellocal);
                }
                // }
                // ;
              }
            } else {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
              if (result.any((element) =>
                  element.documentno == ReportsModellocal.documentno)) {
                // result.removeWhere((element) =>
                //     element.documentno == ReportsModellocal.documentno);
                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              }
            }
            // else if (doctype == "SR") {
            //   ReportsModellocal =
            //       ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            //   if (result.any((element) =>
            //       element.documentno == ReportsModellocal.documentno)) {
            //     result.removeWhere((element) =>
            //         element.documentno == ReportsModellocal.documentno);
            //     ReportsModellocal.flag = "Y";
            //     result.add(ReportsModellocal);
            //   }
            // } else {
            //   ReportsModellocal =
            //       ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            //   if (result.any((element) =>
            //       element.documentno == ReportsModellocal.documentno)) {
            //     result.removeWhere((element) =>
            //         element.documentno == ReportsModellocal.documentno);
            //     ReportsModellocal.flag = "Y";
            //     result.add(ReportsModellocal);
            //   }
            // }

            // if (ReportsModellocal.isapprove == "Y") {
            //   result.add(ReportsModellocal);
            // } else {
            //   result.add(ReportsModellocal);
            // }
          }
        }

        // result.removeWhere((element) => element.doctype == "SR");
        // result.removeWhere((element) => element.T_DATA
        //     .every((subElement) => !subElement.maktx.contains("Pallet")));
        // Other processing logic...
        tolisthistory.assignAll(result);
        isLoading.value = false;
        return result;
      });
    } else {
      return FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(choice.value)
          .collection(choicedate.value)
          .snapshots()
          .asyncMap((QuerySnapshot query) async {
        Set<String> uniqueKeys = Set(); // To store unique keys
        List<ReportsModel> result = [];
        List<ReportsModel> result2 = [];
        if (query.docs.isNotEmpty) {
          for (var doc in query.docs) {
            String doctype = doc.data()['doctype'];
            String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added
            // if (!uniqueKeys.contains(key)) {
            //   uniqueKeys.add(key);

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
            } else if (doctype == "SR") {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            } else {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            }

            if (ReportsModellocal.isapprove == "Y") {
              result.add(ReportsModellocal);
            } else {
              result.add(ReportsModellocal);
            }
          }
        }

        // }

        // Now, fetch data from the 'ALL' collection
        QuerySnapshot query2 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc("ALL")
            .collection(choicedate.value)
            .get();
        int calculate = 0;
        if (query2.docs.isNotEmpty) {
          for (var doc in query2.docs) {
            String doctype = doc.data()['doctype'];
            // String key = doc.data()['documentno']; // Unique identifier field

            // Check if this key has already been added

            ReportsModel ReportsModellocal;

            if (doctype == "IN") {
              ReportsModellocal = ReportsModel.fromDocumentSnapshotInModel(
                  documentSnapshot: doc);
              if (result
                  .any((element) => element.ebeln == ReportsModellocal.ebeln)) {
                if (calculate == 1) {
                  calculate = calculate + 1;
                  result.removeWhere(
                      (element) => element.ebeln == ReportsModellocal.ebeln);
                }

                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              }
            } else if (doctype == "SR") {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);
              if (result.any((element) =>
                  element.documentno == ReportsModellocal.documentno)) {
                // if (calculate == 0) {
                //   calculate = calculate + 1;
                result.removeWhere((element) =>
                    element.documentno == ReportsModellocal.documentno &&
                    element.mblnr == null);
                // }

                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              } else {
                // for (int i = 0; i < listcategory.length; i++) {
                if (ReportsModellocal.detail.any(
                    (element) => element.inventory_group == choice.value)) {
                  result.removeWhere((element) =>
                      element.documentno == ReportsModellocal.documentno);
                  ReportsModellocal.flag = "Y";
                  result.add(ReportsModellocal);
                }
                // }
                // ;
              }
            } else {
              ReportsModellocal =
                  ReportsModel.fromDocumentSnapshotStock(documentSnapshot: doc);
              if (result.any((element) =>
                  element.documentno == ReportsModellocal.documentno)) {
                result.removeWhere((element) =>
                    element.documentno == ReportsModellocal.documentno);
                ReportsModellocal.flag = "Y";
                result.add(ReportsModellocal);
              }
            }

            // if (ReportsModellocal.isapprove == "Y") {
            //   result.add(ReportsModellocal);
            // } else {
            //   result.add(ReportsModellocal);
            // }
          }
        }
        QuerySnapshot query3 = await FirebaseFirestore.instance
            .collection('SR')
            .where('createdat', isGreaterThanOrEqualTo: choicedate.value)
            .get();

        if (query3.docs.isNotEmpty) {
          for (var doc in query3.docs) {
            ReportsModel ReportsModellocal;

            ReportsModellocal =
                ReportsModel.fromDocumentSnapshotOut(documentSnapshot: doc);

            ReportsModellocal.flag = "Y";

            result2.add(ReportsModellocal);
          }
          tolisthistoryout.assignAll(result2);
          tolisthistory.assignAll(result);
          isLoading.value = false;
          return result;
        }
      });
    }
  }

  dateToString(String date) {
    final format = DateFormat('dd-MM-yyyy');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }
}
