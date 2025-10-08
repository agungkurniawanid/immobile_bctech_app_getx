import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cpma/config/globalVar.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/config/globalVar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double size;
  final bool isBlueTxt;
  final bool isBlueBackground;
  final FontWeight weight;
  final TextAlign textAlign;
  final int maxLines;
  final Color color;
  final bool isdark;

  TextWidget({
    this.text,
    this.size = 14.0,
    @required this.isBlueTxt,
    this.weight,
    this.textAlign,
    this.maxLines = 1,
    this.isBlueBackground = false,
    this.color,
    this.isdark,
  });
  TextWidget.appBar({
    this.text,
    this.size = 18.0,
    @required this.isBlueTxt,
    this.weight,
    this.textAlign,
    this.maxLines = 1,
    this.isBlueBackground = false,
    this.color,
    this.isdark,
  });
  TextWidget.banner({
    this.text,
    this.size = 24.0,
    @required this.isBlueTxt,
    this.weight,
    this.textAlign,
    this.maxLines = 1,
    this.isBlueBackground = false,
    this.color,
    this.isdark,
  });
  TextWidget.title({
    this.text,
    this.size = 36.0,
    @required this.isBlueTxt,
    this.weight,
    this.textAlign,
    this.maxLines = 1,
    this.isBlueBackground = false,
    this.color,
    this.isdark,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget;
    isBlueBackground
        ? widget = AutoSizeText(text,
            textAlign: textAlign,
            maxLines: maxLines,
            style: TextStyle(
                fontSize: size ?? 14,
                fontWeight: weight ?? FontWeight.normal,
                color: color != null ? color : kWhiteColor))
        : isBlueTxt
            ? widget = AutoSizeText(text,
                textAlign: textAlign,
                maxLines: maxLines,
                style: TextStyle(
                    fontSize: size ?? 14,
                    fontWeight: weight ?? FontWeight.normal,
                    color: Color(0xfff44236)))
            : widget = AutoSizeText(text,
                textAlign: textAlign,
                maxLines: maxLines,
                style: TextStyle(
                    fontSize: size ?? 14,
                    fontWeight: weight ?? FontWeight.normal,
                    color: color == null ? kBlackColor : color));
    return widget;
  }
}
