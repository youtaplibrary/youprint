import 'package:youprint/youprint.dart';

class PrinterTextParserCut implements PrinterTextParserElement {
  @override
  int length() => 0;

  @override
  PrinterTextParserCut print(EscPosPrinterCommands printerSocket) {
    printerSocket
      ..feedPaper(2)
      ..cutPaper();
    return this;
  }
}
