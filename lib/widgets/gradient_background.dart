import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GradientBackground({Key? key, required this.child, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
