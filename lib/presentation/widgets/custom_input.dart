import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({
    super.key,
    required this.controller,
    required this.isPassword,
    required this.hintText,
  });

  final TextEditingController controller;
  final bool isPassword;
  final String hintText;

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,

      obscureText: widget.isPassword ? isVisible : false,
      decoration: InputDecoration(
        isDense: true,
        hintStyle: GoogleFonts.outfit(),
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: AppColors.secondaryBackground,
        suffixIcon:
            widget.isPassword
                ? InkWell(
                  onTap: () => setState(() => isVisible = !isVisible),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    isVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Color(0xFF757575),
                    size: 22.0,
                  ),
                )
                : null,
      ),
      style: GoogleFonts.plusJakartaSans(),
      cursorColor: AppColors.primary,
    );
  }
}
