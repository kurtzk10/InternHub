import 'package:flutter/material.dart';
import 'package:internhub/internetHelper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:email_validator/email_validator.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

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
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter email address',
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Next'),
                        onPressed: () async {
                          final email = emailController.text.trim();

                          if (!EmailValidator.validate(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid email address."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final response = await Supabase.instance.client
                              .from('users')
                              .select('email')
                              .eq('email', email)
                              .maybeSingle();

                          if (response == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "No account found with this email.",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: CircularProgressIndicator(color: orange),
                            ),
                          );

                          try {
                            await Supabase.instance.client.auth
                                .resetPasswordForEmail(
                                  email,
                                  redirectTo:
                                      'https://kurtzk10.github.io/InternHub-HTML/resetPassword.html',
                                );

                            Navigator.of(context).pop();

                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => PasswordMessage(),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
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

class PasswordMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = const Color(0xffF5761A);
    final isWide = screenWidth > 600;

    return Scaffold(
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
      body: Padding(
        padding: isWide
            ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
            : EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Center(
          child: Text(
            'A password reset email has been sent to your email address.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
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
