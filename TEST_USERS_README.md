# Test Users Setup for InternHub

This document explains how to create and use test users for the InternHub application.

## 📋 Test User Credentials

### 👨‍🎓 Student User
- **Email**: `student@internhub.test`
- **Password**: `student123`
- **Role**: Student
- **Features**: Browse listings, apply to jobs, manage profile, view applications

### 🏢 Company User
- **Email**: `company@internhub.test`
- **Password**: `company123`
- **Role**: Company
- **Features**: Create listings, view applicants, manage company profile, approve/reject applications

### 👨‍💼 Admin User
- **Email**: `admin@internhub.test`
- **Password**: `admin123`
- **Role**: Administrator
- **Features**: Manage users, companies, view logs, system administration, manage listings

## 🚀 How to Create Test Users

### Method 1: Through the Flutter App (Recommended)

1. **Run your Flutter app**:
   ```bash
   flutter run
   ```

2. **Navigate to Login page** and click the **"Setup Test Users"** button

3. **Click "Create Test Users"** on the Test Users Setup page

4. **Wait for completion** - you'll see real-time progress

5. **View credentials** by clicking "Show Credentials"

### Method 2: Manual Creation in Supabase

1. Go to your Supabase dashboard
2. Navigate to Authentication > Users
3. Create users manually with the credentials above
4. Update user metadata to include `user_type`
5. Create corresponding records in your database tables

## 📊 Database Schema Requirements

The test users will be created with the following data structure:

### Users Table
```sql
INSERT INTO users (auth_id, user_type) VALUES 
('auth_user_id', 'student'), -- or 'company', 'admin'
```

### Students Table (for Student user)
```sql
INSERT INTO students (user_id, name, course, year_level, resume_link, about_me, skills, phone, linkedin_url, github_url, portfolio_url, location) VALUES 
(user_table_id, 'John Student', 'Computer Science', '3', 'https://example.com/john-resume.pdf', 'Passionate computer science student...', 'Flutter, Dart, JavaScript, Python, React', '09123456789', 'https://linkedin.com/in/johnstudent', 'https://github.com/johnstudent', 'https://johnstudent.dev', 'Manila, Philippines');
```

### Company Table (for Company user)
```sql
INSERT INTO company (user_id, name, industry, contact_email, contact_number, is_verified) VALUES 
(user_table_id, 'TechCorp Solutions', 'Technology', 'hr@techcorp.test', '09123456789', true);
```

### Admin Table (for Admin user)
```sql
INSERT INTO admin (user_id, name) VALUES 
(user_table_id, 'Admin Coordinator');
```

## 🧪 Testing Workflow

### 1. Test Student Features
- Login as `student@internhub.test`
- Complete first-time setup
- Browse available listings
- Apply to job postings
- Update profile information
- View application status

### 2. Test Company Features
- Login as `company@internhub.test`
- Complete company setup
- Create new job listings
- View applicant profiles
- Manage applications
- Update company information

### 3. Test Admin Features
- Login as `admin@internhub.test`
- Complete admin setup
- View system overview
- Manage users and companies
- View application logs
- System administration

## 🔧 Troubleshooting

### Common Issues

1. **"User already exists"**
   - The user might already be created
   - Check Supabase Auth dashboard
   - Try logging in directly

2. **"Database error"**
   - Check RLS policies in Supabase
   - Ensure tables exist
   - Verify database connection

3. **"Email not confirmed"**
   - For development, email confirmation might be disabled
   - Check Supabase Auth settings
   - Users should be able to login regardless

### Database Policies

Make sure your RLS policies allow:
- Users to insert their own records
- Proper access control between user types
- Admin users to access all data

## 🗑️ Cleanup

To remove test users:

1. **Through Supabase Dashboard**:
   - Go to Authentication > Users
   - Delete test users manually
   - Clean up database records

2. **Through Database**:
   ```sql
   DELETE FROM students WHERE name LIKE '%Test%';
   DELETE FROM company WHERE name LIKE '%Test%';
   DELETE FROM admin WHERE name LIKE '%Test%';
   DELETE FROM users WHERE auth_id IN (SELECT id FROM auth.users WHERE email LIKE '%@internhub.test');
   ```

## ⚠️ Important Notes

- **Development Only**: These are test accounts for development purposes
- **Not for Production**: Never use these credentials in production
- **Email Domains**: Using `.test` domain to avoid conflicts
- **Password Strength**: Simple passwords for easy testing
- **Data Privacy**: Test data should be realistic but not real personal information

## 📝 Customization

You can modify the test user data by editing:
- `lib/screens/testUsersPage.dart` - UI for creating users
- `test_users_setup.dart` - User creation logic
- Database insert statements for different test data

## 🆘 Support

If you encounter issues:
1. Check Supabase logs
2. Verify database schema
3. Check Flutter console for errors
4. Ensure proper authentication setup

---

**Happy Testing! 🎉**
