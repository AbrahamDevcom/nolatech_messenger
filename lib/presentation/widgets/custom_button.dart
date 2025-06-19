import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Function() onPressed;
  final String text;
  final ButtonOptions options;
  final IconData? icon;
  final Color? iconColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.options,
    this.icon,
    this.iconColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.options.width,
      height: widget.options.height,
      child: ElevatedButton(
        onPressed:
            _isLoading
                ? null
                : () async {
                  if (_isLoading) {
                    return;
                  }
                  setState(() => _isLoading = true);

                  try {
                    await widget.onPressed();
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
        style: ElevatedButton.styleFrom(
          padding: widget.options.padding,
          backgroundColor: widget.options.color,
          disabledBackgroundColor: widget.options.color,
          elevation: widget.options.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.options.borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon != null
                ? Icon(widget.icon, color: widget.iconColor)
                : SizedBox(),
            widget.icon != null ? SizedBox(width: 8) : SizedBox(),
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(widget.text, style: widget.options.textStyle),
          ],
        ),
      ),
    );
  }
}

class ButtonOptions {
  final double width;
  final double height;
  final EdgeInsetsDirectional padding;
  final Color color;
  final TextStyle textStyle;
  final double elevation;
  final double borderRadius;

  ButtonOptions({
    required this.width,
    required this.height,
    required this.padding,
    required this.color,
    required this.textStyle,
    required this.elevation,
    required this.borderRadius,
  });
}
