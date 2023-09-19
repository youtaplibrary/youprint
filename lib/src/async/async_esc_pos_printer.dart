import 'dart:developer';
import 'dart:typed_data';

import 'package:youprint/src/connection/device_connection.dart';
import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_size.dart';

class AsyncEscPosPrinter extends EscPosPrinterSize {
  final DeviceConnection printerConnection;

  AsyncEscPosPrinter(
    this.printerConnection,
    int printerDpi,
    double printerWidthMM,
    int printerNbrCharactersPerLine,
  ) : super(printerDpi, printerWidthMM, printerNbrCharactersPerLine);

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

  Future<Uint8List> parsedToBytes({
    int feedCount = 0,
    bool useCut = false,
    bool openDrawer = false,
  }) async {
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
            dotsFeedPaper: feedCount,
            useCut: useCut,
            openDrawer: openDrawer,
          );
        }
      }
    } catch (e) {
      log('AsyncEscPosPrint: $e');
    }

    log('${printerConnection.data}');
    return Uint8List.fromList(printerConnection.data);
  }
}
