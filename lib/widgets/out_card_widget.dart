import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/models/details_out_model.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/stock_request_view_model.dart';
import 'package:immobile_app_fixed/view_models/weborder_view_model.dart';
import 'package:intl/intl.dart';

class OutCard extends StatelessWidget {
  final int index;
  final IconData? icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final NumberFormat currency = NumberFormat("#,###", "en_US");
  final double height;
  final String? choice;
  final String? category;

  final WeborderVM weborderVM = Get.find();
  final GlobalVM globalVM = Get.find();
  final StockRequestVM stockrequestVM = Get.find();

  OutCard({
    super.key,
    required this.index,
    this.icon,
    this.elevation = 9,
    this.iconSize = 0.10,
    this.fontSize = 14.0,
    this.height = 40,
    this.choice,
    this.category,
  });

  String _calcuCTN() {
    try {
      List<DetailItem> listbyinventorygroup = [];
      double total = 0;

      if (category == "ALL") {
        listbyinventorygroup =
            stockrequestVM.srOutList[index].detail?.toList() ?? [];
      } else {
        listbyinventorygroup =
            stockrequestVM.srOutList[index].detail
                ?.where((element) => element.inventoryGroup == category)
                .toList() ??
            [];
      }

      for (final element in listbyinventorygroup) {
        final listbyuom = element.uom.where((uom) => uom.uom == "CTN").toList();
        if (listbyuom.isNotEmpty) {
          for (final uomItem in listbyuom) {
            total += double.tryParse(uomItem.totalItem) ?? 0;
          }
        }
      }

      return total.toInt().toString();
    } catch (e) {
      debugPrint('Error in _calcuCTN: $e');
      return '0';
    }
  }

