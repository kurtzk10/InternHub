import 'package:flutter/material.dart';
import 'package:internhub/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/adminPage.dart';
import 'package:internhub/screens/studentPage.dart';
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
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          final user = Supabase.instance.client.auth.currentUser;

          final userResponse = await Supabase.instance.client
              .from('users')
              .select('user_id, role')
              .eq('auth_id', user!.id)
              .maybeSingle();
          final userId = userResponse?['user_id'];

          final userType = userResponse?['role'];

          final nameResponse = await Supabase.instance.client
              .from(userType)
              .select('name')
              .eq('user_id', userId)
              .maybeSingle();
          final name = nameResponse?['name'];

          if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => AdminPage(isFirstTime: name == null),
              ),
            );
          } else if (userType == 'students') {
            if (name == null) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => FirstTimeStudentPage(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => StudentPage()),
              );
            }
          } else {
            if (name == null) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => FirstTimeCompanyPage(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => CompanyPage()),
              );
            }
          }
        }
      });

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LoginPage(),
            transitionDuration: Duration.zero,
          ),
        );
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
