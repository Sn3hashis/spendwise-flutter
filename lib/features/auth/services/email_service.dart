import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendOTPEmail(String email, String otp) async {
    final smtpServer = gmail(
      'snehashismukherjeee@gmail.com',
      'ghyw lzqy wvnx tvyw',
    );

    final message = Message()
      ..from = Address('snehashismukherjeee@gmail.com', 'SpendWise')
      ..recipients.add(email)
      ..subject = 'Your SpendWise Verification Code'
      ..html = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>SpendWise Verification</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              margin: 0;
              padding: 0;
              background-color: #f4f4f4;
            }
            .container {
              max-width: 600px;
              margin: 20px auto;
              padding: 20px;
              background-color: #ffffff;
              border-radius: 10px;
              box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            .header {
              text-align: center;
              padding: 20px 0;
              border-bottom: 2px solid #f0f0f0;
            }
            .header h1 {
              color: #2196F3;
              margin: 0;
              font-size: 28px;
            }
            .content {
              padding: 30px 20px;
              text-align: center;
            }
            .otp-code {
              font-size: 36px;
              font-weight: bold;
              color: #1976D2;
              letter-spacing: 5px;
              padding: 20px;
              background-color: #E3F2FD;
              border-radius: 8px;
              margin: 20px 0;
            }
            .warning {
              color: #757575;
              font-size: 14px;
              margin-top: 30px;
              padding: 15px;
              background-color: #FAFAFA;
              border-radius: 5px;
            }
            .footer {
              text-align: center;
              padding-top: 20px;
              border-top: 2px solid #f0f0f0;
              color: #9E9E9E;
              font-size: 12px;
            }
            .expiry {
              color: #F44336;
              font-weight: bold;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>SpendWise</h1>
            </div>
            <div class="content">
              <h2>Verify Your Email Address</h2>
              <p>Thank you for choosing SpendWise. Use the following verification code to complete your registration:</p>
              
              <div class="otp-code">
                $otp
              </div>
              
              <p>This code will expire in <span class="expiry">5 minutes</span>.</p>
              
              <div class="warning">
                <p>⚠️ If you didn't request this code, please ignore this email or contact support if you have concerns.</p>
              </div>
            </div>
            <div class="footer">
              <p>This is an automated message, please do not reply.</p>
              <p>© ${DateTime.now().year} SpendWise. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      ''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw 'Failed to send verification email: ${e.toString()}';
    }
  }
} 