import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/login.dart';
import 'package:internhub/screens/studentPage.dart';
import 'package:internhub/screens/companyPage.dart';
import 'package:internhub/screens/adminPage.dart';
import 'package:internhub/screens/firstTimeStudent.dart';
import 'package:internhub/screens/firstTimeCompany.dart';
import 'package:internhub/screens/passwordReset.dart';
import 'dart:html' as html;

class AuthCallbackPage extends StatefulWidget {
  @override
  _AuthCallbackPageState createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      // ALWAYS show debug page first to see what we're getting
      print('Auth callback triggered!');
      print('Current URL: ${html.window.location.href}');
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/debug-callback');
        return;
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Authentication error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xffF5761A);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              CircularProgressIndicator(
                color: orange,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Processing authentication...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ] else if (errorMessage != null) ...[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 20),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LoginPage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Back to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
