import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/theme/app_theme.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:ayojana_hub/theme/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _agreedToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showErrorDialog('Please accept the Terms and Conditions');
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      _showSuccessDialog();
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
              child: Text('Registration Error'),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        content: SuccessState(
          title: 'Welcome!',
          message: 'Your account has been created successfully',
          onContinue: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
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
              vertical: AppDimensions.paddingM,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Back Button
                    AuthPageHeader(
                      title: 'Create Account',
                      subtitle: 'Join AyojanaHub to start planning amazing events',
                      showBackButton: true,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name Field
                          PremiumTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            labelText: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_emailFocus);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              if (value.trim().split(' ').length < 2) {
                                return 'Please enter your first and last name';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),

                          // Email Field
                          PremiumTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            labelText: 'Email',
                            hintText: 'you@example.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_phoneFocus);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),

                          // Phone Field
                          PremiumTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            labelText: 'Phone Number',
                            hintText: '1234567890',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocus);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                              if (digitsOnly.length < 10) {
                                return 'Phone number must have at least 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),

                          // Password Field
                          PremiumTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            labelText: 'Password',
                            hintText: 'At least 8 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            suffixIcon: Icons.visibility_off_rounded,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),

                          // Confirm Password Field
                          PremiumTextField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            suffixIcon: Icons.visibility_off_rounded,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingM),

                          // Terms and Conditions Checkbox
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreedToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'I agree to the ',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Terms',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' and ',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Privacy',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingXL),

                          // Register Button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return PremiumButton(
                                text: 'Create Account',
                                isLoading: auth.isLoading,
                                onPressed: _register,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Sign In Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
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
                    const SizedBox(height: AppDimensions.paddingM),
                    // (Vendor registration link moved to the Login screen)
                    const SizedBox(height: AppDimensions.paddingL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
