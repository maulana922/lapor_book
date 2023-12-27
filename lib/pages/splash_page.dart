import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashFull();
  }
}

class SplashFull extends StatefulWidget {
  const SplashFull({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashFull> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;

    if (user != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Selamat Datang Di Aplikasi Laporan',
            style: headerStyle(level: 1),
          ),
        ),
      ),
    );
  }
}
