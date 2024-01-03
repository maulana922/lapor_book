import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lapor_book/firebase_options.dart';
import 'package:lapor_book/pages/addform_page.dart';
import 'package:lapor_book/pages/dashboard_page.dart';
import 'package:lapor_book/pages/login_page.dart';
import 'package:lapor_book/pages/register_page.dart';
import 'package:lapor_book/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: "Lapor Book",
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
    },
  ));
}
