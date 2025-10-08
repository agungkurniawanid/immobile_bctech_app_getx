import 'dart:convert';

class Item {
  String? pcs;
  String? uom;

  Item({this.pcs, this.uom});

  /// Factory constructor untuk membuat instance dari JSON
  factory Item.fromJson(Map<String, dynamic> data) {
    return Item(
      pcs: data['total']?.toString() ?? '', // pastikan jadi string aman
      uom: data['uom'] ?? '',
    );
  }

  /// Konversi ke Map (jika ingin dikirim ke Firestore atau API)
  Map<String, dynamic> toJson() {
    return {'pcs': pcs, 'uom': uom};
  }

  /// Convert ke JSON string
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'pcs: $pcs, uom: $uom';
}
