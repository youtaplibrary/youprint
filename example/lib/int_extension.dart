import 'package:intl/intl.dart';

extension PriceUtils on int {
  String get inIDR {
    final NumberFormat numberFormat = NumberFormat('#,##0', 'ID');
    final String formatted = numberFormat.format(this);
    final String formattedFinal = formatted.contains('-')
        ? '${formatted.substring(0, 1)} Rp${formatted.substring(1, formatted.length)}'
        : 'Rp$formatted';
    return formattedFinal;
  }

  String get inPrice {
    final NumberFormat numberFormat = NumberFormat('#,##0', 'ID');
    final String formatted = numberFormat.format(this);
    final String formattedFinal = formatted.contains('-')
        ? '${formatted.substring(0, 1)} ${formatted.substring(1, formatted.length)}'
        : formatted;
    return formattedFinal;
  }
}
