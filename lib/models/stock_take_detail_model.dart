import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class StockTakeDetailModel {
  final String? werks; // Factory
  final String? matnr; // Material number
  final double labst; // Stock in storage
  final String? lgort; // Storage location
  final double insme; // Reserved field
  final double speme; // Reserved field
  final String? normt; // Standard text
  final String? meins; // Base unit of measure
  final String? matkl; // Material group
  final String maktx; // Material description
  final String isApprove;
  final String selectedChoice;
  final List<Marm>? marm; // List of material unit conversion
  final ValueNotifier<bool> checkboxValidation;

  // PERBAIKAN: Tambahkan properti yang hilang dengan nilai default
  final String NORMT;
  final String MATNR;
  final String MAKTX;

  static final _logger = Logger();

  StockTakeDetailModel({
    this.werks,
    String? matnr,
    required this.labst,
    this.lgort,
    required this.insme,
    required this.speme,
    String? normt,
    this.meins,
    this.matkl,
    required String maktx,
    required this.isApprove,
    required this.selectedChoice,
    this.marm,
    ValueNotifier<bool>? checkboxValidation,
  }) : // PERBAIKAN: Inisialisasi di initializer list
       matnr = matnr ?? '',
       normt = normt ?? '',
       maktx = maktx,
       MATNR = matnr ?? '', // Set MATNR sama dengan matnr
       NORMT = normt ?? '', // Set NORMT sama dengan normt
       MAKTX = maktx, // Set MAKTX sama dengan maktx
       checkboxValidation = checkboxValidation ?? ValueNotifier<bool>(false);

  Map<String, dynamic> toMap() {
    try {
      return {
        'WERKS': werks ?? '',
        'MATNR': matnr ?? '',
        'LABST': labst,
        'LGORT': lgort ?? '',
        'INSME': insme,
        'SPEME': speme,
        'NORMT': normt ?? '',
        'MEINS': meins ?? '',
        'MATKL': matkl ?? '',
        'MAKTX': maktx,
        'isapprove': isApprove,
        'selectedChoice': selectedChoice,
        'MARM': marm?.map((e) => e.toMap()).toList(),
        'checkboxvalidation': checkboxValidation.value,
      };
    } catch (e) {
      _logger.e('Error in toMap: $e');
      return {};
    }
  }

  factory StockTakeDetailModel.fromJson(Map<String, dynamic> data) {
    try {
      final marmList = data['MARM'] != null
          ? List<Marm>.from((data['MARM'] as List).map((x) => Marm.fromJson(x)))
          : null;

      return StockTakeDetailModel(
        werks: data['WERKS'] as String? ?? '',
        matnr: data['MATNR'] as String? ?? '',
        labst: (data['LABST'] as num?)?.toDouble() ?? 0.0,
        lgort: data['LGORT'] as String? ?? '',
        insme: (data['INSME'] as num?)?.toDouble() ?? 0.0,
        speme: (data['SPEME'] as num?)?.toDouble() ?? 0.0,
        normt: data['NORMT'] as String? ?? '',
        meins: data['MEINS'] as String? ?? '',
        matkl: data['MATKL'] as String? ?? '',
        maktx: (data['MAKTX'] as String?)?.trim() ?? 'No description',
        isApprove: data['isapprove'] as String? ?? '',
        selectedChoice: data['selectedChoice'] as String? ?? 'UU',
        marm: marmList,
        checkboxValidation: ValueNotifier<bool>(
          data['checkboxvalidation'] as bool? ?? false,
        ),
      );
    } catch (e) {
      _logger.e('Error in fromJson: $e');
      return StockTakeDetailModel(
        labst: 0.0,
        insme: 0.0,
        speme: 0.0,
        maktx: 'No description',
        isApprove: '',
        selectedChoice: 'UU',
      );
    }
  }

  factory StockTakeDetailModel.fromDocumentSnapshot(
    DocumentSnapshot documentSnapshot,
  ) {
    try {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      return StockTakeDetailModel.fromJson(data);
    } catch (e) {
      _logger.e('Error in fromDocumentSnapshot: $e');
      return StockTakeDetailModel(
        labst: 0.0,
        insme: 0.0,
        speme: 0.0,
        maktx: 'No description',
        isApprove: '',
        selectedChoice: 'UU',
      );
    }
  }

  StockTakeDetailModel copyWith({
    String? werks,
    String? matnr,
    double? labst,
    String? lgort,
    double? insme,
    double? speme,
    String? normt,
    String? meins,
    String? matkl,
    String? maktx,
    String? isApprove,
    String? selectedChoice,
    List<Marm>? marm,
    ValueNotifier<bool>? checkboxValidation,
  }) {
    return StockTakeDetailModel(
      werks: werks ?? this.werks,
      matnr: matnr ?? this.matnr,
      labst: labst ?? this.labst,
      lgort: lgort ?? this.lgort,
      insme: insme ?? this.insme,
      speme: speme ?? this.speme,
      normt: normt ?? this.normt,
      meins: meins ?? this.meins,
      matkl: matkl ?? this.matkl,
      maktx: maktx ?? this.maktx,
      isApprove: isApprove ?? this.isApprove,
      selectedChoice: selectedChoice ?? this.selectedChoice,
      marm: marm ?? this.marm?.map((e) => e.copyWith()).toList(),
      checkboxValidation: checkboxValidation ?? this.checkboxValidation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTakeDetailModel &&
        other.werks == werks &&
        other.matnr == matnr &&
        other.labst == labst &&
        other.lgort == lgort;
  }

  @override
  int get hashCode {
    return Object.hash(werks, matnr, labst, lgort);
  }
}

class Marm {
  final String? matnr;
  final String? umrez;
  final String? umren;
  final String? meinh;

  static final _logger = Logger();

  const Marm({this.matnr, this.umrez, this.umren, this.meinh});

  Map<String, dynamic> toMap() {
    return {
      'MATNR': matnr ?? '',
      'UMREZ': umrez ?? '',
      'UMREN': umren ?? '',
      'MEINH': meinh ?? '',
    };
  }

  factory Marm.fromJson(Map<String, dynamic> json) {
    try {
      return Marm(
        matnr: json['MATNR'] as String? ?? '',
        umrez: json['UMREZ'] as String? ?? '',
        umren: json['UMREN'] as String? ?? '',
        meinh: json['MEINH'] as String? ?? '',
      );
    } catch (e) {
      _logger.e('Error in Marm.fromJson: $e');
      return const Marm();
    }
  }

  Marm copyWith({String? matnr, String? umrez, String? umren, String? meinh}) {
    return Marm(
      matnr: matnr ?? this.matnr,
      umrez: umrez ?? this.umrez,
      umren: umren ?? this.umren,
      meinh: meinh ?? this.meinh,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Marm &&
        other.matnr == matnr &&
        other.umrez == umrez &&
        other.umren == umren &&
        other.meinh == meinh;
  }

  @override
  int get hashCode {
    return Object.hash(matnr, umrez, umren, meinh);
  }
}
