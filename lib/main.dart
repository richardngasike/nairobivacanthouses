import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nairobivacanthouses/Loginscreens/landlordloginscreen/landlord_login_creen.dart';
import 'package:nairobivacanthouses/Loginscreens/landlordloginscreen/landlord_signup_screen.dart';
import 'package:nairobivacanthouses/Loginscreens/mainloginpage/mainloginpage.dart';
import 'package:nairobivacanthouses/screens/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: 'https://qhgswourzxofsoqdcdsz.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFoZ3N3b3VyenhvZnNvcWRjZHN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0MzYyMzAsImV4cCI6MjA1NzAxMjIzMH0.ql0_FnX5c_bBUE8W04WGwj37sH_BR_XFMGigr_HZzMM',
    );
  } catch (e) {
    debugPrint("🔥 Initialization Error: \$e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nairobi Vacant Houses',
      useInheritedMediaQuery: true,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
          bodyMedium: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
          bodySmall: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
          titleLarge: GoogleFonts.montserrat(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.orange,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
            textStyle:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
            textStyle: GoogleFonts.poppins(),
          ),
        ),
      ),
      initialRoute: '/auth-wrapper',
      getPages: [
        GetPage(name: '/auth-wrapper', page: () => const AuthWrapper()),
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
        GetPage(name: '/login', page: () => LandlordLoginScreen()),
        GetPage(name: '/signup', page: () => const AccountCreationScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return OnboardingScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLoginPage();
  }
}
