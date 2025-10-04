import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  final String? email;
  const VerificationPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Verify'),
    );
  }
}