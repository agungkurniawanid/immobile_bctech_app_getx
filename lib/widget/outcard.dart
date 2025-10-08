import 'package:get/get.dart';
import 'package:immobile/model/detailsout.dart';
import 'package:intl/intl.dart';
import 'package:immobile/config/globalVar.dart';
import 'package:immobile/viewmodel/webordervm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:flutter/material.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/widget/utils.dart';

class OutCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final currency = NumberFormat("#,###", "en_US");
  double height;
  String choice;
  String category;

  WeborderVM weborderVM = Get.find();

  GlobalVM globalVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();

  OutCard(
      {this.index,
      this.icon,
      this.elevation = 9,
      this.iconSize = 0.10,
      this.fontSize = 14.0,
      this.height = 40,
      this.choice,
      this.category});

  String _calcuCTN() {
    try {
      List<DetailItem> listbyinventorygroup = [];
      double total = 0;

      if (category == "ALL") {
        listbyinventorygroup =
            stockrequestVM.tolistsrout[index].detail.toList();
      } else {
        listbyinventorygroup = stockrequestVM.tolistsrout[index].detail
            .where((element) => element.inventory_group == category)
            .toList();
      }

      for (var j = 0; j < listbyinventorygroup.length; j++) {
        var listbyuom = listbyinventorygroup[j]
            .uom
            .where((element) => element.uom == "CTN")
            .toList();
        if (listbyuom.length == 0) {
        } else {
          for (var i = 0; i < listbyuom.length; i++) {
            total += double.tryParse(listbyuom[i].total_item) ?? 0;
          }
        }
      }
      int totalint = total.toInt();
      String totalstring = totalint.toString();
      return totalstring;
    } catch (e) {
      print(e);
    }
  }

  int calcuforcolour() {
    int ab;
    int ch;
    int fz;
    if (weborderVM.choiceout.value != "ALL") {
      ab = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename == "" && element.inventory_group == "AB")
          .toList()
          .length;
      ch = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename == "" && element.inventory_group == "CH")
          .toList()
          .length;
      fz = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename == "" && element.inventory_group == "FZ")
          .toList()
          .length;
    } else {
      ab = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename != "" && element.inventory_group == "AB")
          .toList()
          .length;
      ch = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename != "" && element.inventory_group == "CH")
          .toList()
          .length;
      fz = stockrequestVM.tolistsrout[index].detail
          .where((element) =>
              element.approvename != "" && element.inventory_group == "FZ")
          .toList()
          .length;
    }

    if (ab != 0) {
      ab = 1;
    }
    if (ch != 0) {
      ch = 1;
    }
    if (fz != 0) {
      fz = 1;
    }
    int calcu = ab + ch + fz;
    return calcu;
  }

  String _calcuPCS() {
    try {
      double total = 0;
      if (category == "ALL") {
        for (var j = 0;
            j < stockrequestVM.tolistsrout[index].detail.length;
            j++) {
          var listbyuom = stockrequestVM.tolistsrout[index].detail[j].uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (listbyuom.length == 0) {
          } else {
            for (var i = 0; i < listbyuom.length; i++) {
              total += double.tryParse(listbyuom[i].total_item) ?? 0;
            }
          }
        }
      } else {
        var listbyinventorygroup = stockrequestVM.tolistsrout[index].detail
            .where((element) => element.inventory_group == category)
            .toList();
        for (var j = 0; j < listbyinventorygroup.length; j++) {
          var listbyuom = listbyinventorygroup[j]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (listbyuom.length == 0) {
          } else {
            for (var i = 0; i < listbyuom.length; i++) {
              total += double.tryParse(listbyuom[i].total_item) ?? 0;
            }
          }
        }
      }

      int totalint = total.toInt();
      String totalstring = totalint.toString();
      return totalstring;
    } catch (e) {
      print(e);
    }
  }

  String _CalculTotal() {
    try {
      String calcuCTN = _calcuCTN();
      // String calcuPCS = _calcuPCS();
      String totalstring = calcuCTN + " CTN ";
      return totalstring;
    } catch (e) {
      print(e);
    }
  }

  String _calcutotalpcs() {
    try {
      String calcuPCS = _calcuPCS();
      String totalstring = calcuPCS + " PCS ";
      return totalstring;
    } catch (e) {
      print(e);
    }
  }

  InlineSpan getInlineSpan(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename == "" &&
                    element.inventory_group == "AB")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename != "" &&
                    element.inventory_group == "AB")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_red.png', width: 13, height: 13),
      );
    } else {
      return TextSpan(
        text: '',
      );
    }
  }

  InlineSpan getInlineSpanCH(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename == "" &&
                    element.inventory_group == "CH")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        ),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename != "" &&
                    element.inventory_group == "CH")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child:
            Image.asset('data/images/stars_green.png', width: 13, height: 13),
      );
    } else {
      return TextSpan(
        text: '',
      );
    }
  }

  InlineSpan getInlineSpanFZ(int index) {
    if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename == "" &&
                    element.inventory_group == "FZ")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      );
    } else if (weborderVM.choiceout.value == "ALL" &&
        stockrequestVM.tolistsrout[index].detail
                .where((element) =>
                    element.approvename != "" &&
                    element.inventory_group == "FZ")
                .toList()
                .length !=
            0) {
      return WidgetSpan(
        child: Image.asset('data/images/stars_blue.png', width: 13, height: 13),
      );
    } else {
      return TextSpan(
        text: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      // woex1cHR (4:817)
      // padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 6 * fem),
      width: double.infinity,
      height: 200 * fem,
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
              color: category == "FZ"
                  ? Colors.blue
                  : category == "CH"
                      ? Colors.green
                      : weborderVM.choiceout.value == "ALL"
                          ? Colors.orange
                          : Color(0xfff44236),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * fem),
                topRight: Radius.circular(8 * fem),
              ),
            ),
            child: Center(
              child: Text(
                choice == "WO"
                    ? '${weborderVM.tolistwoout[index].location}'
                    : '${stockrequestVM.tolistsrout[index].documentno}',
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
            // deliverydate14032022uQw (4:821)
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
                  TextSpan(
                    text: choice == "WO"
                        ? 'Delivery Date:   '
                        : 'Request Date:   ',
                  ),
                  TextSpan(
                    text: choice == "WO"
                        ? globalVM.dateToString(
                            weborderVM.tolistwoout[index].delivery_date)
                        : globalVM.dateToString(stockrequestVM
                                .tolistsrout[index].delivery_date) +
                            "\n" +
                            "                            " +
                            stockrequestVM.tolistsrout[index].delivery_date
                                .substring(
                                    11,
                                    stockrequestVM.tolistsrout[index]
                                        .delivery_date.length),
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 12 * ffem,
                      fontWeight: FontWeight.w400,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff3d3d3d),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Container(
          //   // totalitem3CHZ (4:822)
          //   margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 4 * fem),
          //   child: RichText(
          //     text: TextSpan(
          //       style: SafeGoogleFont(
          //         'Roboto',
          //         fontSize: 12 * ffem,
          //         fontWeight: FontWeight.w600,
          //         height: 1.1725 * ffem / fem,
          //         color: Color(0xff3d3d3d),
          //       ),
          //       children: [
          //         TextSpan(
          //           text: 'Total Item:         ',
          //         ),
          //         TextSpan(
          //           text: choice == "WO"
          //               ? '${weborderVM.tolistwoout[index].total_item}'
          //               : '${stockrequestVM.tolistsrout[index].total_item}',
          //           style: SafeGoogleFont(
          //             'Roboto',
          //             fontSize: 12 * ffem,
          //             fontWeight: FontWeight.w400,
          //             height: 1.1725 * ffem / fem,
          //             color: Color(0xff3d3d3d),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          Container(
            margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 0 * fem),
            constraints: BoxConstraints(
              maxWidth: 150 * fem,
            ),
            child: Row(
              // Wrap with Column
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
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
                          text: 'Total Quantity:  ',
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      choice == "WO"
                          ? '${weborderVM.tolistwoout[index].item}'
                          : _CalculTotal(),
                      style: SafeGoogleFont(
                        'Roboto',
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff3d3d3d),
                      ),
                    ),
                    Text(
                      choice == "WO"
                          ? '${weborderVM.tolistwoout[index].item}'
                          : _calcutotalpcs(),
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
              ],
            ),
          ),
          Visibility(
              child: Container(
                // totalquantity60pcs48pakZXR (4:823)
                margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 0 * fem),
                constraints: BoxConstraints(
                  maxWidth: 150 * fem,
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
                      getInlineSpan(index),
                      TextSpan(
                        text: ' ',
                      ),
                      getInlineSpanCH(index),
                      TextSpan(
                        text: ' ',
                      ),
                      getInlineSpanFZ(index),
                      // weborderVM.choiceout.value != "ALL" &&
                      //         calcuforcolour() == 1
                      //     ? TextSpan(
                      //         text: '                            ',
                      //       )
                      //     : weborderVM.choiceout.value != "ALL" &&
                      //             calcuforcolour() == 2
                      //         ? TextSpan(
                      //             text: '                            ',
                      //           )
                      //         : weborderVM.choiceout.value != "ALL" &&
                      //                 calcuforcolour() == 3
                      //             ? TextSpan(
                      //                 text: '                            ',
                      //               )
                      //             : calcuforcolour() == 1
                      //                 ? TextSpan(
                      //                     text: '                     ',
                      //                   )
                      //                 : calcuforcolour() == 2
                      //                     ? TextSpan(
                      //                         text: '                     ',
                      //                       )
                      //                     : calcuforcolour() == 3
                      //                         ? TextSpan(
                      //                             text:
                      //                                 '                            ',
                      //                           )
                      //                         : TextSpan(
                      //                             text: '                     ',
                      //                           ),
                      // TextSpan(
                      //   text: '                            ',
                      // ),
                      // Row(
                      //     children: List.generate(
                      //         weborderVM.tolistWO[index].item.length, (asd) {
                      //   return Text(
                      //       weborderVM.tolistWO[index].item[asd].toString());
                      // }))

                      TextSpan(
                        text: "",
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
              visible: choice != "WO")
        ],
      ),
    );
  }
}
