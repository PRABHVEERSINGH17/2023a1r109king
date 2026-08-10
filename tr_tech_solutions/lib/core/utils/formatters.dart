import 'package:intl/intl.dart';

class Formatters {
  static final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final currencyDecimal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final date = DateFormat('dd MMM yyyy');
  static final dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final month = DateFormat('MMM yyyy');

  static String formatCurrency(num value) => currency.format(value);
  static String formatDate(DateTime? date) => date != null ? Formatters.date.format(date) : '-';
}
