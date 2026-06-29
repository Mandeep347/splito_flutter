import 'package:flutter/material.dart';

/// A Material 3 text input field wrapping [TextFormField] with consistent style.
class AppTextField extends StatelessWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label text displayed above or inside the field.
  final String labelText;

  /// Optional placeholder helper text.
  final String? hintText;

  /// Whether to obscure text (useful for password inputs).
  final bool obscureText;

  /// The keyboard type for numeric, email, or other inputs.
  final TextInputType? keyboardType;

  /// The action button displayed on the keyboard.
  final TextInputAction? textInputAction;

  /// Evaluates input text and returns validation error descriptions.
  final String? Function(String?)? validator;

  /// Callback when keyboard submit action is fired.
  final ValueChanged<String>? onFieldSubmitted;

  /// Optional widget displayed at the end of the input field.
  final Widget? suffixIcon;

  /// Optional widget displayed at the start of the input field.
  final Widget? prefixIcon;

  /// Flag indicating if the input is editable.
  final bool enabled;

  /// The maximum number of text lines to display.
  final int maxLines;

  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
