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

class HistoryCard extends StatelessWidget {
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

  HistoryCard(
      {this.index,
      this.icon,
      this.elevation = 9,
      this.iconSize = 0.10,
      this.fontSize = 14.0,
      this.height = 40,
      this.choice,
      this.category});

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
      child: Stack(
        children: [
          Positioned(
            // frame21W7S (32:899)
            left: 16 * fem,
            top: 10 * fem,
            child: Container(
              width: 327 * fem,
              height: 546 * fem,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    // polistex1mZA (32:907)
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 6 * fem),
                      width: double.infinity,
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
                            // autogroupga5n5CU (Xy36ywQUkXg1e71gTJGA5N)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 17 * fem, 0 * fem),
                            width: double.infinity,
                            height: 60 * fem,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  // autogroup3hvg9TE (Xy37624gU2aqxF1zr23Hvg)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 85 * fem, 0 * fem),
                                  height: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // autogroupjemeB92 (Xy379rHdX8tFFEW1K3jemE)
                                        margin: EdgeInsets.fromLTRB(
                                            0 * fem, 0 * fem, 0 * fem, 7 * fem),
                                        width: 200 * fem,
                                        height: 38 * fem,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff44236),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8 * fem),
                                            bottomRight:
                                                Radius.circular(8 * fem),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'IN - 2611000089',
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 20 * ffem,
                                              fontWeight: FontWeight.w600,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // approveddate02022023100212jZr (32:911)
                                        margin: EdgeInsets.fromLTRB(12 * fem,
                                            0 * fem, 0 * fem, 0 * fem),
                                        child: Text(
                                          'Approved Date: 02.02.2023, 10:02:12',
                                          style: SafeGoogleFont(
                                            'Roboto',
                                            fontSize: 12 * ffem,
                                            fontWeight: FontWeight.w600,
                                            height: 1.1725 * ffem / fem,
                                            color: Color(0xff2d2d2d),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   // vectorYnC (32:913)
                                //   margin: EdgeInsets.fromLTRB(
                                //       0 * fem,
                                //       0 * fem,
                                //       0 * fem,
                                //       8.66 * fem),
                                //   width: 11 * fem,
                                //   height: 19.39 * fem,
                                //   child: Image.asset(
                                //     'assets/page-1/images/vector-gMN.png',
                                //     width: 11 * fem,
                                //     height: 19.39 * fem,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Container(
                            // approvedbywarehouse1BaG (32:912)
                            margin: EdgeInsets.fromLTRB(
                                12 * fem, 0 * fem, 0 * fem, 0 * fem),
                            child: Text(
                              'Approved By:   Warehouse 1',
                              style: SafeGoogleFont(
                                'Roboto',
                                fontSize: 12 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xff2d2d2d),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
