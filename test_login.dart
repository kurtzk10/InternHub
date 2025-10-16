import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script to verify test user credentials
/// This can be run to test if the created users can login successfully

class TestUserLogin {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// Test login for all test users
  static Future<void> testAllLogins() async {
    print('🧪 Testing login credentials for all test users...\n');

    // Test Student Login
    await _testLogin('student@internhub.test', 'student123', 'Student');

    // Test Company Login
    await _testLogin('company@internhub.test', 'company123', 'Company');

    // Test Admin Login
    await _testLogin('admin@internhub.test', 'admin123', 'Admin');

    print('\n✅ Login testing completed!');
  }

  /// Test login for a specific user
  static Future<void> _testLogin(String email, String password, String role) async {
    try {
      print('🔐 Testing $role login...');
      
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ $role login successful');
        print('   User ID: ${response.user!.id}');
        print('   Email: ${response.user!.email}');
        print('   Email Confirmed: ${response.user!.emailConfirmedAt != null}');
        
        // Sign out after testing
        await supabase.auth.signOut();
        print('   Signed out successfully\n');
      } else {
        print('❌ $role login failed - no user returned\n');
      }
    } catch (e) {
      print('❌ $role login failed: $e\n');
    }
  }

  /// Test specific user login
  static Future<void> testStudentLogin() async {
    await _testLogin('student@internhub.test', 'student123', 'Student');
  }

  static Future<void> testCompanyLogin() async {
    await _testLogin('company@internhub.test', 'company123', 'Company');
  }

  static Future<void> testAdminLogin() async {
    await _testLogin('admin@internhub.test', 'admin123', 'Admin');
  }
}

/// Usage example in your main.dart or test file:
/*
void main() async {
  // Initialize Supabase first
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Test all logins
  await TestUserLogin.testAllLogins();
}
*/
