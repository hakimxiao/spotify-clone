import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hinText;
  final TextEditingController controller;
  final bool isObscureText;

  const CustomField({
    super.key,
    required this.hinText,
    required this.controller,
    this.isObscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      controller: controller,
      decoration: InputDecoration(hintText: hinText),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return 'Please enter $hinText';
        }
        return null;
      },
    );
  }
}
