import 'dart:async';
import 'package:immobile/config/config.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:get/get.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:immobile/viewmodel/globalvm.dart';

class InVM extends GetxController {
  GlobalVM globalvm = Get.find();
  static var client = http.Client();
  Config config = Config();
  var tolistPO = List<InModel>().obs;
  var tolistPOapprove = List<InModel>().obs;
  var tolistPObackup = List<InModel>().obs;

  Rx<List<InModel>> srlist = Rx<List<InModel>>([]);
  Rx<List<InModel>> srlisthistory = Rx<List<InModel>>([]);
  List<InModel> outmodellocal = [];
  List<InModel> outmodellocalbackup = [];
  List<InModel> outmodelhistory = [];

  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var sortVal = "PO Date".obs;
  var choicein = "".obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var isSearch = true.obs;
  var isapprove = false.obs;
  var isIconSearchint = 0.obs;
  var isIconSearch = true.obs;
  var isDark = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  String username;

  @override
  void onReady() {
    // srlist.bindStream(listPO());
    srlist.bindStream(listPO());
  }

  void onRecent() {
    srlist.bindStream(listforRecentALL());
  }

  void getname() async {
    username = await DatabaseHelper.db.getUser();
  }

  dateToString(String date, String test) {
    String dateFormat;
    if (date == null) {
      return dateFormat = "";
    } else {
      final format = DateFormat('dd-MM-yyyy');
      final dateTime = DateTime.parse(date);
      dateFormat = format.format(dateTime);
      return dateFormat;
    }
  }

  approveIn(InModel inmodel, List<Map<String, dynamic>> tdata) async {
    try {
      DateTime now = DateTime.now();

      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('in')
          .doc(inmodel.group)
          .collection('header')
          .doc(inmodel.ebeln)
          .set({
        'AEDAT': inmodel.aedat,
        'BWART': inmodel.bwart,
        'DLV_COMP': inmodel.dlv_comp,
        'EBELN': inmodel.ebeln,
        'ERNAM': inmodel.ernam,
        'GROUP': inmodel.group,
        'LGORT': inmodel.lgort,
        'LIFNR': inmodel.lifnr,
        'T_DATA': tdata,
        'WERKS': inmodel.werks,
        'clientid': inmodel.clientid,
        'created': inmodel.created,
        'createdby': inmodel.createdby,
        'doctype': inmodel.doctype,
        'orgid': inmodel.orgid,
        'sync': inmodel.issync,
        'updated': formattedDate,
        'updatedby': username,
        'TRUCK': inmodel.truck,
        'INVOICENO': inmodel.invoiceno,
        'VENDORPO': inmodel.vendorpo
      });
      return true;
    } catch (e) {
      return false;
    }

    // .then((result) => {print("Sukses")})
    // .catchError((err) => print(err));
  }

  Future<void> sendHistory(
      InModel inmodel, List<Map<String, dynamic>> tdata) async {
    try {
      DateTime now = DateTime.now();
      String todayString = DateFormat('yyyy-MM-dd').format(now);
      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      var username = await DatabaseHelper.db.getUser();

      // Reference to the collection and document (no specific document ID)
      final CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(GlobalVar.choicecategory)
          .collection(todayString);

      final Map<String, dynamic> historyData = {
        'AEDAT': inmodel.aedat,
        'BWART': inmodel.bwart,
        'DLV_COMP': inmodel.dlv_comp,
        'EBELN': inmodel.ebeln,
        'ERNAM': inmodel.ernam,
        'GROUP': inmodel.group,
        'LGORT': inmodel.lgort,
        'LIFNR': inmodel.lifnr,
        'T_DATA': tdata,
        'WERKS': inmodel.werks,
        'clientid': inmodel.clientid,
        'created': inmodel.created,
        'createdby': inmodel.createdby,
        'doctype': inmodel.doctype,
        'orgid': inmodel.orgid,
        'sync': inmodel.issync,
        'updated': formattedDate,
        'updatedby': username,
        'TRUCK': inmodel.truck
      };

      // Add the data as a new document with a generated document ID
      await historyCollection.add(historyData);
    } catch (e) {
      // Handle errors or log them as needed
    }
  }

  Future<List<InModel>> getData(String ebeln, String category) async {
    try {
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('in')
          .doc(category)
          .collection('header')
          .where("EBELN", isEqualTo: ebeln)
          .get();

      if (query.docs.isNotEmpty) {
        final List<InModel> outmodellocal = [];
        for (var sr in query.docs) {
          final returnpo = InModel.fromDocumentSnapshot(documentSnapshot: sr);
          final returnpobackup =
              InModel.fromDocumentSnapshot(documentSnapshot: sr);

          if (returnpo.dlv_comp == "X" || returnpo.dlv_comp == "I") {
            // Skip this item if the condition is met
          } else {
            outmodellocal.add(returnpo);
            outmodellocalbackup.add(returnpobackup);
          }
        }

        // You should return the list of data here
        return outmodellocal;
      } else {
        // If no data is found, you can return an empty list or handle it accordingly
        return [];
      }
    } catch (e) {
      // Handle any errors that may occur during data retrieval
      print("Error fetching data: $e");
      throw e; // You can choose to handle or propagate the error
    }
  }

