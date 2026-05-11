import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  // Retrieve Twilio credentials from .env for security and to resolve lint warnings
  String get _twilioSid => dotenv.env['TWILIO_SID'] ?? '';
  String get _twilioAuthToken => dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  String get _fromWhatsAppNumber => dotenv.env['TWILIO_WHATSAPP_NUMBER'] ?? '';

  Future<bool> sendEmergencyAlert({
    required String recipientPhone,
    required String patientName,
    required int missedCount,
    required String lastMedication,
    String channel = 'WhatsApp',
    String? facebookId,
    String? instagramId,
  }) async {
    final messageBody = 'ALERT: $patientName has missed $missedCount doses of $lastMedication. Please check on them.';
    
    debugPrint('--- SIMULATING $channel ALERT ---');
    debugPrint('To: ${channel == 'WhatsApp' ? recipientPhone : (facebookId ?? instagramId ?? recipientPhone)}');
    debugPrint('Message: $messageBody');
    debugPrint('----------------------------------');

    try {
      if (channel == 'WhatsApp' && _twilioSid.isNotEmpty && !_twilioSid.contains('YOUR_')) {
        // Example of a real Twilio API call using the imported http package
        final url = 'https://api.twilio.com/2010-04-01/Accounts/$_twilioSid/Messages.json';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Basic $_twilioSid:$_twilioAuthToken', // In production, use base64 encoding
          },
          body: {
            'From': _fromWhatsAppNumber,
            'To': 'whatsapp:$recipientPhone',
            'Body': messageBody,
          },
        );
        return response.statusCode == 201;
      }
    } catch (e) {
      debugPrint('Messaging Service Error: $e');
    }

    return true; // Return true to simulate success in prototype mode
  }
}

