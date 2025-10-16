import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test Users Setup Script for InternHub
/// This script creates test users for Student, Company, and Admin roles
/// Run this in your Flutter app's main() function or as a separate utility

class TestUsersSetup {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// Create test users for all roles
  static Future<void> createTestUsers() async {
    print('🚀 Starting test users setup...');
    
    try {
      // Create Student Test User
      await _createStudentUser();
      
      // Create Company Test User  
      await _createCompanyUser();
      
      // Create Admin Test User
      await _createAdminUser();
      
      print('✅ All test users created successfully!');
      print('\n📋 Test User Credentials:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('👨‍🎓 STUDENT USER:');
      print('   Email: student@internhub.test');
      print('   Password: student123');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🏢 COMPANY USER:');
      print('   Email: company@internhub.test');
      print('   Password: company123');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('👨‍💼 ADMIN USER:');
      print('   Email: admin@internhub.test');
      print('   Password: admin123');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
    } catch (e) {
      print('❌ Error creating test users: $e');
    }
  }

  /// Create Student Test User
  static Future<void> _createStudentUser() async {
    try {
      print('👨‍🎓 Creating Student test user...');
      
      // Create auth user
      final authResponse = await supabase.auth.signUp(
        email: 'student@internhub.test',
        password: 'student123',
        data: {
          'user_type': 'student',
          'name': 'John Student',
        },
      );

      if (authResponse.user == null) {
        print('⚠️ Student user might already exist, skipping...');
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await supabase.from('users').insert({
        'auth_id': userId,
        'user_type': 'student',
      });

      // Get the user_id from users table
      final userResponse = await supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into students table
      await supabase.from('students').insert({
        'user_id': userTableId,
        'name': 'John Student',
        'course': 'Computer Science',
        'year_level': '3',
        'resume_link': 'https://example.com/john-resume.pdf',
        'about_me': 'Passionate computer science student with interests in web development and machine learning.',
        'skills': 'Flutter, Dart, JavaScript, Python, React',
        'phone': '09123456789',
        'linkedin_url': 'https://linkedin.com/in/johnstudent',
        'github_url': 'https://github.com/johnstudent',
        'portfolio_url': 'https://johnstudent.dev',
        'location': 'Manila, Philippines',
      });

      print('✅ Student user created successfully');
    } catch (e) {
      print('❌ Error creating Student user: $e');
    }
  }

  /// Create Company Test User
  static Future<void> _createCompanyUser() async {
    try {
      print('🏢 Creating Company test user...');
      
      // Create auth user
      final authResponse = await supabase.auth.signUp(
        email: 'company@internhub.test',
        password: 'company123',
        data: {
          'user_type': 'company',
          'name': 'TechCorp Solutions',
        },
      );

      if (authResponse.user == null) {
        print('⚠️ Company user might already exist, skipping...');
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await supabase.from('users').insert({
        'auth_id': userId,
        'user_type': 'company',
      });

      // Get the user_id from users table
      final userResponse = await supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into company table
      await supabase.from('company').insert({
        'user_id': userTableId,
        'name': 'TechCorp Solutions',
        'industry': 'Technology',
        'contact_email': 'hr@techcorp.test',
        'contact_number': '09123456789',
        'is_verified': true, // Set as verified for testing
      });

      print('✅ Company user created successfully');
    } catch (e) {
      print('❌ Error creating Company user: $e');
    }
  }

  /// Create Admin Test User
  static Future<void> _createAdminUser() async {
    try {
      print('👨‍💼 Creating Admin test user...');
      
      // Create auth user
      final authResponse = await supabase.auth.signUp(
        email: 'admin@internhub.test',
        password: 'admin123',
        data: {
          'user_type': 'admin',
          'name': 'Admin Coordinator',
        },
      );

      if (authResponse.user == null) {
        print('⚠️ Admin user might already exist, skipping...');
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await supabase.from('users').insert({
        'auth_id': userId,
        'user_type': 'admin',
      });

      // Get the user_id from users table
      final userResponse = await supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into admin table
      await supabase.from('admin').insert({
        'user_id': userTableId,
        'name': 'Admin Coordinator',
      });

      print('✅ Admin user created successfully');
    } catch (e) {
      print('❌ Error creating Admin user: $e');
    }
  }

  /// Delete all test users (cleanup function)
  static Future<void> deleteTestUsers() async {
    print('🧹 Cleaning up test users...');
    
    try {
      // Delete from database tables first
      await supabase.from('students').delete().like('name', '%Test%');
      await supabase.from('company').delete().like('name', '%Test%');
      await supabase.from('admin').delete().like('name', '%Test%');
      await supabase.from('users').delete().like('auth_id', '%');
      
      // Note: Auth users deletion would need to be done manually in Supabase dashboard
      // or through admin API calls
      
      print('✅ Test users cleanup completed');
    } catch (e) {
      print('❌ Error during cleanup: $e');
    }
  }

  /// Display test user credentials
  static void displayCredentials() {
    print('\n📋 Test User Credentials for InternHub:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('👨‍🎓 STUDENT USER:');
    print('   Email: student@internhub.test');
    print('   Password: student123');
    print('   Role: Student');
    print('   Features: Browse listings, apply to jobs, manage profile');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🏢 COMPANY USER:');
    print('   Email: company@internhub.test');
    print('   Password: company123');
    print('   Role: Company');
    print('   Features: Create listings, view applicants, manage company profile');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('👨‍💼 ADMIN USER:');
    print('   Email: admin@internhub.test');
    print('   Password: admin123');
    print('   Role: Administrator');
    print('   Features: Manage users, companies, view logs, system administration');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

/// Extension to add this functionality to your main app
/// Usage: Add this to your main.dart file
/*
Future<void> main() async {
  // Initialize Supabase first
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Create test users (uncomment the line below to run)
  // await TestUsersSetup.createTestUsers();

  runApp(MyApp());
}
*/
