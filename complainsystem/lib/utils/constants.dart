class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ugmdgbapiqjvycxuslyw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnbWRnYmFwaXFqdnljeHVzbHl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMTk5NDIsImV4cCI6MjA2NTc5NTk0Mn0.pfYIVVk8tSuwK7sQS7-zoEknhTsALfnRtAjaJ3V2EPk';
  
  // App Information
  static const String appName = 'CS Complaint System';
  static const String appVersion = '1.0.0';
  
  // Department
  static const String departmentName = 'CS';
  
  // Batch Names
  static const List<String> batchNames = [
    'FA18', 'FA19', 'FA20', 'FA21', 
    'FA22', 'FA23', 'FA24', 'FA25'
  ];
  
  // Complaint Titles
  static const List<String> complaintTitles = [
    'Transport',
    'Course', 
    'Fee',
    'Faculty',
    'Personal',
    'Other'
  ];
  
  // Complaint Statuses
  static const List<String> complaintStatuses = [
    'Submitted',
    'In Progress', 
    'Escalated',
    'Resolved',
    'Rejected'
  ];
  
  // User Roles
  static const List<String> userRoles = [
    'admin',
    'student',
    'batch_advisor', 
    'hod'
  ];
  
  // Email Configuration
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String emailUsername = 'taimoorvri@gmail.com';
  static const String emailPassword = 'kdhu opzj regf xsxg';
  
  // Auto-escalation time (24 hours in milliseconds)
  static const int autoEscalationTime = 24 * 60 * 60 * 1000;
  
  // Same title complaint threshold
  static const int sameTitleThreshold = 5;
  
  // Student ID prefix
  static const String studentIdPrefix = 'BCS-';
  
  // Colors
  static const int primaryColor = 0xFF1976D2;
  static const int secondaryColor = 0xFF424242;
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFF44336;
  static const int warningColor = 0xFFFF9800;
  static const int infoColor = 0xFF2196F3;
} 