  int calcuforcolour() {
    int ab;
    int ch;
    int fz;

    if (weborderVM.choiceout.value != "ALL") {
      ab =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isEmpty &&
                    element.inventoryGroup == "AB",
              )
              .length ??
          0;
      ch =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isEmpty &&
                    element.inventoryGroup == "CH",
              )
              .length ??
          0;
      fz =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isEmpty &&
                    element.inventoryGroup == "FZ",
              )
              .length ??
          0;
    } else {
      ab =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isNotEmpty &&
                    element.inventoryGroup == "AB",
              )
              .length ??
          0;
      ch =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isNotEmpty &&
                    element.inventoryGroup == "CH",
              )
              .length ??
          0;
      fz =
          stockrequestVM.srOutList[index].detail
              ?.where(
                (element) =>
                    element.approveName.isNotEmpty &&
                    element.inventoryGroup == "FZ",
              )
              .length ??
          0;
    }

    ab = ab > 0 ? 1 : 0;
    ch = ch > 0 ? 1 : 0;
    fz = fz > 0 ? 1 : 0;

    return ab + ch + fz;
  }

  String _calcuPCS() {
    try {
      double total = 0;

      if (category == "ALL") {
        for (final element in stockrequestVM.srOutList[index].detail ?? []) {
          final listbyuom = element.uom
              .where((uom) => uom.uom == "PCS")
              .toList();
          if (listbyuom.isNotEmpty) {
            for (final uomItem in listbyuom) {
              total += double.tryParse(uomItem.totalItem) ?? 0;
            }
          }
        }
      } else {
        final listbyinventorygroup =
            stockrequestVM.srOutList[index].detail
                ?.where((element) => element.inventoryGroup == category)
                .toList() ??
            [];
        for (final element in listbyinventorygroup) {
          final listbyuom = element.uom
              .where((uom) => uom.uom == "PCS")
              .toList();
          if (listbyuom.isNotEmpty) {
            for (final uomItem in listbyuom) {
              total += double.tryParse(uomItem.totalItem) ?? 0;
            }
          }
        }
      }

      return total.toInt().toString();
    } catch (e) {
      debugPrint('Error in _calcuPCS: $e');
      return '0';
    }
  }

  String _calculTotal() {
    try {
      final calcuCTN = _calcuCTN();
      return '$calcuCTN CTN';
    } catch (e) {
      debugPrint('Error in _CalculTotal: $e');
      return '0 CTN';
    }
  }

  String _calcutotalpcs() {
    try {
      final calcuPCS = _calcuPCS();
      return '$calcuPCS PCS';
    } catch (e) {
      debugPrint('Error in _calcutotalpcs: $e');
      return '0 PCS';
    }
  }

  InlineSpan getInlineSpan(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isEmpty &&
                      element.inventoryGroup == "AB",
                )
                .isNotEmpty ??
            false)) {
      return const WidgetSpan(
        child: CircleAvatar(backgroundColor: Colors.red, radius: 5.5),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isNotEmpty &&
                      element.inventoryGroup == "AB",
                )
                .isNotEmpty ??
            false)) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_red.png', width: 13, height: 13),
      );
    } else {
      return const TextSpan(text: '');
    }
  }

  InlineSpan getInlineSpanCH(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isEmpty &&
                      element.inventoryGroup == "CH",
                )
                .isNotEmpty ??
            false)) {
      return const WidgetSpan(
        child: CircleAvatar(backgroundColor: Colors.green, radius: 5.5),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isNotEmpty &&
                      element.inventoryGroup == "CH",
                )
                .isNotEmpty ??
            false)) {
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

  InlineSpan getInlineSpanFZ(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isEmpty &&
                      element.inventoryGroup == "FZ",
                )
                .isNotEmpty ??
            false)) {
      return const WidgetSpan(
        child: CircleAvatar(backgroundColor: Colors.blue, radius: 5.5),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        (stockrequestVM.srOutList[index].detail
                ?.where(
                  (element) =>
                      element.approveName.isNotEmpty &&
                      element.inventoryGroup == "FZ",
                )
                .isNotEmpty ??
            false)) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_blue.png', width: 13, height: 13),
      );
    } else {
      return const TextSpan(text: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseWidth = 360;
    final double fem = MediaQuery.of(context).size.width / baseWidth;
    final double ffem = fem * 0.97;

    final isWO = choice == "WO";
    final currentItem = isWO
        ? weborderVM.tolistwoout[index]
        : stockrequestVM.srOutList[index];

    return Container(
      width: double.infinity,
      height: 200 * fem,
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
          // Header Section
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
                isWO
                    ? currentItem.location ?? ''
                    : currentItem.documentNo ?? '',
                textAlign: TextAlign.center,
                style: _getHeaderTextStyle(ffem, fem),
              ),
            ),
          ),

          // Date Section
          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 8 * fem, 0, 4 * fem),
            child: RichText(
              text: TextSpan(
                style: _getTextStyle(ffem, fem),
                children: [
                  TextSpan(
                    text: isWO ? 'Delivery Date:   ' : 'Request Date:   ',
                  ),
                  TextSpan(
                    text: _getDateText(isWO, currentItem),
                    style: _getTextStyle(ffem, fem, isBold: false),
                  ),
                ],
              ),
            ),
          ),

          // Quantity Section
          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 0),
            constraints: BoxConstraints(maxWidth: 150 * fem),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12 * fem),
                  child: RichText(
                    text: TextSpan(
                      text: 'Total Quantity:  ',
                      style: _getTextStyle(ffem, fem),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWO ? currentItem.item ?? '' : _calculTotal(),
                      style: _getTextStyle(ffem, fem, isBold: false),
                    ),
                    if (!isWO) ...[
                      SizedBox(height: 2 * fem),
                      Text(
                        _calcutotalpcs(),
                        style: _getTextStyle(ffem, fem, isBold: false),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Status Indicators (only for non-WO)
          if (choice != "WO") ...[
            SizedBox(height: 8 * fem),
            Container(
              margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 0),
              constraints: BoxConstraints(maxWidth: 150 * fem),
              child: RichText(
                text: TextSpan(
                  style: _getTextStyle(ffem, fem),
                  children: [
                    getInlineSpan(index),
                    const TextSpan(text: ' '),
                    getInlineSpanCH(index),
                    const TextSpan(text: ' '),
                    getInlineSpanFZ(index),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getHeaderColor() {
    if (category == "FZ") return Colors.blue;
    if (category == "CH") return Colors.green;
    if (weborderVM.choiceout.value == "ALL") return Colors.orange;
    return const Color(0xfff44236);
  }

  TextStyle _getHeaderTextStyle(double ffem, double fem) {
    return TextStyle(
      fontSize: 16 * ffem,
      fontWeight: FontWeight.w600,
      height: 1.1725 * ffem / fem,
      color: Colors.white,
    );
  }

  TextStyle _getTextStyle(double ffem, double fem, {bool isBold = true}) {
    return TextStyle(
      fontSize: 12 * ffem,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      height: 1.1725 * ffem / fem,
      color: const Color(0xff3d3d3d),
    );
  }

  String _getDateText(bool isWO, dynamic currentItem) {
    if (isWO) {
      return globalVM.dateToString(currentItem.deliveryDate ?? '');
    } else {
      final dateString = globalVM.dateToString(currentItem.deliveryDate ?? '');
      final timeString = (currentItem.deliveryDate?.length ?? 0) > 11
          ? currentItem.deliveryDate!.substring(11)
          : '';
      return timeString.isNotEmpty
          ? '$dateString\n                            $timeString'
          : dateString;
    }
  }
}

// Helper function untuk font (jika diperlukan)
TextStyle safeGoogleFont(
  String fontFamily, {
  required double fontSize,
  required FontWeight fontWeight,
  required double height,
  required Color color,
}) {
  return TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    color: color,
  );
}
