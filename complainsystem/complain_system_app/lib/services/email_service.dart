import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../utils/constants.dart';

class EmailService {
  static Future<void> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      final smtpServer = SmtpServer(
        AppConstants.smtpServer,
        port: AppConstants.smtpPort,
        username: AppConstants.emailUsername,
        password: AppConstants.emailPassword,
        ssl: false,
        allowInsecure: true,
      );

      final message = Message()
        ..from = Address(AppConstants.emailUsername, AppConstants.appName)
        ..recipients.add(to)
        ..subject = subject
        ..html = htmlBody;

      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  static String _getEmailTemplate({
    required String name,
    required String greeting,
    required String content,
    String? role,
    String? department,
    String? batch,
    String? username,
    String? password,
    String? studentId,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CS Complaint System</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 3px solid #1976D2;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #1976D2;
            margin: 0;
            font-size: 28px;
        }
        .content {
            margin-bottom: 30px;
        }
        .credentials {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #1976D2;
            margin: 20px 0;
        }
        .credentials h3 {
            margin-top: 0;
            color: #1976D2;
        }
        .credential-item {
            margin: 10px 0;
            font-weight: 500;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
            font-size: 14px;
        }
        .unsubscribe {
            color: #1976D2;
            text-decoration: none;
        }
        .unsubscribe:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>CS Complaint System</h1>
            <p>Computer Science Department</p>
        </div>
        
        <div class="content">
            <p><strong>Dear $name,</strong></p>
            
            <p>$greeting</p>
            
            $content
            
            ${username != null ? '''
            <div class="credentials">
                <h3>Your Login Credentials:</h3>
                <div class="credential-item"><strong>Username:</strong> $username</div>
                ${password != null ? '<div class="credential-item"><strong>Password:</strong> $password</div>' : ''}
                ${role != null ? '<div class="credential-item"><strong>Role:</strong> $role</div>' : ''}
                ${department != null ? '<div class="credential-item"><strong>Department:</strong> $department</div>' : ''}
                ${batch != null ? '<div class="credential-item"><strong>Batch:</strong> $batch</div>' : ''}
                ${studentId != null ? '<div class="credential-item"><strong>Student ID:</strong> $studentId</div>' : ''}
            </div>
            ''' : ''}
            
            <p><strong>Important Notes:</strong></p>
            <ul>
                <li>Keep your credentials secure and do not share them with others</li>
                <li>You can change your password after your first login</li>
                <li>For any issues, contact the system administrator</li>
            </ul>
            
            <p>Best regards,<br>
            <strong>CS Complaint Committee</strong></p>
        </div>
        
        <div class="footer">
            <p>&copy; 2025 CS Complaint System. All rights reserved.</p>
            <p><a href="#" class="unsubscribe">Unsubscribe</a> | <a href="#" class="unsubscribe">Privacy Policy</a></p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  static Future<void> sendAdminCredentials({
    required String name,
    required String email,
    required String password,
  }) async {
    final htmlBody = _getEmailTemplate(
      name: name,
      greeting: 'Welcome to the CS Complaint Management System! Your admin account has been successfully created.',
      content: '''
        <p>You have been registered as an <strong>Administrator</strong> for the Computer Science Department's Complaint Management System.</p>
        <p>As an admin, you have full access to:</p>
        <ul>
            <li>Create and manage user accounts (HOD, Batch Advisors, Students)</li>
            <li>Import student data via CSV files</li>
            <li>Manage batches and assign advisors</li>
            <li>Monitor all complaints and system activities</li>
        </ul>
      ''',
      role: 'Administrator',
      department: 'CS',
      username: email,
      password: password,
    );

    await sendEmail(
      to: email,
      subject: 'Admin Account Created - CS Complaint System',
      htmlBody: htmlBody,
    );
  }

  static Future<void> sendHODCredentials({
    required String name,
    required String email,
    required String password,
  }) async {
    final htmlBody = _getEmailTemplate(
      name: name,
      greeting: 'Welcome to the CS Complaint Management System! Your HOD account has been successfully created.',
      content: '''
        <p>You have been registered as the <strong>Head of Department (HOD)</strong> for the Computer Science Department's Complaint Management System.</p>
        <p>As HOD, you can:</p>
        <ul>
            <li>Review escalated complaints from Batch Advisors</li>
            <li>Handle complaints with 5+ similar titles</li>
            <li>Resolve or reject complaints with detailed comments</li>
            <li>Monitor complaint timelines and status updates</li>
        </ul>
      ''',
      role: 'Head of Department (HOD)',
      department: 'CS',
      username: email,
      password: password,
    );

    await sendEmail(
      to: email,
      subject: 'HOD Account Created - CS Complaint System',
      htmlBody: htmlBody,
    );
  }

  static Future<void> sendBatchAdvisorCredentials({
    required String name,
    required String email,
    required String password,
    required String batch,
  }) async {
    final htmlBody = _getEmailTemplate(
      name: name,
      greeting: 'Welcome to the CS Complaint Management System! Your Batch Advisor account has been successfully created.',
      content: '''
        <p>You have been registered as a <strong>Batch Advisor</strong> for batch <strong>$batch</strong> in the Computer Science Department's Complaint Management System.</p>
        <p>As a Batch Advisor, you can:</p>
        <ul>
            <li>View complaints from your assigned batch ($batch)</li>
            <li>Update complaint status and add comments</li>
            <li>Escalate complaints to HOD when necessary</li>
            <li>Monitor complaint timelines</li>
        </ul>
        <p><strong>Note:</strong> Complaints will be automatically escalated to HOD if no action is taken within 24 hours.</p>
      ''',
      role: 'Batch Advisor',
      department: 'CS',
      batch: batch,
      username: email,
      password: password,
    );

    await sendEmail(
      to: email,
      subject: 'Batch Advisor Account Created - CS Complaint System',
      htmlBody: htmlBody,
    );
  }

  static Future<void> sendStudentCredentials({
    required String name,
    required String email,
    required String studentId,
    required String batch,
  }) async {
    final htmlBody = _getEmailTemplate(
      name: name,
      greeting: 'Welcome to the CS Complaint Management System! Your student account has been successfully created.',
      content: '''
        <p>You have been registered as a <strong>Student</strong> in batch <strong>$batch</strong> of the Computer Science Department's Complaint Management System.</p>
        <p>As a student, you can:</p>
        <ul>
            <li>Submit complaints with detailed descriptions</li>
            <li>Attach media files (images/videos) via Google Drive links</li>
            <li>Track the status of your complaints</li>
            <li>View comments and updates from advisors and HOD</li>
        </ul>
        <p><strong>Login Instructions:</strong> Use your Student ID as username and email as password.</p>
      ''',
      role: 'Student',
      department: 'CS',
      batch: batch,
      username: studentId,
      studentId: studentId,
    );

    await sendEmail(
      to: email,
      subject: 'Student Account Created - CS Complaint System',
      htmlBody: htmlBody,
    );
  }

  static Future<void> sendComplaintStatusUpdate({
    required String name,
    required String email,
    required String complaintTitle,
    required String status,
    String? comment,
  }) async {
    final htmlBody = _getEmailTemplate(
      name: name,
      greeting: 'Your complaint status has been updated.',
      content: '''
        <p>Your complaint "<strong>$complaintTitle</strong>" has been updated to status: <strong>$status</strong></p>
        ${comment != null ? '<p><strong>Comment:</strong> $comment</p>' : ''}
        <p>Please log in to your account to view the complete details and timeline.</p>
      ''',
    );

    await sendEmail(
      to: email,
      subject: 'Complaint Status Update - CS Complaint System',
      htmlBody: htmlBody,
    );
  }
} 