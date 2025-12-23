import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:ayojana_hub/event_provider.dart';
import 'package:ayojana_hub/home_screen.dart';
import 'package:ayojana_hub/my_bookings_screen.dart';
import 'package:ayojana_hub/my_events_screen.dart';
import 'package:ayojana_hub/profile_screen.dart';
import 'package:ayojana_hub/register_screen.dart';
import 'package:ayojana_hub/vendor_list_screen.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Screens


// Providers


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: const Color(0xFF6C63FF),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Color(0xFF6C63FF),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          // '/': (context) => const SplashScreen(),
          // '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          // '/home': (context) => const HomeScreen(),
          '/': (context) => const HomeScreen(),
          // '/create-event': (context) => const CreateEventScreen(),
          '/my-events': (context) => const MyEventsScreen(),
          '/vendors': (context) => const VendorListScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          '/profile': (context) =>  const ProfileScreen(),
        },
      ),
    );
  }
}