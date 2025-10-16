import 'package:flutter/material.dart';
import 'package:internhub/screens/companyPage.dart';
import 'package:internhub/screens/modernStudentPage.dart';
import 'package:internhub/screens/passwordChange.dart';
import 'package:internhub/screens/adminPage.dart';
import 'package:internhub/screens/testUsersPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

class LoginResult {
  final bool success;
  final String message;
  LoginResult(this.success, this.message);
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loginFocus = true;
  int userType = 0;
  bool isVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

  Future<LoginResult> _login(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return LoginResult(false, "Login failed. Please try again.");
      }
      
      // For development, allow login even if email is not confirmed
      // In production, you might want to enforce email confirmation
      if (response.user!.emailConfirmedAt == null) {
        print('Warning: User ${email} logged in without email confirmation');
        // You can choose to allow this for development or block it
        // return LoginResult(false, "Please check your email and click the confirmation link before logging in.");
      }
      
      return LoginResult(true, 'Successfully signed in as $email');
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        return LoginResult(false, "Please check your email and click the confirmation link before logging in.");
      }
      return LoginResult(false, e.message);
    }
  }

  Future<String> _signUp(String email, String password, int userType) async {
    try {
      // Check if user already exists in our database
      final isExisting = await Supabase.instance.client
          .from('users')
          .select('email')
          .eq('email', email);

      if (isExisting.isNotEmpty) {
        return "This email already has an account registered to it.";
      }

      // Sign up with Supabase Auth (this will send confirmation email)
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'http://localhost:3000/auth/callback', // For local development
        data: {
          'user_type': userType == 0 ? 'student' : userType == 1 ? 'company' : 'admin',
        },
      );

      if (response.user == null) return "Sign-up failed. Please try again.";

      // Create user record immediately (we'll handle email confirmation in login)
      String role = userType == 0
          ? 'students'
          : userType == 1
          ? 'company'
          : 'admin';

      final userInsert = await Supabase.instance.client
          .from('users')
          .insert({'auth_id': response.user!.id, 'role': role, 'email': email})
          .select()
          .single();

      await Supabase.instance.client.from(role).insert({
        'user_id': userInsert['user_id'],
      });

      return "Account created! Check your email for a verification link. If you don't receive it, try logging in - you may already be verified.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }


  Future<Map<String, dynamic>?> getProfile(String role) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user.id)
        .maybeSingle();

    Map<String, dynamic>? response = await Supabase.instance.client
        .from(role)
        .select()
        .eq('user_id', usersResponse!['user_id'])
        .single();

    for (final entry in response.entries) {
      final value = entry.value;
      if (value == null || value.toString().isEmpty) {
        return null;
      }
    }

    return response;
  }


  Widget _buildNavTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF55119) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
                    child: Text(
          text,
                      style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFB8C5D1),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
                      ),
                    ),
                  ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF02243F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF04305A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildUserTypeTab('Student', 0),
          _buildUserTypeTab('Company', 1),
          _buildUserTypeTab('Admin', 2),
        ],
      ),
    );
  }

  Widget _buildUserTypeTab(String text, int value) {
    final isSelected = userType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => userType = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF55119) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFB8C5D1),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernForm() {
  return Container(
      padding: EdgeInsets.all(32),
    decoration: BoxDecoration(
        color: const Color(0xFF02243F),
      borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF04305A),
          width: 1,
        ),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF04305A).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
        ),
      ],
    ),
      child: Column(
        children: [
          // Email field
          _buildModernInputField(
            controller: emailController,
            hintText: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          
          SizedBox(height: 20),
          
          // Password field
          _buildModernInputField(
            controller: passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: isVisible,
            onToggleVisibility: () => setState(() => isVisible = !isVisible),
          ),
          
          SizedBox(height: 16),
          
          // Forgot password and resend verification links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => PasswordChangePage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: const Color(0xFFF2A13B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter your email first'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF02243F),
                        title: Text('Resend Verification Email', style: TextStyle(color: Colors.white)),
                        content: Text('Send a new verification email to $email?', style: TextStyle(color: const Color(0xFFB8C5D1))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel', style: TextStyle(color: const Color(0xFFB8C5D1))),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              try {
                                await Supabase.instance.client.auth.resend(
                                  type: OtpType.signup,
                                  email: email,
                                  emailRedirectTo: 'http://localhost:3000/auth/callback',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Verification email sent! Check your inbox.'),
                                      backgroundColor: const Color(0xFFF55119),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to send email: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text('Send Email', style: TextStyle(color: const Color(0xFFF2A13B))),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Resend verification',
                  style: TextStyle(
                    color: const Color(0xFFF2A13B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
          
          SizedBox(height: 32),
          
          // Submit button
          _buildModernButton(),
        ],
    ),
  );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
  return Container(
                decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF04305A),
          width: 1,
        ),
                ),
                child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isVisible,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
                      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF7A8B9A),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFB8C5D1),
            size: 20,
          ),
          suffixIcon: isPassword && onToggleVisibility != null
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFB8C5D1),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF55119), const Color(0xFFF27B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
            color: const Color(0xFFF55119).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    isVisible = false;

                    final email = emailController.text.trim().toLowerCase();
                    final password = passwordController.text.trim();

                    if (email.isEmpty) {
            if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Email can't be empty"),
                          duration: Duration(seconds: 2),
                        ),
                      );
            }
                      return;
                    } else if (password.isEmpty) {
            if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password can't be empty"),
                          duration: Duration(seconds: 2),
                        ),
                      );
            }
                      return;
                    }

                    emailController.text = '';
                    passwordController.text = '';

                    if (loginFocus) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircularProgressIndicator(color: const Color(0xffF5761A)),
                ),
              ),
            );

            final result = await _login(email, password);

                      Navigator.of(context).pop();

            if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            duration: Duration(seconds: 2),
                          ),
                        );
            }

                      if (!result.success) return;

                      try {
                        final type = await Supabase.instance.client
                            .from('users')
                            .select('role')
                            .eq('email', email)
                            .maybeSingle();
                        
                        if (type != null && type['role'] == 'students') {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ModernStudentPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else if (type != null && type['role'] == 'company') {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => CompanyPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else if (type != null && type['role'] == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => AdminPage(isFirstTime: false),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          // Default to student dashboard if role not found
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ModernStudentPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error getting user role: $e');
                        // Default to student dashboard on error
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ModernStudentPage(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircularProgressIndicator(color: const Color(0xffF5761A)),
                ),
              ),
            );

            final result = await _signUp(email, password, userType);

                      Navigator.of(context).pop();

            if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result),
                            duration: Duration(seconds: 2),
                          ),
                        );
            }
                    }
                  },
        child: Text(
          loginFocus ? 'Sign In' : 'Create Account',
                          style: TextStyle(
            color: Colors.white,
                            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final orange = const Color(0xFFF55119);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF02243F), // Deep blue background
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF02243F),
                const Color(0xFF04305A),
                const Color(0xFF02243F),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // Header with logo and navigation
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/logo-no-text.png',
                              height: 32,
                              width: 32,
                            ),
                          ),
                          // Navigation tabs
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF04305A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF04305A),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildNavTab('LOGIN', loginFocus, () {
                                  setState(() {
                                    loginFocus = true;
                                    isVisible = false;
                                    emailController.text = '';
                                    passwordController.text = '';
                                  });
                                }),
                                _buildNavTab('SIGN UP', !loginFocus, () {
                                  setState(() {
                                    loginFocus = false;
                                    isVisible = false;
                                    emailController.text = '';
                                    passwordController.text = '';
                                  });
                                }),
            ],
          ),
        ),
      ],
                      ),
                    ),
                    // Main content area
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Welcome text
                            Container(
                              margin: EdgeInsets.only(bottom: 40),
                              child: Column(
                                children: [
                                  Text(
                                    loginFocus ? 'Welcome Back!' : 'Join InternHub',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    loginFocus 
                                        ? 'Sign in to continue your journey'
                                        : 'Create your account to get started',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color(0xFF888888),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // User type selector (only for signup)
                            if (!loginFocus)
                              Container(
                                margin: EdgeInsets.only(bottom: 32),
                                child: _buildUserTypeSelector(),
                              ),

                            // Login/Signup form
                            _buildModernForm(),
                            
                            SizedBox(height: 20),
                            
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    ),
    );
  }
}
