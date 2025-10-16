import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String serviceId = 'service_henk1cp';
  static const String templateId = 'template_2naqu4q';
  static const String publicKey = 'l_oDGrnB_D3bFV67I';

  static Future<bool> sendEmail({
    required String name,
    required String email,
    required String title,
    required String companyName,
    required String companyEmail,
    required String companyContact,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'name': name,
          'email': email,
          'title': title,
          'company_name': companyName,
          'company_email': companyEmail,
          'company_contact': companyContact,
        }
      }),
    );
    
    print(response.statusCode);
    print(response.body);
    return response.statusCode == 200;
  }
}
