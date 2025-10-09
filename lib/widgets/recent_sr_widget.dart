import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/models/details_out_model.dart';
import 'package:intl/intl.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/stock_request_view_model.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';

class RecentSR extends StatelessWidget {
  final int index;
  final IconData? icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final double height;
  final NumberFormat currency = NumberFormat("#,###", "en_US");
  final StockRequestVM stockRequestVM = Get.find();
  final GlobalVM globalVM = Get.find();

  RecentSR({
    super.key,
    required this.index,
    this.icon,
    this.elevation = 9,
    this.iconSize = 0.10,
    this.fontSize = 14.0,
    this.height = 40,
  });

  String _calculateCTN() {
    try {
      List<DetailItem> listByInventoryGroup;
      double total = 0;

      final details = stockRequestVM.srOutList[index].detail ?? [];

      if (GlobalVar.choicecategory == 'ALL') {
        listByInventoryGroup = details.toList();
      } else {
        listByInventoryGroup = details
            .where(
              (element) =>
                  element.inventoryGroup.contains(GlobalVar.choicecategory),
            )
            .toList();
      }

      for (final detail in listByInventoryGroup) {
        final listByUOM = detail.uom
            .where((element) => element.uom == "CTN")
            .toList();
        if (listByUOM.isNotEmpty) {
          for (final uom in listByUOM) {
            total += double.tryParse(uom.totalItem) ?? 0;
          }
        }
      }

      return total.toInt().toString();
    } catch (e) {
      debugPrint('Error calculating CTN: $e');
      return "0";
    }
  }

  String _calculatePCS() {
    try {
      double total = 0;
      final details = stockRequestVM.srOutList[index].detail ?? [];

      if (GlobalVar.choicecategory == 'ALL') {
        for (final detail in details) {
          final listByUOM = detail.uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (listByUOM.isNotEmpty) {
            for (final uom in listByUOM) {
              total += double.tryParse(uom.totalItem) ?? 0;
            }
          }
        }
      } else {
        final listByInventoryGroup = details
            .where(
              (element) =>
                  element.inventoryGroup.contains(GlobalVar.choicecategory),
            )
            .toList();

        for (final detail in listByInventoryGroup) {
          final listByUOM = detail.uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (listByUOM.isNotEmpty) {
            for (final uom in listByUOM) {
              total += double.tryParse(uom.totalItem) ?? 0;
            }
          }
        }
      }

      return total.toInt().toString();
    } catch (e) {
      debugPrint('Error calculating PCS: $e');
      return "0";
    }
  }

  String _calculateTotalCTN() {
    try {
      final calcuCTN = _calculateCTN();
      return '$calcuCTN CTN';
    } catch (e) {
      debugPrint('Error calculating total CTN: $e');
      return '0 CTN';
    }
  }

  String _calculateTotalPCS() {
    try {
      final calcuPCS = _calculatePCS();
      return '$calcuPCS PCS';
    } catch (e) {
      debugPrint('Error calculating total PCS: $e');
      return '0 PCS';
    }
  }

