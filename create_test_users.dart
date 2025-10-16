#!/usr/bin/env dart

/// Command-line script to create test users for InternHub
/// Run with: dart create_test_users.dart

import 'dart:io';

void main() async {
  print('🚀 InternHub Test Users Creator');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  
  print('This script will create test users for your InternHub application.');
  print('Make sure you have your Supabase credentials configured in your Flutter app.');
  print('');
  
  print('📋 Test Users to be created:');
  print('');
  print('👨‍🎓 STUDENT USER:');
  print('   Email: student@internhub.test');
  print('   Password: student123');
  print('   Role: Student');
  print('');
  print('🏢 COMPANY USER:');
  print('   Email: company@internhub.test');
  print('   Password: company123');
  print('   Role: Company');
  print('');
  print('👨‍💼 ADMIN USER:');
  print('   Email: admin@internhub.test');
  print('   Password: admin123');
  print('   Role: Administrator');
  print('');
  
  stdout.write('Do you want to proceed? (y/N): ');
  String? input = stdin.readLineSync();
  
  if (input?.toLowerCase() != 'y' && input?.toLowerCase() != 'yes') {
    print('❌ Operation cancelled.');
    exit(0);
  }
  
  print('');
  print('⚠️  IMPORTANT NOTES:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  print('1. This script creates users in your Supabase database');
  print('2. Make sure your Supabase project is properly configured');
  print('3. These are test accounts - do not use in production');
  print('4. You can create users manually through the Flutter app');
  print('5. Or use the Test Users Setup page in your app');
  print('');
  print('🔧 To create users through the Flutter app:');
  print('1. Run your Flutter app: flutter run');
  print('2. Go to the Login page');
  print('3. Click "Setup Test Users" button');
  print('4. Follow the on-screen instructions');
  print('');
  print('✨ Test users setup complete!');
  print('You can now test your app with these credentials.');
}
