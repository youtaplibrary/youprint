import 'dart:developer';

import 'package:youprint/youprint.dart';

class PrinterTextParserCut implements PrinterTextParserElement {
  @override
  int length() => 0;

  @override
  PrinterTextParserCut print(EscPosPrinterCommands printerSocket) {
    log('cut executed');
    printerSocket.cutPaper();
    return this;
  }
}
