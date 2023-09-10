import 'dart:developer';

import 'package:youprint/src/async/async_esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer.dart';

class AsyncEscPosPrint {
  void parsedToBytes(AsyncEscPosPrinter printersData) {
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
          printer.printFormattedTextAndCut(textToPrint, mmFeedPaper: 10.0);
        }
      }
    } catch (e) {
      log('AsyncEscPosPrint: $e');
    }
  }
}
