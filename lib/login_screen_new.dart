import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/theme/app_theme.dart';
import 'package:ayojana_hub/theme/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
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
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.pushReplacementNamed(context, '/home');
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
              child: Text('Login Failed'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const SizedBox(height: AppDimensions.paddingL),
                    AuthPageHeader(
                      title: 'Welcome to Digital Events',
                      subtitle: 'Sign in to your account to continue',
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
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocus);
                            },
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
                          const SizedBox(height: AppDimensions.paddingM),

                          // Password Field
                          PremiumTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            labelText: 'Password',
                            hintText: 'At least 6 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            suffixIcon: Icons.visibility_off_rounded,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingS),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingL),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return PremiumButton(
                                text: 'Sign In',
                                isLoading: auth.isLoading,
                                onPressed: _login,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.divider,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                          ),
                          child: Text(
                            'New to AyojanaHub?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.divider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Don\'t have an account? ',
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
                                    '/register',
                                  );
                                },
                                child: Text(
                                  'Create Account',
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
