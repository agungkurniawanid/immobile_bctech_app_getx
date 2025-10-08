import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // for ValueNotifier

class StockTakeDetailModel {
  String WERKS;        // Factory
  String MATNR;        // Material number
  double LABST;        // Stock in storage
  String LGORT;        // Storage location
  double INSME;        // Reserved field
  double SPEME;        // Reserved field
  String NORMT;        // Standard text
  String MEINS;        // Base unit of measure
  String MATKL;        // Material group
  String MAKTX;        // Material description
  String isapprove;
  String selectedChoice;
  List<Marm> MARM;     // List of material unit conversion
  ValueNotifier<bool> checkboxvalidation; // New field

  StockTakeDetailModel({
    this.WERKS,
    this.MATNR,
    this.LABST,
    this.LGORT,
    this.INSME,
    this.SPEME,
    this.NORMT,
    this.MEINS,
    this.MATKL,
    this.MAKTX,
    this.isapprove,
    this.selectedChoice,
    this.MARM,
    ValueNotifier<bool> checkboxvalidation,
  }) : checkboxvalidation = checkboxvalidation ?? ValueNotifier<bool>(false);

  Map<String, dynamic> toMap() {
    try {
      return {
        'WERKS': WERKS,
        'MATNR': MATNR,
        'LABST': LABST,
        'LGORT': LGORT,
        'INSME': INSME,
        'SPEME': SPEME,
        'NORMT': NORMT,
        'MEINS': MEINS,
        'MATKL': MATKL,
        'MAKTX': MAKTX ?? "",
        'isapprove': isapprove ?? "",
        'selectedChoice': selectedChoice ?? "UU",
        'MARM': MARM?.map((e) => e.toMap())?.toList(),
        'checkboxvalidation': checkboxvalidation.value, // Optional: include in map
      };
    } catch (e) {
      print(e);
      return null;
    }
  }

  factory StockTakeDetailModel.fromJson(Map<String, dynamic> data) {
    try {
      var marmList = data['MARM'] != null
          ? List<Marm>.from(data['MARM'].map((x) => Marm.fromJson(x)))
          : null;

      return StockTakeDetailModel(
        WERKS: data['WERKS'] ?? "",
        MATNR: data['MATNR'] ?? "",
        LABST: data['LABST']?.toDouble() ?? 0.0,
        LGORT: data['LGORT'] ?? "",
        INSME: data['INSME']?.toDouble() ?? 0,
        SPEME: data['SPEME']?.toDouble() ?? 0,
        NORMT: data['NORMT'] ?? "",
        MEINS: data['MEINS'] ?? "",
        MATKL: data['MATKL'] ?? "",
        MAKTX: data['MAKTX']?.trim() ?? "No description",
        isapprove: data['isapprove'] ?? "",
        selectedChoice: data['selectedChoice'] ?? "UU",
        MARM: marmList,
        checkboxvalidation: ValueNotifier<bool>(data['checkboxvalidation'] ?? false),
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  StockTakeDetailModel clone() {
    return StockTakeDetailModel(
      WERKS: this.WERKS,
      MATNR: this.MATNR,
      LABST: this.LABST,
      LGORT: this.LGORT,
      INSME: this.INSME,
      SPEME: this.SPEME,
      NORMT: this.NORMT,
      MEINS: this.MEINS,
      MATKL: this.MATKL,
      MAKTX: this.MAKTX,
      isapprove: this.isapprove,
      selectedChoice: this.selectedChoice,
      MARM: this.MARM?.map((e) => e.clone())?.toList(),
      checkboxvalidation: ValueNotifier<bool>(this.checkboxvalidation.value),
    );
  }

  StockTakeDetailModel.fromDocumentSnapshot({ DocumentSnapshot documentSnapshot}) {
    try {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      var marmList = data['MARM'] != null
          ? List<Marm>.from(data['MARM'].map((x) => Marm.fromJson(x)))
          : null;

      WERKS = data['WERKS'] ?? "";
      MATNR = data['MATNR'] ?? "";
      LABST = data['LABST']?.toDouble() ?? 0.0;
      LGORT = data['LGORT'] ?? "";
      INSME = data['INSME']?.toDouble() ?? 0;
      SPEME = data['SPEME']?.toDouble() ?? 0;
      NORMT = data['NORMT'] ?? "";
      MEINS = data['MEINS'] ?? "";
      MATKL = data['MATKL'] ?? "";
      isapprove = data['isapprove'] ?? "";
      selectedChoice = data['selectedChoice'] ?? "UU";
      MAKTX = data['MAKTX']?.trim() ?? "No description";
      MARM = marmList;
      checkboxvalidation = ValueNotifier<bool>(data['checkboxvalidation'] ?? false);
    } catch (e) {
      print(e);
    }
  }
}

class Marm {
  String MATNR;
  String UMREZ;
  String UMREN;
  String MEINH;

  Marm({
    this.MATNR,
    this.UMREZ,
    this.UMREN,
    this.MEINH,
  });

  Map<String, dynamic> toMap() {
    return {
      'MATNR': MATNR,
      'UMREZ': UMREZ,
      'UMREN': UMREN,
      'MEINH': MEINH,
    };
  }

  factory Marm.fromJson(Map<String, dynamic> json) {
    return Marm(
      MATNR: json['MATNR'] ?? "",
      UMREZ: json['UMREZ'] ?? "",
      UMREN: json['UMREN'] ?? "",
      MEINH: json['MEINH'] ?? "",
    );
  }

  Marm clone() {
    return Marm(
      MATNR: this.MATNR,
      UMREZ: this.UMREZ,
      UMREN: this.UMREN,
      MEINH: this.MEINH,
    );
  }
}
