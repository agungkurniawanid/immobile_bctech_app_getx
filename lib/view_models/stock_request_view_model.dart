import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/config.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';
import 'package:immobile_app_fixed/models/out_model.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:intl/intl.dart';

class StockRequestVM extends GetxController {
  final GlobalVM globalVM = Get.find();
  final Config config = Config();

  // Reactive variables
  final RxList<OutModel> srList = <OutModel>[].obs;
  final RxList<OutModel> srBackupList = <OutModel>[].obs;
  final RxList<OutModel> srOutList = <OutModel>[].obs;
  final RxList<OutModel> srApproveList = <OutModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool srButton = false.obs;
  final Rx<DateTime> dateTimeNow = DateTime.now().obs;
  final Rx<DateTime> firstDate = DateTime.now().obs;
  final Rx<DateTime> lastDate = DateTime.now().obs;
  final RxBool isApprove = false.obs;
  final RxBool isLoadingPDF = true.obs;
  final RxBool isSearch = true.obs;
  final RxInt isIconSearchInt = 0.obs;
  final RxBool isIconSearch = true.obs;
  final RxString pdfDir = ''.obs;
  final Rx<dynamic> pdfFile = Rx<dynamic>(null);
  final Rx<dynamic> pdfBytes = Rx<dynamic>(null);
  final RxBool tutorialRecent = true.obs;

  final ValueNotifier<bool> forButton = ValueNotifier(false);

  // Non-reactive
  List<OutModel> outModelLocal = [];
  List<OutModel> outModelLocalOut = [];
  List<OutModel> originalSROut = [];
  List<OutModel> listSRApprove = [];

  late OutModel modelLocal;

  String sameCode = '';
  String totalItem = '';
  String uom = '';
  String validationDocumentNo = '';
  String replyFromServer = '';
  String collectionName = '';

  bool validationButtonRefresh = false;

  // === Lifecycle ===
  @override
  void onReady() {
    super.onReady();
    srList.bindStream(listSR());
  }

  void onButton() {
    srButton.bindStream(validationForButton());
  }

