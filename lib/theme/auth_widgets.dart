import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_theme.dart';

class PremiumTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onSuffixTapped;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const PremiumTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onSuffixTapped,
    this.onFieldSubmitted,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      maxLines: _isObscured ? 1 : widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: AppColors.textSecondary,
                size: AppDimensions.iconM,
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: Icon(
                  widget.suffixIcon,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconM,
                ),
                onPressed: widget.onSuffixTapped ??
                    () {
                      if (widget.obscureText) {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      }
                    },
              )
            : null,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
      ),
    );
  }
}


class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        color: backgroundColor ?? AppColors.gold,
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.gold).withOpacity(0.12),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.black,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...
                        [
                          Icon(
                            icon!,
                            color: textColor ?? Colors.black,
                            size: AppDimensions.iconM,
                          ),
                          const SizedBox(width: 8),
                        ],
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? Colors.black,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
            child: GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textLight,
                  size: 18,
                ),
              ),
            ),
          ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textLight,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.6,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class SuccessState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinue;

  const SuccessState({
    super.key,
    required this.title,
    required this.message,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 56,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingXXL),
        PremiumButton(
          text: 'Continue',
          onPressed: onContinue,
        ),
      ],
    );
  }
}
