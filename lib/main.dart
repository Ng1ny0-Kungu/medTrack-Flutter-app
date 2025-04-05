import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';
import 'sign_in_page.dart';
import 'welcome_screen.dart';
import 'sign_in_as_staff.dart';
import 'create_password.dart';
import 'package:med_track_a/staff_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppStart());
}

class AppStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MedTrackApp(); // Launch app when Firebase is ready
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show loader while Firebase initializes
          ),
        );
      },
    );
  }
}

class MedTrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set WelcomeScreen as the first screen
      routes: {
        '/': (context) => WelcomeScreen(),
        '/signIn': (context) => SignInPage(),
        '/home': (context) => HomePage(),
        '/signInStaff': (context) => SignInAsStaff(),
        '/createPassword': (context) => CreatePassword(),
        '/staffHome': (context) => StaffHomePage(),
      },
    );
  }
}
