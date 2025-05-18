import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy, hh:mm a').format(date);
  }
}