import 'package:flutter/foundation.dart';
import 'detail_double_out_model.dart';

class DetailItem {
  final String itemCode;
  final String itemName;
  final String itemImage;
  final List<DetailDouble> uom;
  final String compatible;
  final String requiredString;
  final String isSame;
  final String inventoryGroup;
  final String isApprove;
  final String approveName;
  final String updatedAt;
  final String orderId;

  const DetailItem({
    this.itemCode = '',
    this.itemName = '',
    this.itemImage = '',
    this.uom = const [],
    this.compatible = '',
    this.requiredString = '',
    this.isSame = '',
    this.inventoryGroup = '',
    this.isApprove = '',
    this.approveName = '',
    this.updatedAt = '',
    this.orderId = '',
  });

  factory DetailItem.fromJson(Map<String, dynamic> data) {
    List<DetailDouble> uomList = const [];

    try {
      if (data['uom_data'] is List) {
        uomList = (data['uom_data'] as List)
            .map<DetailDouble>((item) => DetailDouble.fromJson(item))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing uom_data: $e');
      }
    }

    return DetailItem(
      itemCode: data['item_code']?.toString() ?? '',
      itemName: data['item_name']?.toString() ?? '',
      itemImage: data['item_image']?.toString() ?? '',
      uom: uomList,
      compatible: data['compatible']?.toString() ?? '',
      requiredString: data['required']?.toString() ?? '',
      isSame: data['isSame']?.toString() ?? '',
      inventoryGroup: data['inventory_group']?.toString() ?? '',
      isApprove: data['isapprove']?.toString() ?? '',
      approveName: data['approvename']?.toString() ?? '',
      updatedAt: data['updatedat']?.toString() ?? '',
      orderId: data['order_id']?.toString() ?? '',
    );
  }

  DetailItem copyWith({
    String? itemCode,
    String? itemName,
    String? itemImage,
    List<DetailDouble>? uom,
    String? compatible,
    String? requiredString,
    String? isSame,
    String? inventoryGroup,
    String? isApprove,
    String? approveName,
    String? updatedAt,
    String? orderId,
  }) {
    return DetailItem(
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemImage: itemImage ?? this.itemImage,
      uom: uom ?? this.uom,
      compatible: compatible ?? this.compatible,
      requiredString: requiredString ?? this.requiredString,
      isSame: isSame ?? this.isSame,
      inventoryGroup: inventoryGroup ?? this.inventoryGroup,
      isApprove: isApprove ?? this.isApprove,
      approveName: approveName ?? this.approveName,
      updatedAt: updatedAt ?? this.updatedAt,
      orderId: orderId ?? this.orderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'item_image': itemImage,
      'uom_data': uom.map((element) => element.toMap()).toList(),
      'compatible': compatible,
      'required': requiredString,
      'isSame': isSame,
      'inventory_group': inventoryGroup,
      'isapprove': isApprove,
      'approvename': approveName,
      'updatedat': updatedAt,
      'order_id': orderId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'DetailItem(itemCode: $itemCode, itemName: $itemName, itemImage: $itemImage, uom: $uom, compatible: $compatible, requiredString: $requiredString, isSame: $isSame, inventoryGroup: $inventoryGroup, isApprove: $isApprove, approveName: $approveName, updatedAt: $updatedAt, orderId: $orderId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DetailItem &&
        other.itemCode == itemCode &&
        other.itemName == itemName &&
        other.itemImage == itemImage &&
        listEquals(other.uom, uom) &&
        other.compatible == compatible &&
        other.requiredString == requiredString &&
        other.isSame == isSame &&
        other.inventoryGroup == inventoryGroup &&
        other.isApprove == isApprove &&
        other.approveName == approveName &&
        other.updatedAt == updatedAt &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    return Object.hash(
      itemCode,
      itemName,
      itemImage,
      Object.hashAll(uom),
      compatible,
      requiredString,
      isSame,
      inventoryGroup,
      isApprove,
      approveName,
      updatedAt,
      orderId,
    );
  }
}
