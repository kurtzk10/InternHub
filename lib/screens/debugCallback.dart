import 'package:flutter/material.dart';
import 'dart:html' as html;

class DebugCallbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(html.window.location.href);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug: Auth Callback URL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Full URL:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              html.window.location.href,
              style: TextStyle(color: Colors.yellow, fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'Query Parameters:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            ...uri.queryParameters.entries.map((entry) => 
              Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(color: Colors.cyan, fontSize: 14),
              )
            ),
            SizedBox(height: 20),
            Text(
              'Fragment:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              uri.fragment,
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/password-reset');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF5761A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Test Password Reset Page'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Go to Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
