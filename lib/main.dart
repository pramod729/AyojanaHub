import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:ayojana_hub/chat_provider.dart';
import 'package:ayojana_hub/create_event_screen.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/event_provider.dart';
import 'package:ayojana_hub/firebase_options.dart';
import 'package:ayojana_hub/forgot_password_screen_new.dart';
import 'package:ayojana_hub/home_screen.dart';
import 'package:ayojana_hub/login_screen_new.dart';
import 'package:ayojana_hub/my_bookings_screen.dart';
import 'package:ayojana_hub/my_events_screen.dart';
import 'package:ayojana_hub/notification_service.dart';
import 'package:ayojana_hub/profile_screen.dart';
import 'package:ayojana_hub/proposal_provider.dart';
import 'package:ayojana_hub/register_screen_new.dart';
import 'package:ayojana_hub/splash_screen.dart';
import 'package:ayojana_hub/submit_proposal_screen.dart';
import 'package:ayojana_hub/theme/app_theme.dart';
import 'package:ayojana_hub/vendor_dashboard_screen.dart';
import 'package:ayojana_hub/vendor_list_screen.dart';
import 'package:ayojana_hub/vendor_opportunities_screen.dart';
import 'package:ayojana_hub/vendor_proposals_screen.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:ayojana_hub/vendor_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ayojana_hub/admin_provider.dart';
import 'package:ayojana_hub/admin_analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize notification service
    NotificationService().initializeNotifications();
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
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ProposalProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Ayojana Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/vendor-register': (context) => const VendorRegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/my-events': (context) => const MyEventsScreen(),
          '/create-event': (context) => const CreateEventScreen(),
          '/vendors': (context) => const VendorListScreen(),
          '/vendor-dashboard': (context) => const VendorDashboardScreen(),
          '/vendor-opportunities': (context) => const VendorOpportunitiesScreen(),
          '/vendor-proposals': (context) => const VendorProposalsScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin-analytics': (context) => const AdminAnalyticsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/submit-proposal') {
            final event = settings.arguments as EventModel;
            return MaterialPageRoute(
              builder: (context) => SubmitProposalScreen(event: event),
            );
          }
          return null;
        },
      ),
    );
  }
}

