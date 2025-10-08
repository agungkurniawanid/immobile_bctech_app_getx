// import 'package:cpma/config/globalVar.dart';
import 'package:immobile/widget/theme.dart';
import 'package:flutter/material.dart';

class BtnWidget extends StatelessWidget {
  final Function onPress;
  final Color btnColor;
  final ShapeBorder shape;
  final String btnText;

  BtnWidget(
      {@required this.onPress,
      this.btnColor,
      this.shape,
      @required this.btnText});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        minWidth: double.infinity,
        height: 50,
        onPressed: onPress,
        color: Color(0xfff44236),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text(
          btnText,
          style: TextStyle(
              color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 18.0),
        ));
  }
}
