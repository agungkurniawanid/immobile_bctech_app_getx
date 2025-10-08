import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:immobile/config/globalVar.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:flutter/material.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/widget/utils.dart';

class RecentIn extends StatelessWidget {
  final int index;
  final IconData icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final currency = NumberFormat("#,###", "en_US");
  double height;

  InVM inVM = Get.find();
  GlobalVM globalVM = Get.find();

  RecentIn(
      {this.index,
      this.icon,
      this.elevation = 9,
      this.iconSize = 0.10,
      this.fontSize = 14.0,
      this.height = 40});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // woex1cHR (4:817)
          // padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
          width: 155 * fem,
          height: 110 * fem,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(8 * fem),
            boxShadow: [
              BoxShadow(
                color: Color(0x3f000000),
                offset: Offset(0 * fem, 4 * fem),
                blurRadius: 5 * fem,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // autogroupd6pk4v7 (UM5H3kTqHfqtnm2TNqD6pK)
                margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
                width: double.infinity,
                height: 31 * fem,
                decoration: BoxDecoration(
                  color: globalVM.choicecategory.value == "FZ"
                      ? Colors.blue
                      : globalVM.choicecategory.value == "CH"
                          ? Colors.green
                          : globalVM.choicecategory.value == "ALL"
                              ? Colors.orange
                              : Color(0xfff44236),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8 * fem),
                    topRight: Radius.circular(8 * fem),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${inVM.tolistPO[index].ebeln}',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
              Container(
                // totalitem3CHZ (4:822)
                margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 4 * fem),
                child: RichText(
                  text: TextSpan(
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff3d3d3d),
                    ),
                    children: [
                      // TextSpan(
                      //   text: 'Vendor:         ',
                      // ),
                      TextSpan(
                        text: inVM.tolistPO[index].lifnr.length > 42
                            ? 'Vendor:   ${inVM.tolistPO[index].lifnr.substring(0, 7)}' +
                                '\n' +
                                '${inVM.tolistPO[index].lifnr.substring(8, 43)}'
                            : inVM.tolistPO[index].lifnr
                                    .contains("Crown Pacific Investments")
                                ? 'Vendor:   ${inVM.tolistPO[index].lifnr.substring(0, 7)}' +
                                    '\n' +
                                    '${inVM.tolistPO[index].lifnr.substring(8, inVM.tolistPO[index].lifnr.length)}'
                                : inVM.tolistPO[index].lifnr
                                        .contains("Australian Fruit Juice")
                                    ? 'Vendor:   ${inVM.tolistPO[index].lifnr.substring(0, 7)}' +
                                        '\n' +
                                        '${inVM.tolistPO[index].lifnr.substring(8, inVM.tolistPO[index].lifnr.length)}'
                                    : 'Vendor:   ${inVM.tolistPO[index].lifnr}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.2175 * ffem / fem,
                          color: Color(0xff202020),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                // totalquantity60pcs48pakZXR (4:823)
                margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 0 * fem),
                constraints: BoxConstraints(
                  maxWidth: 130 * fem,
                ),
                child: RichText(
                  text: TextSpan(
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff3d3d3d),
                    ),
                    children: [
                      TextSpan(
                        text: 'Last Updated:  ',
                      ),
                      TextSpan(
                        text:
                            '${globalVM.stringToDateWithTime(inVM.tolistPO[index].created)}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff3d3d3d),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // SizedBox(
        //   width: 10 * fem,
        // ),
      ],
    );
  }
}
