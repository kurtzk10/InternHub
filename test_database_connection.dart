// Test script to verify database schema and connection
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testDatabaseConnection() async {
  try {
    // Test if we can read from students table
    final response = await Supabase.instance.client
        .from('students')
        .select('*')
        .limit(1);
    
    print('Database connection successful!');
    print('Students table accessible');
    
    // Test if new fields exist
    if (response.isNotEmpty) {
      final student = response.first;
      print('Available fields: ${student.keys.toList()}');
      
      // Check for new fields
      final newFields = ['about_me', 'skills', 'phone_number', 'linkedin_url', 'github_url', 'portfolio_url', 'location'];
      for (final field in newFields) {
        if (student.containsKey(field)) {
          print('✅ Field "$field" exists');
        } else {
          print('❌ Field "$field" missing - run database_update.sql');
        }
      }
    }
  } catch (e) {
    print('Database connection failed: $e');
  }
}
