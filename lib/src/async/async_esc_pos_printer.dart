import 'dart:developer';
import 'dart:typed_data';

import 'package:youprint/src/connection/device_connection.dart';
import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_size.dart';

class AsyncEscPosPrinter extends EscPosPrinterSize {
  final DeviceConnection printerConnection;
  final double? mmFeedPaper;
  final int? dotsFeedPaper;

  AsyncEscPosPrinter(
    this.printerConnection,
    int printerDpi,
    double printerWidthMM,
    int printerNbrCharactersPerLine, {
    this.mmFeedPaper,
    this.dotsFeedPaper,
  }) : super(printerDpi, printerWidthMM, printerNbrCharactersPerLine);

  List<String?> textsToPrint = [];

  AsyncEscPosPrinter setTextsToPrint(List<String?> textsToPrint) {
    this.textsToPrint = textsToPrint;
    return this;
  }

  AsyncEscPosPrinter addTextToPrint(String? textToPrint) {
    if (textToPrint != null) {
      List<String?> tmp = List.filled(textToPrint.length + 1, null);
      tmp.setRange(0, textsToPrint.length, tmp, 0);
      tmp[textsToPrint.length] = textToPrint;
      textsToPrint = tmp;
      return this;
    }
    return this;
  }

  Future<Uint8List> parsedToBytes() async {
    try {
      final deviceConnection = printerConnection;
      final printer = EscPosPrinter(
        deviceConnection,
        null,
        null,
        getPrinterDpi,
        getPrinterWidthMM,
        getPrinterNbrCharactersPerLine,
      );

      List<String?> textsToPrint = this.textsToPrint;
      for (String? textToPrint in textsToPrint) {
        if (textToPrint != null) {
          printer.printFormattedTextAndCut(
            textToPrint,
            mmFeedPaper: mmFeedPaper ?? 10.0,
            dotsFeedPaper: dotsFeedPaper,
          );
        }
      }
    } catch (e) {
      log('AsyncEscPosPrint: $e');
    }
    return Uint8List.fromList(printerConnection.data);
  }
}
