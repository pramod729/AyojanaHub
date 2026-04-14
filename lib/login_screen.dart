import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ayojana_hub/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final emailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
    return email.isNotEmpty && pass.isNotEmpty && emailValid && pass.length >= 6;
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;

      // Use AuthProvider for login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorMessage = await authProvider.login(email: email, password: pass);

      if (mounted) {
        if (errorMessage == null) {
          // Login successful - check user role and navigate accordingly
          final userRole = authProvider.userModel?.role ?? 'customer';
          final destinationRoute = userRole == 'admin'
              ? '/admin-analytics'
              : userRole == 'vendor'
                  ? '/vendor-dashboard'
                  : '/home';
          
          Navigator.of(context).pushReplacementNamed(destinationRoute);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully')),
          );
        } else {
          // Login failed - show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
      ),
      hintStyle: TextStyle(color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 520;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF061428), Color(0xFF001B3A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.all(isSmall ? 18 : 28),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome to Ayojana Hub',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmall ? 20 : 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Sign in to manage and explore events seamlessly',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmall ? 13 : 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 18.0),

                            // Secure Login hint
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.lock_outline, color: Colors.white54, size: 16),
                                SizedBox(width: 6),
                                Text('Secure Login', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 18.0),

                            // Email
                            TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(hint: 'name@example.com', icon: Icons.email_outlined),
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'Email is required';
                                  final valid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value);
                                  if (!valid) return 'Enter a valid email';
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12.0),

                            // Password
                            TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(hint: 'Enter your password', icon: Icons.lock_outline).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    tooltip: _obscure ? 'Show password' : 'Hide password',
                                  ),
                                ),
                                validator: (v) {
                                  final value = v ?? '';
                                  if (value.isEmpty) return 'Password is required';
                                  if (value.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  if (_isFormValid && !_isLoading) _onSignIn();
                                },
                                onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 8.0),
                            // Forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/forgot-password');
                                },
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                                child: const Text('Forgot password?', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ),
                            ),

                            const SizedBox(height: 6.0),

                            // Sign in button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isFormValid && !_isLoading ? _onSignIn : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? const Color(0xFF2F7BFF) : Colors.blueGrey.shade700,
                                  disabledBackgroundColor: Colors.blueGrey.shade800,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                  elevation: _isFormValid ? 10 : 0,
                                  shadowColor: Colors.blue.shade300.withValues(alpha: 0.25),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _isLoading
                                      ? const SizedBox(key: ValueKey('loading'), width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                      : const Text('Sign In', key: ValueKey('label'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18.0),

                            // Divider and secondary actions
                            Row(children: [Expanded(child: Divider(color: Colors.white12.withValues(alpha: 0.5))), const SizedBox(width: 12), const Text('New to Ayojana Hub?', style: TextStyle(color: Colors.white60)), const SizedBox(width: 12), Expanded(child: Divider(color: Colors.white12.withValues(alpha: 0.5)))]),
                            const SizedBox(height: 14.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/register');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.white24),
                                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                        ),
                                        child: const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/vendor-register');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade600,
                                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                        ),
                                        child: const Text('Register as Vendor', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18.0),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text('© 2026 Ayojana Hub', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
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
