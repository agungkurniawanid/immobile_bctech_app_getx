// import 'package:cpma/config/globalVar.dart';
import 'package:flutter/material.dart';
import 'package:immobile/config/globalvar.dart';

class TextFieldWidget extends StatefulWidget {
  final Key fieldKey;
  final int maxLength;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final bool isPasswordField;
  final Icon prefixIcon;
  final TextInputType keyboardType;
  final dynamic initialValue;
  final TextEditingController myController;
  final GestureTapCallback tap;

  const TextFieldWidget(
      {this.fieldKey,
      this.maxLength,
      this.hintText,
      @required this.labelText,
      this.helperText,
      this.onSaved,
      this.validator,
      this.onFieldSubmitted,
      @required this.isPasswordField,
      this.prefixIcon,
      this.initialValue,
      this.keyboardType = TextInputType.text,
      this.myController,
      this.tap});

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    GlobalVar.darkChecker(context);
    return widget.isPasswordField
        ? Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: TextFormField(
              keyboardType: widget.keyboardType ?? TextInputType.text,
              key: widget.fieldKey,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: widget.labelText,
                contentPadding: EdgeInsets.only(top: 30, left: 8),
                // isDense: true,
                // filled: true, //<-- SEE HERE
                // fillColor: Colors.grey[400],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: GestureDetector(
                  child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVar.isDark ? Colors.white : Colors.black),
              validator: widget.validator,
              onSaved: widget.onSaved,
              onFieldSubmitted: widget.onFieldSubmitted,
              textAlign: TextAlign.left,
            ))
        : Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: TextFormField(
              key: widget.fieldKey,
              decoration: InputDecoration(
                  labelText: widget.labelText,
                  contentPadding: EdgeInsets.only(top: 15, left: 8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: widget.prefixIcon),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVar.isDark ? Colors.white : Colors.black),
              validator: widget.validator,
              onSaved: widget.onSaved,
              onFieldSubmitted: widget.onFieldSubmitted,
              textAlign: TextAlign.left,
              initialValue: widget.initialValue,
              keyboardType: widget.keyboardType,
              controller: widget.myController,
              onTap: widget.tap,
            ));
  }
}
