import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:ayojana_hub/event_provider.dart';
import 'package:ayojana_hub/firebase_options.dart';
import 'package:ayojana_hub/forgot_password_screen_new.dart';
import 'package:ayojana_hub/home_screen.dart';
import 'package:ayojana_hub/login_screen_new.dart';
import 'package:ayojana_hub/my_bookings_screen.dart';
import 'package:ayojana_hub/my_events_screen.dart';
import 'package:ayojana_hub/profile_screen.dart';
import 'package:ayojana_hub/register_screen_new.dart';
import 'package:ayojana_hub/splash_screen.dart';
import 'package:ayojana_hub/theme/app_theme.dart';
import 'package:ayojana_hub/vendor_list_screen.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const AyojanaHubApp());
}

class AyojanaHubApp extends StatelessWidget {
  const AyojanaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Ayojana Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const _RootScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/my-events': (context) => const MyEventsScreen(),
          '/vendors': (context) => const VendorListScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
