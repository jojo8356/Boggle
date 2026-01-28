import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordChip extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final TextDecoration? textDecoration;
  final VoidCallback? onTap;
  final bool isSelected;

  const WordChip({
    super.key,
    required this.text,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.textDecoration,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isSelected ? AppColors.green300 : AppColors.green100),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor ?? (isSelected ? AppColors.green700 : AppColors.green300),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor ?? AppColors.green800,
          fontWeight: isSelected ? FontWeight.bold : fontWeight,
          decoration: textDecoration,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}
