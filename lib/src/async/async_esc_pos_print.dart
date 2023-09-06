import 'dart:developer';

import 'package:youprint/src/async/async_esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer.dart';

class AsyncEscPosPrint {
  Future<void> parsedToBytes(AsyncEscPosPrinter printersData) async {
    try {
      final deviceConnection = printersData.printerConnection;
      final printer = EscPosPrinter(
        deviceConnection,
        null,
        null,
        printersData.getPrinterDpi,
        printersData.getPrinterWidthMM,
        printersData.getPrinterNbrCharactersPerLine,
      );

      List<String?> textsToPrint = printersData.textsToPrint;
      for (String? textToPrint in textsToPrint) {
        if (textToPrint != null) {
          printer.printFormattedText(textToPrint, 5);
        }
      }
    } catch (e) {
      log('AsyncEscPosPrint: $e');
    }
  }
}
