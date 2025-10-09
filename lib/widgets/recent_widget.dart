import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/weborder_view_model.dart';
import 'package:intl/intl.dart';

class RecentWidget extends StatelessWidget {
  final int index;
  final IconData? icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final double height;

  final NumberFormat currency = NumberFormat("#,###", "en_US");
  final WeborderVM weborderVM = Get.find();
  final GlobalVM globalVM = Get.find();

  RecentWidget({
    super.key,
    required this.index,
    this.icon,
    this.elevation = 9,
    this.iconSize = 0.10,
    this.fontSize = 14.0,
    this.height = 40,
  });

  Color _getHeaderColor() {
    switch (weborderVM.choiceWO.value) {
      case "FZ":
        return Colors.blue;
      case "CH":
        return Colors.green;
      default:
        return const Color(0xfff44236);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseWidth = 360;
    final double fem = MediaQuery.of(context).size.width / baseWidth;
    final double ffem = fem * 0.97;

    final currentItem = weborderVM.tolistWO[index];

    return Container(
      width: 155 * fem,
      height: 100 * fem,
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
                currentItem.inventoryGroup ?? '',
                textAlign: TextAlign.center,
                style: _getTextStyle(ffem, fem, isHeader: true),
              ),
            ),
          ),

          // Delivery Date Section
          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 4 * fem, 0, 2 * fem),
            child: RichText(
              text: TextSpan(
                style: _getTextStyle(ffem, fem),
                children: [
                  const TextSpan(text: 'Delivery Date:   '),
                  TextSpan(
                    text: globalVM.dateToString(currentItem.deliveryDate ?? ''),
                    style: _getTextStyle(ffem, fem, isBold: false),
                  ),
                ],
              ),
            ),
          ),

          // Total Item Section
          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 2 * fem),
            child: RichText(
              text: TextSpan(
                style: _getTextStyle(ffem, fem),
                children: [
                  const TextSpan(text: 'Total Item:         '),
                  TextSpan(
                    text: '${currentItem.totalItem}',
                    style: _getTextStyle(ffem, fem, isBold: false),
                  ),
                ],
              ),
            ),
          ),

          // Total Quantity Section
          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 0, 0, 4 * fem),
            constraints: BoxConstraints(maxWidth: 130 * fem),
            child: RichText(
              text: TextSpan(
                style: _getTextStyle(ffem, fem),
                children: [
                  const TextSpan(text: 'Total Quantity:  '),
                  TextSpan(
                    text: currentItem.item ?? '',
                    style: _getTextStyle(ffem, fem, isBold: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(
    double ffem,
    double fem, {
    bool isBold = true,
    bool isHeader = false,
  }) {
    if (isHeader) {
      return TextStyle(
        fontSize: 16 * ffem,
        fontWeight: FontWeight.w600,
        height: 1.1725 * ffem / fem,
        color: Colors.white,
      );
    }

    return TextStyle(
      fontSize: 12 * ffem,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      height: 1.1725 * ffem / fem,
      color: const Color(0xff3d3d3d),
    );
  }
}
