import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = const Color(0xffF5761A);
    final isWide = screenWidth > 600;

    final emailController = TextEditingController();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isWide ? screenHeight * 0.1 : screenHeight * 0.08,
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            backgroundColor: orange,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
              child: Image.asset(
                'assets/logo-no-text.png',
                height: isWide ? 30 : 35,
                width: isWide ? 30 : 35,
              ),
            ),
          ),
        ),

        body: Container(
          height: screenHeight,
          margin: isWide
              ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
              : EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Enter email address',
                        style: TextStyle(color: Colors.grey),
                      ),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(),
                      errorBorder: _inputBorder(),
                      focusedErrorBorder: _inputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Next'),
                        onPressed: () {
                          final email = emailController.text.trim();

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => PasswordForm(email),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordForm extends StatefulWidget {
  final email;
  const PasswordForm(this.email);

  @override
  PasswordFormState createState() => PasswordFormState();
}

class PasswordFormState extends State<PasswordForm> {
  bool pwIsVisible = false;
  bool confIsVisible = false;

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = const Color(0xffF5761A);
    final isWide = screenWidth > 600;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isWide ? screenHeight * 0.1 : screenHeight * 0.08,
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            backgroundColor: orange,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
              child: Image.asset(
                'assets/logo-no-text.png',
                height: isWide ? 30 : 35,
                width: isWide ? 30 : 35,
              ),
            ),
          ),
        ),

        body: Container(
          height: screenHeight,
          margin: isWide
              ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
              : EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: passwordController,
                    cursorColor: Colors.black,
                    obscureText: pwIsVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            pwIsVisible = !pwIsVisible;
                          });
                        },
                        icon: Icon(
                          pwIsVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      hint: Text(
                        'New password',
                        style: TextStyle(color: Colors.grey),
                      ),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(),
                      errorBorder: _inputBorder(),
                      focusedErrorBorder: _inputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: confirmController,
                    cursorColor: Colors.black,
                    obscureText: confIsVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            confIsVisible = !confIsVisible;
                          });
                        },
                        icon: Icon(
                          confIsVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      hint: Text(
                        'Confirm new password',
                        style: TextStyle(color: Colors.grey),
                      ),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(),
                      errorBorder: _inputBorder(),
                      focusedErrorBorder: _inputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Done'),
                        onPressed: () {
                          final password = passwordController.text.trim();
                          final confirm = confirmController.text.trim();

                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Password can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Passwords do not match."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _inputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.circular(12.5),
  );
}
