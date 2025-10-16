import 'package:flutter/material.dart';
import 'package:internhub/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/adminPage.dart';
import 'package:internhub/screens/modernStudentPage.dart';
import 'package:internhub/screens/firstTimeStudent.dart';
import 'package:internhub/screens/companyPage.dart';
import 'package:internhub/screens/firstTimeCompany.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 1), () {
      setState(() {
        _opacity = 0.0;
      });

      Future.delayed(Duration(seconds: 1), () async {
        // Always redirect to login page first
        if (mounted && context.mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => LoginPage(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          opacity: _opacity,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
