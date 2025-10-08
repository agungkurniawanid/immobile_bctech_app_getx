import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_detail_model.dart';
import 'immobileitem_model.dart';

class StockModel implements ImmobileItem {
  final String? recordid;
  final String? color;
  final String? created;
  final String? createdby;
  final String? orgid;
  final String? updated;
  final String? updatedby;
  final String? location;
  final String? formattedUpdatedAt;
  final String? isApprove;
  final String? locationName;
  final String? updatedAt;
  final String? clientid;
  final String? isSync;
  final String? doctype;
  final List<StockDetail>? detail;

  const StockModel({
    this.recordid,
    this.color,
    this.created,
    this.createdby,
    this.orgid,
    this.updated,
    this.updatedby,
    this.location,
    this.formattedUpdatedAt,
    this.isApprove,
    this.locationName,
    this.updatedAt,
    this.clientid,
    this.isSync,
    this.doctype,
    this.detail,
  });

  /// 🔁 Clone method
  StockModel clone() => StockModel(
    recordid: recordid,
    color: color,
    created: created,
    createdby: createdby,
    orgid: orgid,
    updated: updated,
    updatedby: updatedby,
    location: location,
    formattedUpdatedAt: formattedUpdatedAt,
    isApprove: isApprove,
    locationName: locationName,
    updatedAt: updatedAt,
    clientid: clientid,
    isSync: isSync,
    doctype: doctype,
    detail: detail != null
        ? detail!.map((item) => StockDetail.clone(item)).toList()
        : [],
  );

  /// 🔍 Ambil tanggal approval terakhir user
  @override
  String getApprovedat(String user) {
    String maxDate = "2000-01-01";

    if (detail == null || detail!.isEmpty) return maxDate;

    for (var item in detail!.where(
      (item) =>
          item.approveName == user && (item.updatedAt?.isNotEmpty ?? false),
    )) {
      final updatedAtDate = DateTime.tryParse(item.updatedAt ?? "2000-01-01");
      final maxDateParsed = DateTime.tryParse(maxDate);

      if (updatedAtDate != null &&
          maxDateParsed != null &&
          updatedAtDate.isAfter(maxDateParsed)) {
        maxDate = item.updatedAt!;
      }
    }
    return maxDate;
  }

  /// 🏗️ Factory dari Firestore Document
  factory StockModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    try {
      final data = documentSnapshot.data() as Map<String, dynamic>? ?? {};

      return StockModel(
        recordid: data['recordid']?.toString() ?? '',
        color: data['color']?.toString() ?? '',
        formattedUpdatedAt: data['formatted_updated_at']?.toString() ?? '',
        location: data['location']?.toString() ?? '',
        locationName: data['location_name']?.toString() ?? '',
        updatedAt: data['updated_at']?.toString() ?? '',
        isApprove: data['isapprove']?.toString() ?? '',
        isSync: data['sync']?.toString() ?? '',
        clientid: data['clientid']?.toString() ?? '',
        created: data['created']?.toString() ?? '',
        createdby: data['createdby']?.toString() ?? '',
        orgid: data['orgid']?.toString() ?? '',
        updated: data['updated']?.toString() ?? '',
        updatedby: data['updatedby']?.toString() ?? '',
        doctype: data['doctype']?.toString() ?? '',
        detail: (data['detail'] is List)
            ? (data['detail'] as List)
                  .map((item) => StockDetail.fromJson(item))
                  .toList()
            : [],
      );
    } catch (e) {
      print('Error parsing StockModel: $e');
      return const StockModel();
    }
  }

  /// 🔁 Konversi ke JSON
  Map<String, dynamic> toJson() => {
    'recordid': recordid,
    'color': color,
    'created': created,
    'createdby': createdby,
    'orgid': orgid,
    'updated': updated,
    'updatedby': updatedby,
    'location': location,
    'formatted_updated_at': formattedUpdatedAt,
    'isapprove': isApprove,
    'location_name': locationName,
    'updated_at': updatedAt,
    'clientid': clientid,
    'sync': isSync,
    'doctype': doctype,
    'detail': detail?.map((e) => e.toMap()).toList(),
  };

  @override
  String toString() => jsonEncode(toJson());
}
