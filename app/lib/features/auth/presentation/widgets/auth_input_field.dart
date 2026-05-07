import 'package:app/core/theme.dart';
import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;



  const AuthInputField({super.key, required this.hint, required this.icon, required this.controller,  this.isPassword = false, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      color: DefaultColors.sentMessageInput,
      borderRadius: BorderRadius.circular(25),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
  }
}