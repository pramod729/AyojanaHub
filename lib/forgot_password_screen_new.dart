import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/theme/app_theme.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:ayojana_hub/theme/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _emailSent = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.7, curve: Curves.easeOut)),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      setState(() {
        _emailSent = true;
      });
    } else {
      _showErrorDialog(error);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Error'),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingL,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _emailSent ? _buildSuccessState() : _buildFormState(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with Back Button
        AuthPageHeader(
          title: 'Reset Password',
          subtitle: 'Enter your email address and we\'ll send you a link to reset your password',
          showBackButton: true,
        ),
        const SizedBox(height: AppDimensions.paddingXXL),

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              PremiumTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _resetPassword(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email address is required';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Reset Button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return PremiumButton(
                    text: 'Send Reset Link',
                    isLoading: auth.isLoading,
                    onPressed: _resetPassword,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),

        // Back to Login Link
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Remember your password? ',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.paddingXXL),
        SuccessState(
          title: 'Check Your Email',
          message: 'We\'ve sent a password reset link to ${_emailController.text}. Click the link to set a new password.',
          onContinue: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: AppDimensions.paddingXXL),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Didn\'t receive it? ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    child: Text(
                      'Try again',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
