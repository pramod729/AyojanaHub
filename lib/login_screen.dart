import 'package:ayojana_hub/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Login Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFF6C63FF).withOpacity(0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Premium Icon Badge
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.celebration,
                                size: 48,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Welcome Text with enhanced styling
                      const Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color.fromARGB(40, 0, 0, 0),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Login to plan amazing events',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Form with glassmorphism
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            _buildGlassmorphicInput(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              labelText: 'Email Address',
                              icon: Icons.mail_rounded,
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
                            const SizedBox(height: 18),

                            // Password Field
                            _buildGlassmorphicInput(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              labelText: 'Password',
                              icon: Icons.lock_rounded,
                              obscureText: true,
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
                            const SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Premium Login Button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B6B),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      disabledBackgroundColor:
                                          const Color(0xFFFF6B6B).withOpacity(0.5),
                                    ),
                                    child: auth.isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Divider with enhanced style
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'New here?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Sign Up Link - Enhanced
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF6B6B),
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFF6B6B),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        errorStyle: TextStyle(
          color: Colors.red[300],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: validator,
    );
  }
}
