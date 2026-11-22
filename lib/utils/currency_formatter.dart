import 'package:flutter/services.dart';

class CurrencyUtils {
  /// Format angka menjadi string bertitik: 125000 -> "125.000"
  static String formatRibuan(num value) {
    final intVal = value.toInt().toString();
    return intVal.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Ambil angka murni dari string bertitik: "125.000" -> 125000.0
  static double parseRibuan(String text) {
    final clean = text.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}

/// Formatter otomatis saat mengetik di TextField nominal uang
class RibuanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = CurrencyUtils.formatRibuan(int.parse(digitsOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}