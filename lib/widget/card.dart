import 'package:immobile/widget/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final double elevation;
  final double iconSize;
  final double fontSize;
  final String text2;
  final bool regis;
  double height;
  final IconButton buttonnext;

  CardWidget(
      {this.text,
      this.icon,
      this.elevation = 9,
      this.iconSize = 0.10,
      this.fontSize = 14.0,
      this.height = 40,
      this.text2,
      this.regis,
      this.buttonnext});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(5)),
                      border: Border.all(
                        width: 1,
                        style: BorderStyle.none,
                      ),
                    ),
                    child: regis == true
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                            child: TextWidget(
                              isBlueTxt: false,
                              isBlueBackground: true,
                              text: text2,
                              size: 20,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                            child: TextWidget(
                              isBlueTxt: false,
                              isBlueBackground: true,
                              text: 'No Document',
                              size: 20,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                          )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(children: [
                  Visibility(
                    visible: regis == true,
                    child: //
                        IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                  Padding(
                    padding: regis == true
                        ? const EdgeInsets.only(top: 0.0)
                        : const EdgeInsets.only(top: 8.0),
                    child: TextWidget(
                      isBlueTxt: true,
                      text: text,
                      size: fontSize,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Visibility(
                    visible: regis == true,
                    child: buttonnext != null ? buttonnext : Container(),
                  ),
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }
}