  // sendHistory(InModel inmodel, List<Map<String, dynamic>> tdata) async {
  //   try {
  //     DateTime now = DateTime.now();
  //     String todayString = DateFormat('yyyy-MM-dd').format(now);
  //     String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
  //     var username = await DatabaseHelper.db.getUser();
  //     await FirebaseFirestore.instance
  //         .collection('HISTORY')
  //         .doc(GlobalVar.choicecategory)
  //         .collection(todayString)
  //         .doc(inmodel.ebeln)
  //         .set({
  //       'AEDAT': inmodel.aedat,
  //       'BWART': inmodel.bwart,
  //       'DLV_COMP': inmodel.dlv_comp,
  //       'EBELN': inmodel.ebeln,
  //       'ERNAM': inmodel.ernam,
  //       'GROUP': inmodel.group,
  //       'LGORT': inmodel.lgort,
  //       'LIFNR': inmodel.lifnr,
  //       'T_DATA': tdata,
  //       'WERKS': inmodel.werks,
  //       'clientid': inmodel.clientid,
  //       'created': inmodel.created,
  //       'createdby': inmodel.createdby,
  //       'doctype': inmodel.doctype,
  //       'orgid': inmodel.orgid,
  //       'sync': inmodel.issync,
  //       'updated': formattedDate,
  //       'updatedby': username,
  //       'TRUCK': inmodel.truck
  //     });
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Stream<List<InModel>> listPO() {
    final onemonth = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 30);
    final onemonthstring = DateFormat('yyyy-MM-dd').format(onemonth);

