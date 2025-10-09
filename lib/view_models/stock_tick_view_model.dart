import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/config.dart';
import 'package:immobile_app_fixed/models/input_stock_take_model.dart';
import 'package:immobile_app_fixed/models/request_model.dart';
import 'package:immobile_app_fixed/models/stock_take_detail_model.dart';
import 'package:immobile_app_fixed/models/stock_take_model.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/role_view_model.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class StockTickVM extends GetxController {
  final Config config = Config();
  final GlobalVM globalvm = Get.find();
  final Rolevm rolevm = Get.find();
  final RxString selectchoice = "UU".obs;
  final RxList<dynamic> stocktickvm = <dynamic>[].obs;
  final RxString documentno = "".obs;
  final RxList<StocktickModel> tolistforscan = <StocktickModel>[].obs;
  final RxList<InputStockTake> tolistforinputstocktake = <InputStockTake>[].obs;
  final RxList<InputStockTake> tolistcounted = <InputStockTake>[].obs;
  final RxList<InputStockTake> tolistinput = <InputStockTake>[].obs;
  final RxList<StocktickModel> toliststock = <StocktickModel>[].obs;
  final RxList<StocktickModel> tolistdocument = <StocktickModel>[].obs;
  final RxList<StocktickModel> tolistdocumentnosame = <StocktickModel>[].obs;
  final RxList<StocktickModel> tolistdocumentsearch = <StocktickModel>[].obs;
  final RxList<StocktickModel> tolistdocumentcounted = <StocktickModel>[].obs;
  final RxList<StocktickModel> tolistdetail = <StocktickModel>[].obs;
  final RxList<StocktickModel> stockhistory = <StocktickModel>[].obs;
  final RxString searchValue = ''.obs;
  final RxString choicesr = "".obs;
  final RxString document = "".obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingPDF = true.obs;
  final RxBool isSearch = true.obs;
  final RxBool isIconSearch = true.obs;
  final RxInt isIconSearchint = 0.obs;
  final RxBool tutorialRecent = true.obs;
  final Rx<DateTime> datetimenow = DateTime.now().obs;
  final Rx<DateTime> firstdate = DateTime.now().obs;
  final Rx<DateTime> lastdate = DateTime.now().obs;
  final Rx<dynamic> pdfFile = Rx<dynamic>(null);
  final Rx<dynamic> pdfBytes = Rx<dynamic>(null);
  final RxString pdfDir = ''.obs;

  List<String> choicelocation = [];
  String choiceforchip = "";
  final Rx<List<StocktickModel>> stocklist = Rx<List<StocktickModel>>([]);
  List<StocktickModel> stocktickModellocal = [];
  List<InputStockTake> listinputstocktake = [];
  List<InputStockTake> listcountedstocktake = [];
  List<StocktickModel> stocktickModellocalout = [];
  List<StocktickModel> stockforhistory = [];

  @override
  void onReady() {
    super.onReady();
    _initializeStreams();
  }

  void _initializeStreams() {
    stocklist.bindStream(listDocumentStream());
    stocklist.bindStream(listDetailAll());
  }

  void forDetail() {
    stocklist.bindStream(listDetail());
  }

  void forDetailAll() {
    stocklist.bindStream(listDetailAll());
  }

  Future<List<StocktickModel>> listcounted() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('history_stocktake')
          .where('documentno', isEqualTo: document.value)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        stocktickModellocal = [];
        stocktickModellocalout = [];
        listcountedstocktake = [];

        for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
          final InputStockTake returnstock =
              InputStockTake.fromDocumentSnapshot(doc);
          listcountedstocktake.add(returnstock);
        }

        tolistcounted.assignAll(listcountedstocktake);
        isLoading.value = false;
      } else {
        Logger().e("Document does not exist.");
      }
    } catch (e) {
      Logger().e("Error in listcounted: $e");
    }
    return [];
  }

  Stream<List<StocktickModel>> listDetailAll() {
    try {
      return FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(document.value)
          .collection('batchid')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
            _resetLocalLists();

            for (final QueryDocumentSnapshot stock in querySnapshot.docs) {
              final InputStockTake returnstock =
                  InputStockTake.fromDocumentSnapshot(stock);
              listinputstocktake.add(returnstock);
            }

            tolistforinputstocktake.assignAll(listinputstocktake);
            isLoading.value = false;

            return toliststock;
          });
    } catch (e) {
      Logger().e("Error in listDetailAll: $e");
      return Stream.value([]);
    }
  }

  Stream<List<StocktickModel>> listDetail() {
    try {
      return FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(document.value)
          .collection('batchid')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
            _resetLocalLists();

            for (final QueryDocumentSnapshot stock in querySnapshot.docs) {
              final InputStockTake returnstock =
                  InputStockTake.fromDocumentSnapshot(stock);
              listinputstocktake.add(returnstock);
            }

            tolistforinputstocktake.assignAll(listinputstocktake);
            isLoading.value = false;

            return toliststock;
          });
    } catch (e) {
      Logger().e("Error in listDetail: $e");
      return Stream.value([]);
    }
  }

  Stream<List<StocktickModel>> listDocumentStream() {
    try {
      final String thisMonth = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(DateTime.now().year, DateTime.now().month, 1, 0));

      return FirebaseFirestore.instance
          .collection('stocktakes')
          .where('created', isGreaterThanOrEqualTo: thisMonth)
          .where('isapprove', isEqualTo: choiceforchip)
          .where('LGORT', arrayContainsAny: choicelocation)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
            _resetLocalLists();

            if (querySnapshot.docs.isNotEmpty) {
              for (final QueryDocumentSnapshot stock in querySnapshot.docs) {
                final StocktickModel returnstock =
                    StocktickModel.fromDocumentSnapshotWithDetail(stock);

                if (returnstock.isapprove == choiceforchip) {
                  stocktickModellocalout.add(returnstock);

                  final List<StockTakeDetailModel> uniqueDetails = [];
                  final Set<String> uniqueMATNRs = <String>{};

                  for (final StockTakeDetailModel detail
                      in returnstock.detail) {
                    if (uniqueMATNRs.add(detail.matnr ?? '')) {
                      uniqueDetails.add(detail);
                    }
                  }

                  stocktickModellocal.add(
                    StocktickModel(
                      documentno: returnstock.documentno,
                      detail: uniqueDetails,
                      lGORT: returnstock.lGORT,
                      updated: returnstock.updated,
                      updatedby: returnstock.updatedby,
                      created: returnstock.created,
                      createdby: returnstock.createdby,
                      isapprove: returnstock.isapprove,
                      doctype: returnstock.doctype,
                    ),
                  );
                }
              }
            }

            tolistdocumentnosame.assignAll(stocktickModellocal);
            tolistdocument.assignAll(stocktickModellocalout);
            isLoading.value = false;

            return toliststock;
          });
    } catch (e) {
      Logger().e("Error in listDocumentStream: $e");
      return Stream.value([]);
    }
  }

  Future<List<StocktickModel>> listStock() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sloc')
          .where('LGORT', arrayContainsAny: rolevm.role.value.stocktake)
          .get();

      _resetLocalLists();

      for (final QueryDocumentSnapshot stock in querySnapshot.docs) {
        final StocktickModel returnstock = StocktickModel.fromDocumentSnapshot(
          stock,
        );

        if (returnstock.isapprove == "N") {
          stocktickModellocal.add(returnstock);
          stocktickModellocalout.add(returnstock);
        }
      }

      tolistforscan.assignAll(stocktickModellocal);
      toliststock.assignAll(stocktickModellocalout);
      isLoading.value = false;

      return toliststock;
    } catch (e) {
      Logger().e("Error in listStock: $e");
      return [];
    }
  }

  Future<void> createdocument(List<Map<String, dynamic>> detail) async {
    try {
      final DateTime today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat(
        'yyyy-MM-dd kk:mm:ss',
      ).format(now);
      final String todayString = DateFormat('yyyy').format(today);

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stocktakes')
          .where('validation', isEqualTo: todayString)
          .get();

      final int totaldata = querySnapshot.size + 1;

      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc("ST$todayString$totaldata")
          .set({
            'validation': todayString,
            'documentno': "ST$todayString$totaldata",
            'LGORT': "HQ",
            'updated': "",
            'updatedby': "",
            'created': formattedDate,
            'createdby': globalvm.username.value,
            'isapprove': "N",
            'doctype': "stocktake",
            'detail': detail,
          });
    } catch (e) {
      Logger().e("Error in createdocument: $e");
    }
  }

  Future<void> forcounted(InputStockTake stocktickModel2) async {
    try {
      await FirebaseFirestore.instance
          .collection('history_stocktake')
          .doc(
            '${stocktickModel2.documentNo}'
            '${stocktickModel2.batchId}'
            '${stocktickModel2.matnr}'
            '${stocktickModel2.section}'
            '${globalvm.username.value}'
            '${stocktickModel2.selectedChoice}',
          )
          .set(stocktickModel2.toMap());
    } catch (e) {
      Logger().e("Error in forcounted: $e");
    }
  }

  Future<void> sendtohistory(InputStockTake stocktickModel2) async {
    try {
      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel2.documentNo)
          .collection('batchid')
          .doc(
            '${stocktickModel2.batchId}'
            '${stocktickModel2.matnr}'
            '${stocktickModel2.section}'
            '${stocktickModel2.selectedChoice}',
          )
          .set(stocktickModel2.toMap());
    } catch (e) {
      Logger().e("Error in sendtohistory: $e");
    }
  }

  Future<void> updatedetailtick(
    String documentno,
    List<StockTakeDetailModel> indetail,
  ) async {
    try {
      final List<Map<String, dynamic>> detailList = indetail
          .map((detail) => detail.toMap())
          .toList();

      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(documentno)
          .update({'detail': detailList});
    } catch (e) {
      Logger().e("Error in updatedetailtick: $e");
    }
  }

  Future<void> updatedetail(
    InputStockTake stocktickModel2,
    List<StockTakeDetailModel> indetail,
  ) async {
    try {
      final List<Map<String, dynamic>> detailList = indetail
          .map((detail) => detail.toMap())
          .toList();

      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel2.documentNo)
          .update({'detail': detailList});
    } catch (e) {
      Logger().e("Error in updatedetail: $e");
    }
  }

  Future<dynamic> getStock(String lgort, String werks, String username) async {
    try {
      final RequestWorkflow data = RequestWorkflow(
        documentno: lgort,
        group: werks,
        username: username,
      );

      EasyLoading.show(
        status: 'Getting Stock',
        maskType: EasyLoadingMaskType.black,
      );

      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('createdocument_stocktake')))
          .timeout(const Duration(seconds: 90));

      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonRefreshStock(data)));

      final HttpClientResponse response = await request.close();
      final String reply = await response.transform(utf8.decoder).join();

      EasyLoading.dismiss();

      switch (response.statusCode) {
        case 200:
          if (reply.isNotEmpty) {
            final List<StockTakeDetailModel> resList = [];
            return resList;
          } else {
            return false;
          }
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
    } on TimeoutException catch (e) {
      EasyLoading.dismiss();
      Logger().e("Timeout in getStock: $e");
      return "Request Timeout";
    } catch (e) {
      EasyLoading.dismiss();
      Logger().e("Error in getStock: $e");
      return false;
    }
  }

  Future<dynamic> sendemail(String documentno) async {
    try {
      EasyLoading.showProgress(
        0.3,
        status: 'Mempersiapkan request',
        maskType: EasyLoadingMaskType.black,
      );

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('urlsendemail')
          .get();

      if (!doc.exists || !doc.data().toString().contains('value')) {
        EasyLoading.dismiss();
        return "URL tidak ditemukan di Firestore";
      }

      final String url = doc.get('value') as String;

      final RequestWorkflow data = RequestWorkflow(documentno: documentno);

      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .postUrl(Uri.parse('${url}send-email-stocktake'))
          .timeout(const Duration(seconds: 5));

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer a76d16bdd5c5043f6f93f3e6c59bd35a',
      );

      request.add(utf8.encode(toJsonEmail(data)));

      final HttpClientResponse response = await request.close();
      final String reply = await response.transform(utf8.decoder).join();

      EasyLoading.showProgress(
        0.5,
        status: 'Menerima respon',
        maskType: EasyLoadingMaskType.black,
      );

      switch (response.statusCode) {
        case 200:
          EasyLoading.dismiss();
          return reply.isNotEmpty ? reply : false;
        case 400:
          return "Request Gagal Error 400";
        case 401:
          return "Request Gagal Error 401";
        default:
          return "Request Gagal Error ${response.statusCode}";
      }
    } on TimeoutException catch (e) {
      EasyLoading.dismiss();
      Logger().e("Timeout in sendemail: $e");
      return "Request Timeout";
    } catch (e) {
      EasyLoading.dismiss();
      Logger().e("Error in sendemail: $e");
      return false;
    }
  }

  Future<dynamic> producekafka(Map<String, dynamic> payload) async {
    try {
      EasyLoading.showProgress(
        0.3,
        status: 'Call WS',
        maskType: EasyLoadingMaskType.black,
      );

      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final Uri testing = Uri.parse(await config.urlkafka('produce'));

      final HttpClientRequest request = await client
          .postUrl(testing)
          .timeout(const Duration(seconds: 2));

      request.headers.set('Content-Type', 'application/json');
      request.headers.set(
        'Authorization',
        'Bearer a76d16bdd5c5043f6f93f3e6c59bd35a',
      );

      request.add(utf8.encode(jsonEncode(payload)));

      final HttpClientResponse response = await request.close();
      final String reply = await response.transform(utf8.decoder).join();

      EasyLoading.showProgress(
        0.5,
        status: 'Return WS',
        maskType: EasyLoadingMaskType.black,
      );

      switch (response.statusCode) {
        case 200:
          EasyLoading.dismiss();
          return reply.isNotEmpty ? reply : false;
        case 400:
          return "Request Gagal Error 400";
        case 401:
          return "Request Gagal Error 401";
        default:
          return "Request Gagal Error 404";
      }
    } on TimeoutException catch (e) {
      EasyLoading.dismiss();
      Logger().e("Timeout in producekafka: $e");
      return "Request Timeout";
    } catch (e) {
      EasyLoading.dismiss();
      Logger().e("Error in producekafka: $e");
      return false;
    }
  }

  Future<void> changeflag(
    StocktickModel stocktickModel,
    List<Map<String, dynamic>> detail,
  ) async {
    try {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel.documentno);

      await documentReference.update({"detail": detail});
    } catch (e) {
      Logger().e("Error in changeflag: $e");
    }
  }

  Future<void> approveall(StocktickModel stocktickModel) async {
    try {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel.documentno);

      await documentReference.update({
        "isapprove": "Y",
        "updated": stocktickModel.updated,
        "updatedby": stocktickModel.updatedby,
      });
    } catch (e) {
      Logger().e("Error in approveall: $e");
    }
  }

  String dateToString(String date) {
    final DateFormat format = DateFormat('dd-MM-yyyy');
    final DateTime dateTime = DateTime.parse(date);
    return format.format(dateTime);
  }

  List<StockTakeDetailModel> newListToDocument(
    String namechoice,
    String documentno,
  ) {
    if (tolistdocumentnosame.isEmpty) {
      return [];
    }

    final List<StocktickModel> matchedDocs = tolistdocumentnosame
        .where((element) => element.documentno == documentno)
        .toList();

    if (matchedDocs.isEmpty) {
      return [];
    }

    final StocktickModel selectedDoc = matchedDocs.first;

    if (searchValue.value.trim().isNotEmpty) {
      return selectedDoc.detail
          .where(
            (element) =>
                element.mAKTX.toLowerCase().contains(
                  searchValue.value.toLowerCase(),
                ) ||
                element.nORMT.contains(searchValue.value) ||
                element.mATNR.contains(searchValue.value),
          )
          .toSet()
          .toList();
    } else {
      return selectedDoc.detail.toSet().toList();
    }
  }

  StocktickModel newStockTickModel(String namechoice, int index) {
    return namechoice == "ALL"
        ? searchValue.value == ''
              ? tolistdocument[index]
              : tolistdocument[index]
        : searchValue.value.trim().isNotEmpty
        ? tolistdocument[index]
        : tolistdocument[index];
  }

  void _resetLocalLists() {
    stocktickModellocal = [];
    stocktickModellocalout = [];
    stockforhistory = [];
    tolistforscan.value = [];
    listinputstocktake = [];
    tolistdetail.value = [];
  }
}
