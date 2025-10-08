import 'package:flutter/material.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';

class TextFieldWidget extends StatefulWidget {
  final Key? fieldKey;
  final int? maxLength;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isPasswordField;
  final Icon? prefixIcon;
  final TextInputType keyboardType;
  final dynamic initialValue;
  final TextEditingController? myController;
  final GestureTapCallback? onTap;
  final bool enabled;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const TextFieldWidget({
    super.key,
    this.fieldKey,
    this.maxLength,
    this.hintText,
    required this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    required this.isPasswordField,
    this.prefixIcon,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.myController,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    GlobalVar.darkChecker(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );

    final contentPadding = widget.isPasswordField
        ? const EdgeInsets.only(top: 30, left: 8)
        : const EdgeInsets.only(top: 15, left: 8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.myController,
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPasswordField ? _obscureText : false,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          contentPadding: contentPadding,
          isDense: !widget.isPasswordField,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPasswordField
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
        ),
        style: TextStyle(
          fontSize: 18,
          color: GlobalVar.isDark ? Colors.white : Colors.black,
        ),
        validator: widget.validator,
        onSaved: widget.onSaved,
        onFieldSubmitted: widget.onFieldSubmitted,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        textAlign: TextAlign.left,
      ),
    );
  }
}
