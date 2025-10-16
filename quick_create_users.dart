import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Quick script to create test users immediately
/// This can be run directly in your app to create users

class QuickUserCreator {
  static Future<void> createUsersNow() async {
    print('🚀 Creating test users immediately...');
    
    try {
      // Create Student User
      await _createUser(
        email: 'student@internhub.test',
        password: 'student123',
        userType: 'student',
        name: 'John Student',
      );
      
      // Create Company User
      await _createUser(
        email: 'company@internhub.test',
        password: 'company123',
        userType: 'company',
        name: 'TechCorp Solutions',
      );
      
      // Create Admin User
      await _createUser(
        email: 'admin@internhub.test',
        password: 'admin123',
        userType: 'admin',
        name: 'Admin Coordinator',
      );
      
      print('✅ All users created! You can now login with:');
      print('Student: student@internhub.test / student123');
      print('Company: company@internhub.test / company123');
      print('Admin: admin@internhub.test / admin123');
      
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  static Future<void> _createUser({
    required String email,
    required String password,
    required String userType,
    required String name,
  }) async {
    try {
      print('Creating $userType user: $email');
      
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'user_type': userType, 'name': name},
      );
      
      if (authResponse.user != null) {
        print('✅ $userType user created successfully');
      } else {
        print('⚠️ $userType user might already exist');
      }
    } catch (e) {
      print('❌ Error creating $userType: $e');
    }
  }
}
