import 'package:cloud_firestore/cloud_firestore.dart';
import 'in_detail_model.dart';
import 'immobileitem_model.dart';

class InModel implements ImmobileItem {
  String? aedat;
  String? ebeln;
  String? group;
  String? lifnr;
  String? clientid;
  String? ernam;
  List<InDetail>? tData;
  String? mblnr;
  String? approvedate;
  String? issync;
  String? orgid;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;
  String? doctype;
  String? werks;
  String? lgort;
  String? dlvComp;
  String? bwart;
  String? truck;
  String? invoiceno;
  String? vendorpo;

  InModel({
    this.aedat,
    this.ebeln,
    this.group,
    this.lifnr,
    this.clientid,
    this.ernam,
    this.tData,
    this.mblnr,
    this.approvedate,
    this.issync,
    this.orgid,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
    this.doctype,
    this.werks,
    this.lgort,
    this.dlvComp,
    this.bwart,
    this.truck,
    this.invoiceno,
    this.vendorpo,
  });

  @override
  String getApprovedat(String user) {
    if (updatedby == user) {
      return updated ?? "";
    }
    return "";
  }

  factory InModel.clone(InModel data) {
    return InModel(
      aedat: data.aedat,
      ebeln: data.ebeln,
      group: data.group,
      lifnr: data.lifnr,
      clientid: data.clientid,
      ernam: data.ernam,
      tData: data.tData?.map((item) => InDetail.clone(item)).toList(),
      mblnr: data.mblnr,
      approvedate: data.approvedate,
      issync: data.issync,
      orgid: data.orgid,
      created: data.created,
      createdby: data.createdby,
      updated: data.updated,
      updatedby: data.updatedby,
      doctype: data.doctype,
      werks: data.werks,
      lgort: data.lgort,
      dlvComp: data.dlvComp,
      bwart: data.bwart,
      truck: data.truck,
      invoiceno: data.invoiceno,
      vendorpo: data.vendorpo,
    );
  }

  factory InModel.fromJson(Map<String, dynamic> json) {
    return InModel(
      aedat: json['aedat'],
      ebeln: json['ebeln'],
      group: json['group'],
      lifnr: json['lifnr'],
      clientid: json['clientid'],
      ernam: json['ernam'],
      tData: (json['T_DATA'] as List?)
          ?.map((e) => InDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      mblnr: json['mblnr'],
      approvedate: json['approvedate'],
      issync: json['issync'],
      orgid: json['orgid'],
      created: json['created'],
      createdby: json['createdby'],
      updated: json['updated'],
      updatedby: json['updatedby'],
      doctype: json['doctype'],
      werks: json['werks'],
      lgort: json['lgort'],
      dlvComp: json['dlv_comp'],
      bwart: json['bwart'],
      truck: json['truck'],
      invoiceno: json['invoiceno'],
      vendorpo: json['vendorpo'],
    );
  }

  factory InModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>?;

    if (data == null) return InModel();

    return InModel(
      aedat: data['AEDAT'] ?? "",
      ebeln: data['EBELN'] ?? "",
      group: data['GROUP'] ?? "",
      lifnr: data['LIFNR'] ?? "",
      ernam: data['ERNAM'] ?? "",
      clientid: data['clientid'] ?? "",
      tData: (data['T_DATA'] as List?)
          ?.map((e) => InDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      issync: data['sync'] ?? "",
      orgid: data['orgid'] ?? "",
      created: data['created'] ?? "",
      createdby: data['createdby'] ?? "",
      updated: data['updated'] ?? "",
      updatedby: data['updatedby'] ?? "",
      doctype: data['doctype'] ?? "",
      werks: data['WERKS'] ?? "",
      lgort: data['LGORT'] ?? "",
      dlvComp: data['DLV_COMP'] ?? "",
      bwart: data['BWART'] ?? "",
      truck: data['TRUCK'] ?? "",
      mblnr: data['MBLNR'] ?? "",
      invoiceno: data['INVOICENO'] ?? "",
      vendorpo: data['VENDORPO'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aedat': aedat,
      'ebeln': ebeln,
      'group': group,
      'lifnr': lifnr,
      'clientid': clientid,
      'ernam': ernam,
      'T_DATA': tData?.map((e) => e.toJson()).toList(),
      'mblnr': mblnr,
      'approvedate': approvedate,
      'issync': issync,
      'orgid': orgid,
      'created': created,
      'createdby': createdby,
      'updated': updated,
      'updatedby': updatedby,
      'doctype': doctype,
      'werks': werks,
      'lgort': lgort,
      'dlv_comp': dlvComp,
      'bwart': bwart,
      'truck': truck,
      'invoiceno': invoiceno,
      'vendorpo': vendorpo,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
