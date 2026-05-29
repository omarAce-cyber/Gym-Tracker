import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd', 'ar');

  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static DateTime parseDate(String date) => DateTime.parse(date);

  static String shortDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }
    return value;
  }
}