    try {
      if (GlobalVar.choicecategory == "ALL") {
        final stream1 = FirebaseFirestore.instance
            .collection('in/AB/header')
            .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
            .snapshots();

        final stream2 = FirebaseFirestore.instance
            .collection('in/CH/header')
            .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
            .snapshots();

        final stream3 = FirebaseFirestore.instance
            .collection('in/FZ/header')
            .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
            .snapshots();

        if (stream1 == null || stream2 == null || stream3 == null) {
          return Stream.value([]);
        }

        final combinedStream = StreamZip([stream1, stream2, stream3]);

        return combinedStream.asyncMap<List<InModel>>((snapshots) {
          final outmodellocal = <InModel>[];

          for (final query in snapshots) {
            for (final sr in query.docs) {
              final returnpo =
                  InModel.fromDocumentSnapshot(documentSnapshot: sr);

              if (returnpo.dlv_comp == "X") {
                // Handle specific case
              } else if (returnpo.dlv_comp == "I") {
                outmodellocal.add(returnpo);
              }
            }
          }

          tolistPO.assignAll(outmodellocal);
          // isLoading.value = false;
          return tolistPO;
        }).timeout(
          const Duration(seconds: 10), // Set your desired timeout duration
          onTimeout: (event) {
            // isLoading.value = false;
            // Handle timeout here, for example, by returning an empty list or showing an error message.
            return Stream.value([]);
          },
        );
      } else {
        return FirebaseFirestore.instance
            .collection('in/${GlobalVar.choicecategory}/header')
            .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
            .snapshots()
            .map((QuerySnapshot query) {
          final outmodellocal = <InModel>[];

          for (final sr in query.docs) {
            final returnpo = InModel.fromDocumentSnapshot(documentSnapshot: sr);

            if (returnpo.dlv_comp == "X" || returnpo.dlv_comp == "I") {
              // Handle specific cases
            } else {
              outmodellocal.add(returnpo);
            }
          }

          if (outmodellocal
              .any((element) => element.group != GlobalVar.choicecategory)) {
            onReady();
          } else {
            if (outmodellocal.isNotEmpty) {
              tolistPO.assignAll(outmodellocal);
            } else {
              tolistPO.value = [];
            }
          }
          return tolistPO;
        }).timeout(
          const Duration(seconds: 5), // Set your desired timeout duration
          onTimeout: (event) {
            // Handle timeout here, for example, by returning an empty list or showing an error message.
            return Stream.value([]);
          },
        ).timeout(
          const Duration(seconds: 10), // Set your desired timeout duration
          onTimeout: (event) {
            // isLoading.value = false;
            // Handle timeout here, for example, by returning an empty list or showing an error message.
            return Stream.value([]);
          },
        );
      }
    } catch (e) {
      print(e);
      // isLoading.value = false;
      return Stream.error(e);
    }
  }

  // Stream<List<InModel>> listPO() {
  //   // // isLoading.value = true;
  //   var onemonth = DateTime(
  //       DateTime.now().year, DateTime.now().month, DateTime.now().day - 30);
  //   String onemonthstring = DateFormat('yyyy-MM-dd').format(onemonth);
  //   try {
  //     if (GlobalVar.choicecategory == "ALL") {
  //       var stream1 = FirebaseFirestore.instance
  //           .collection('in')
  //           .doc('AB')
  //           .collection('header')
  //           .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
  //           // .limit(10)
  //           .snapshots();

  //       var stream2 = FirebaseFirestore.instance
  //           .collection('in')
  //           .doc('CH')
  //           .collection('header')
  //           .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
  //           // .limit(10)
  //           .snapshots();

  //       var stream3 = FirebaseFirestore.instance
  //           .collection('in')
  //           .doc('FZ')
  //           .collection('header')
  //           .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
  //           // .limit(10)
  //           .snapshots();

  //       // Check if any of the streams is null
  //       if (stream1 == null || stream2 == null || stream3 == null) {
  //         // Return an empty stream or handle the error accordingly
  //         return Stream.value([]);
  //       }

  //       var combinedStream = StreamZip([stream1, stream2, stream3]);

  //       return combinedStream.asyncMap<List<InModel>>((snapshots) {
  //         outmodellocal = [];
  //         // tolistPO.value = [];
  //         // tolistPObackup.value = [];

  //         for (var query in snapshots) {
  //           if (query.docs.isNotEmpty) {
  //             for (var sr in query.docs) {
  //               final returnpo =
  //                   InModel.fromDocumentSnapshot(documentSnapshot: sr);
  //               final returnpobackup =
  //                   InModel.fromDocumentSnapshot(documentSnapshot: sr);

  //               if (returnpo.dlv_comp == "X") {
  //                 // print("TES");
  //               } else if (returnpo.dlv_comp == "I") {
  //                 // if (outmodellocal.length != 10) {
  //                 outmodellocal.add(returnpo);
  //                 outmodellocalbackup.add(returnpobackup);
  //                 // }
  //               }
  //             }
  //           }
  //         }
  //         // if (outmodellocal.length != 0) {
  //         tolistPO.assignAll(outmodellocal);
  //         tolistPObackup.assignAll(outmodellocalbackup);
  //         // } else {
  //         // tolistPO.value = [];
  //         // tolistPObackup.value = [];
  //         //   tolistPO.assignAll(outmodellocal);
  //         //   tolistPObackup.assignAll(outmodellocalbackup);
  //         // }

  //         // isLoading.value = false;

  //         return tolistPO;
  //       });
  //     } else {
  //       return FirebaseFirestore.instance
  //           .collection('in')
  //           .doc(GlobalVar.choicecategory)
  //           .collection('header')
  //           // .limit(10)
  //           // .where("EBELN", isEqualTo: "2611014408")
  //           .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
  //           .snapshots()
  //           .map((QuerySnapshot query) {
  //         if (query.docs.isNotEmpty) {
  //           outmodellocal = [];
  //           tolistPO.value = [];
  //           tolistPObackup.value = [];
  //           for (var sr in query.docs) {
  //             final returnpo =
  //                 InModel.fromDocumentSnapshot(documentSnapshot: sr);
  //             final returnpobackup =
  //                 InModel.fromDocumentSnapshot(documentSnapshot: sr);

  //             // tolistSPPA.removeWhere((element) =>
  //             //     element.documentnosppa == sppa.data()['documentnosppa']);
  //             // if (outmodellocal.length) {

  //             if (returnpo.dlv_comp == "X" || returnpo.dlv_comp == "I") {
  //               // print("TES");
  //             } else {
  //               outmodellocal.add(returnpo);
  //               outmodellocalbackup.add(returnpobackup);
  //             }

  //             // }
  //           }

  //           if (outmodellocal
  //               .any((element) => element.group != GlobalVar.choicecategory)) {
  //             onReady();
  //           } else {
  //             if (outmodellocal.length != 0) {
  //               tolistPO.assignAll(outmodellocal);
  //               tolistPObackup.assignAll(outmodellocalbackup);
  //             } else {
  //               tolistPO.value = [];
  //               tolistPObackup.value = [];
  //               tolistPO.assignAll(outmodellocal);
  //               tolistPObackup.assignAll(outmodellocalbackup);
  //             }
  //             // tolistPO.assignAll(outmodellocal);
  //             // tolistPObackup.assignAll(outmodellocalbackup);
  //             // isLoading.value = false;
  //             return tolistPO;
  //           }
  //         } else {
  //           tolistPO.clear();
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     // isLoading.value = false;
  //     print(e);
  //   }
  // }

  Stream<List<InModel>> listforRecentALL() {
    var onemonth = DateTime.now().subtract(Duration(days: 30));
    String onemonthstring = DateFormat('yyyy-MM-dd').format(onemonth);

    var stream1 = FirebaseFirestore.instance
        .collection('in')
        .doc('AB')
        .collection('header')
        .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
        .limit(10)
        .snapshots();

    var stream2 = FirebaseFirestore.instance
        .collection('in')
        .doc('CH')
        .collection('header')
        .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
        .limit(10)
        .snapshots();

    var stream3 = FirebaseFirestore.instance
        .collection('in')
        .doc('FZ')
        .collection('header')
        .where('AEDAT', isGreaterThanOrEqualTo: onemonthstring)
        .limit(10)
        .snapshots();

    // Check if any of the streams is null
    if (stream1 == null || stream2 == null || stream3 == null) {
      // Return an empty stream or handle the error accordingly
      return Stream.value([]);
    }

    var combinedStream = StreamZip([stream1, stream2, stream3]);

    return combinedStream.asyncMap<List<InModel>>((snapshots) {
      outmodellocal = [];
      tolistPO.value = [];
      tolistPObackup.value = [];

      for (var query in snapshots) {
        if (query.docs.isNotEmpty) {
          for (var sr in query.docs) {
            final returnpo = InModel.fromDocumentSnapshot(documentSnapshot: sr);
            final returnpobackup =
                InModel.fromDocumentSnapshot(documentSnapshot: sr);

            if (returnpo.dlv_comp == "X") {
              // print("TES");
            } else {
              if (outmodellocal.length != 10) {
                outmodellocal.add(returnpo);
                outmodellocalbackup.add(returnpobackup);
              }
            }
          }
        }
      }

      tolistPO.assignAll(outmodellocal);
      tolistPObackup.assignAll(outmodellocalbackup);
      // isLoading.value = false;

      return tolistPO;
    });
  }

  dynamic getpowithdoc(String ebeln) async {
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = ebeln;

      // EasyLoading.showProgress(0.3,
      //     status: 'Call WS', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('getposapwithdoc')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonGetDocument(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      // EasyLoading.showProgress(0.5,
      //     status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          if (reply == "0") {
            return "false";
          } else {}
          // if (reply.isNotEmpty) {
          // } else {
          //   return false;
          // }
          return reply;
        case 400:
          return "false";
        case 401:
          return "false";
        case 403:
          return "false";
        case 504:
          return "false";
        case 500:
          return "false";
        default:
          return "false";
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      print(e);
    } catch (e) {
      print(e);
      return false;
    }
  }

  dynamic approveWF(InModel inmodel, String all) async {
    // // isLoading.value = true;
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = inmodel.ebeln;
      data.group = inmodel.group;
      data.role = "ALL";

      // EasyLoading.showProgress(0.3,
      //     status: 'Call WS', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('postgrtosap')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonApproveIn(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      // EasyLoading.showProgress(0.5,
      //     status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          if (reply.isNotEmpty) {
          } else {
            return "false";
          }
          // isLoading.value = false;
          return "true";
        case 400:
          // isLoading.value = false;
          return "false";
        case 401:
          // isLoading.value = false;
          return "false";
        case 403:
          // isLoading.value = false;
          return "false";
        case 504:
          // // isLoading.value = false;
          return "false";
        case 500:
          // // isLoading.value = false;
          return "false";
        default:
          // // isLoading.value = false;
          return "Approval Gagal";
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      print(e);
    } catch (e) {
      print(e);
      return false;
    }
  }

  dynamic savenodocument(InModel inmodel, String all) async {
    // // isLoading.value = true;
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = inmodel.ebeln;
      data.username = globalvm.username.value;

      // EasyLoading.showProgress(0.3,
      //     status: 'Call WS', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('savenodocument')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonSaveNoDocument(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      // EasyLoading.showProgress(0.5,
      //     status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          if (reply.isNotEmpty) {
          } else {
            return "false";
          }
          // isLoading.value = false;
          return "true";
        case 400:
          // isLoading.value = false;
          return "false";
        case 401:
          // isLoading.value = false;
          return "false";
        case 403:
          // isLoading.value = false;
          return "false";
        case 504:
          // // isLoading.value = false;
          return "false";
        case 500:
          // // isLoading.value = false;
          return "false";
        default:
          // // isLoading.value = false;
          return "Approval Gagal";
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      print(e);
    } catch (e) {
      print(e);
      return false;
    }
  }
}