  InlineSpan _buildInlineSpanAB(int index) {
    final details = stockRequestVM.srOutList[index].detail ?? [];

    if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isEmpty) &&
              element.inventoryGroup.contains("AB"),
        )) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      );
    } else if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isNotEmpty) &&
              element.inventoryGroup.contains("AB"),
        )) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_red.png', width: 13, height: 13),
      );
    } else {
      return const TextSpan(text: '');
    }
  }

  InlineSpan _buildInlineSpanCH(int index) {
    final details = stockRequestVM.srOutList[index].detail ?? [];

    if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isEmpty) &&
              element.inventoryGroup.contains("CH"),
        )) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        ),
      );
    } else if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isNotEmpty) &&
              element.inventoryGroup.contains("CH"),
        )) {
      return WidgetSpan(
        child: Image.asset(
          'data/images/stars_green.png',
          width: 13,
          height: 13,
        ),
      );
    } else {
      return const TextSpan(text: '');
    }
  }

  InlineSpan _buildInlineSpanFZ(int index) {
    final details = stockRequestVM.srOutList[index].detail ?? [];

    if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isEmpty) &&
              element.inventoryGroup.contains("FZ"),
        )) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      );
    } else if (globalVM.choicecategory.value == "ALL" &&
        details.any(
          (element) =>
              (element.approveName.isNotEmpty) &&
              element.inventoryGroup.contains("FZ"),
        )) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_blue.png', width: 13, height: 13),
      );
    } else {
      return const TextSpan(text: '');
    }
  }

  Color _getHeaderColor() {
    switch (globalVM.choicecategory.value) {
      case "FZ":
        return Colors.blue;
      case "CH":
        return Colors.green;
      case "ALL":
        return Colors.orange;
      default:
        return const Color(0xfff44236);
    }
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return '-';

      final formats = [
        DateFormat('yyyy-MM-dd'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('MM/dd/yyyy'),
      ];

      DateTime? parsedDate;
      for (final format in formats) {
        try {
          parsedDate = format.parse(dateString);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate != null) {
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }

      return dateString;
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseWidth = 360;
    final double fem = MediaQuery.of(context).size.width / baseWidth;
    final double ffem = fem * 0.97;

    // Safety check untuk index
    if (index < 0 || index >= stockRequestVM.srOutList.length) {
      return Container();
    }

    final outModel = stockRequestVM.srOutList[index];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 155 * fem,
          height: 110 * fem,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8 * fem),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: Offset(0 * fem, 4 * fem),
                blurRadius: 5 * fem,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 31 * fem,
                decoration: BoxDecoration(
                  color: _getHeaderColor(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8 * fem),
                    topRight: Radius.circular(8 * fem),
                  ),
                ),
                child: Center(
                  child: Text(
                    outModel.documentNo ?? '-',
                    textAlign: TextAlign.center,
                    style: _buildTextStyle(
                      ffem: ffem,
                      fem: fem,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              _buildInfoRow(
                fem: fem,
                ffem: ffem,
                label: 'Request Date:',
                value: _formatDate(outModel.deliveryDate ?? ''),
              ),

              _buildInfoRow(
                fem: fem,
                ffem: ffem,
                label: 'Total Item:',
                value: outModel.totalItem?.toString() ?? '0',
              ),

              Container(
                margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 0),
                constraints: BoxConstraints(maxWidth: 150 * fem),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12 * fem),
                      child: RichText(
                        text: TextSpan(
                          style: _buildTextStyle(
                            ffem: ffem,
                            fem: fem,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff3d3d3d),
                          ),
                          children: const [TextSpan(text: 'Total Quantity:  ')],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _calculateTotalCTN(),
                          style: _buildTextStyle(
                            ffem: ffem,
                            fem: fem,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff3d3d3d),
                          ),
                        ),
                        Text(
                          _calculateTotalPCS(),
                          style: _buildTextStyle(
                            ffem: ffem,
                            fem: fem,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff3d3d3d),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 0),
                constraints: BoxConstraints(maxWidth: 150 * fem),
                child: RichText(
                  text: TextSpan(
                    style: _buildTextStyle(
                      ffem: ffem,
                      fem: fem,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff3d3d3d),
                    ),
                    children: [
                      _buildInlineSpanAB(index),
                      const TextSpan(text: ' '),
                      _buildInlineSpanCH(index),
                      const TextSpan(text: ' '),
                      _buildInlineSpanFZ(index),
                      const TextSpan(text: ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required double fem,
    required double ffem,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 4 * fem),
      child: RichText(
        text: TextSpan(
          style: _buildTextStyle(
            ffem: ffem,
            fem: fem,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xff3d3d3d),
          ),
          children: [
            TextSpan(text: '$label   '),
            TextSpan(
              text: value,
              style: _buildTextStyle(
                ffem: ffem,
                fem: fem,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xff3d3d3d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _buildTextStyle({
    required double ffem,
    required double fem,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize * ffem,
      fontWeight: fontWeight,
      height: 1.1725 * ffem / fem,
      color: color,
    );
  }
}
