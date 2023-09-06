import 'package:youprint/src/esc_pos_printer_commands.dart';

abstract class PrinterTextParserElement {
  int length();
  void print(EscPosPrinterCommands printerSocket);
}
