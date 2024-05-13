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

  AsyncEscPosPrinter addTextToPrint(String? textToPrint) {
    try {
      if (textToPrint != null) {
        List<String?> tmp = List.from(textsToPrint); // Copy existing list
        tmp.add(textToPrint); // Add new text to the list
        textsToPrint = tmp; // Assign the updated list back to textsToPrint
        return this;
      }
    } catch (e) {
      log('$runtimeType - $e ');
      clearTextsToPrint();
      printerConnection.clearData();
    }
    return this;
  }

  void clearTextsToPrint() {
    textsToPrint = [];
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
      log('$runtimeType - error $e');
    }
    return printerConnection.getData();
  }
}