  // === FIREBASE COLLECTION NAME ===
  Future<String> _fetchCollectionName() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('validation')
        .doc('collectionsr')
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['name'] ?? 'rpos_sr';
    }
    return 'rpos_sr';
  }

  Future<void> _initCollection() async {
    collectionName = await _fetchCollectionName();
  }

  // === STREAM BUTTON VALIDATION ===
  Stream<bool> validationForButton() {
    return FirebaseFirestore.instance
        .collection('validation')
        .doc('buttonrefreshout')
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;
            forButton.value = data['name'] == true;
            return forButton.value;
          }
          return false;
        });
  }

  // === STREAM LIST SR ===
  Stream<List<OutModel>> listSR() async* {
    await _initCollection();
    isLoading.value = true;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayString = DateFormat('yyyy-MM-dd').format(yesterday);

    yield* FirebaseFirestore.instance
        .collection(collectionName)
        .where('createdat', isGreaterThanOrEqualTo: yesterdayString)
        .snapshots()
        .map((snapshot) {
          outModelLocalOut.clear();
          originalSROut.clear();
          sameCode = '';
          totalItem = '';
          uom = '';

          for (final doc in snapshot.docs) {
            final outModel = OutModel.fromDocumentSnapshot(doc);

            // Perbaikan: gunakan properti yang sesuai dengan OutModel
            outModel.flag =
                outModel.detail?.any((d) => d.updatedAt.isNotEmpty) ?? false
                ? 'Y'
                : '';

            if (outModel.isApprove != 'Y') {
              if (srOutList.isNotEmpty &&
                  validationDocumentNo == outModel.documentNo) {
                continue;
              } else {
                originalSROut.add(outModel);
                outModelLocalOut.add(outModel);
              }
            }
          }

          // Filtering & sorting
          if (GlobalVar.choicecategory == 'ALL') {
            outModelLocalOut.sort(
              (a, b) => (b.flag ?? '').compareTo(a.flag ?? ''),
            );
            srOutList.assignAll(outModelLocalOut);
          } else {
            try {
              final filtered = outModelLocalOut
                  .where(
                    (e) =>
                        e.detail != null &&
                        e.detail!.any(
                          (d) =>
                              d.isApprove == 'N' &&
                              d.inventoryGroup.contains(
                                GlobalVar.choicecategory,
                              ),
                        ),
                  )
                  .toList();
              srOutList.assignAll(filtered);
            } catch (e) {
              debugPrint('Filter error: $e');
            }
          }

          originalSROut.sort((a, b) => (b.flag ?? '').compareTo(a.flag ?? ''));
          srBackupList.assignAll(originalSROut);
          isLoading.value = false;
          return srBackupList;
        });
  }

  // === APPROVE SR ===
  Future<dynamic> approveSR(OutModel outModel, String group) async {
    try {
      // Perbaikan: sesuaikan dengan model data yang diperlukan
      final requestData = {'documentno': outModel.documentNo, 'group': group};

      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final request = await client
          .postUrl(Uri.parse(await config.url('postsrtosap')))
          .timeout(const Duration(seconds: 90));

      request.headers
        ..set('content-type', 'application/json')
        ..set('Authorization', config.apiKey);

      request.add(utf8.encode(jsonEncode(requestData)));

      final response = await request.close();
      final reply = await response.transform(utf8.decoder).join();
      replyFromServer = reply;

      if (response.statusCode == 200 && reply.isNotEmpty) {
        return true;
      } else {
        return 'Failed: $reply';
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      return 'Failed (Timeout)';
    } catch (e) {
      debugPrint('Error approveSR: $e');
      return 'Failed: $replyFromServer';
    }
  }

  // === FIREBASE UPDATE ===
  Future<bool> approveOut(
    OutModel outModel,
    List<Map<String, dynamic>> tdata,
  ) async {
    try {
      await _initCollection();
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(outModel.documentNo) // Perbaikan: documentNo bukan documentno
          .update({
            'details': tdata,
            'sync': outModel.isSync, // Perbaikan: isSync bukan issync
            'updated': outModel.updated,
            'updatedby': globalVM.username.value,
          });
      return true;
    } catch (e) {
      debugPrint('approveOut error: $e');
      return false;
    }
  }

  Future<bool> flagAfterSendSAP(OutModel outModel) async {
    try {
      await _initCollection();
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(outModel.documentNo) // Perbaikan: documentNo bukan documentno
          .update({
            'isapprove':
                outModel.isApprove, // Perbaikan: isApprove bukan isapprove
            'sync': outModel.isSync, // Perbaikan: isSync bukan issync
          });
      return true;
    } catch (e) {
      debugPrint('flagAfterSendSAP error: $e');
      return false;
    }
  }

  Future<void> sendToHistory(
    OutModel outModel,
    List<Map<String, dynamic>> tdata,
    String group,
  ) async {
    try {
      final today = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(today);

      final historyCollection = FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(group)
          .collection(todayString);

      final historyData = {
        'clientid': outModel.clientId,
        'created': outModel.created,
        'createdat': outModel.createdAt,
        'createdby': outModel.createdBy,
        'delivery_date': outModel.deliveryDate,
        'details': tdata,
        'doctype': outModel.docType,
        'documentno': outModel.documentNo,
        'grouped_items': outModel.item,
        'inventory_group': outModel.inventoryGroup,
        'isapprove': outModel.isApprove,
        'location': outModel.location,
        'location_name': outModel.locationName,
        'orgid': outModel.orgId,
        'recordid': outModel.recordId,
        'sync': outModel.isSync,
        'total_item': outModel.totalItem,
        'total_quantities': outModel.totalQuantity,
        'updated': outModel.updated,
        'updatedby': globalVM.username.value,
      };

      await historyCollection.add(historyData);
    } catch (e) {
      debugPrint('sendToHistory error: $e');
    }
  }

  // === FETCH DATA FROM API ===
  Future<bool> getStockRequest() async {
    try {
      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final request = await client
          .postUrl(Uri.parse(await config.url('getstockrequest')))
          .timeout(const Duration(seconds: 90));

      request.headers
        ..set('content-type', 'application/json')
        ..set('Authorization', config.apiKey);

      request.add(utf8.encode(jsonEncode([])));

      final response = await request.close();
      final reply = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 && reply.isNotEmpty) {
        onReady();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('getStockRequest error: $e');
      return false;
    }
  }

  // === HELPER METHOD UNTUK JSON CONVERSION ===
  String toJsonApproveSR(Map<String, dynamic> data) {
    return jsonEncode(data);
  }
}

// Kelas bantuan untuk request workflow (jika masih diperlukan)
class RequestWorkflow {
  String? documentno;
  String? group;

  RequestWorkflow({this.documentno, this.group});

  Map<String, dynamic> toJson() {
    return {'documentno': documentno, 'group': group};
  }
}
