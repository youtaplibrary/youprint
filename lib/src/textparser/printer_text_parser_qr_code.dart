import 'dart:collection';
import 'dart:typed_data';

import 'package:youprint/src//exceptions/exception.dart';
import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/textparser/textparser.dart';

class PrinterTextParserQRCode extends PrinterTextParserImg {
  PrinterTextParserQRCode(
    PrinterTextParserColumn printerTextParserColumn,
    String textAlign,
    HashMap<String, String> qrCodeAttributes,
    String data,
  ) : super(printerTextParserColumn, textAlign,
            bytes: initConstructor(printerTextParserColumn, qrCodeAttributes, data));

  static Uint8List initConstructor(
    PrinterTextParserColumn printerTextParserColumn,
    HashMap<String, String> qrCodeAttributes,
    String data,
  ) {
    EscPosPrinter printer = printerTextParserColumn.getLine.getTextParser.getPrinter;
    data = data.trim();

    int size = printer.mmToPx(20);

    if (qrCodeAttributes.containsKey(PrinterTextParser.attrQRCodeSize)) {
      String? qrCodeAttribute = qrCodeAttributes[PrinterTextParser.attrQRCodeSize];
      if (qrCodeAttribute == null) {
        throw const EscPosParserException(
            "Invalid QR code attribute : ${PrinterTextParser.attrQRCodeSize}");
      }
      try {
        size = printer.mmToPx(double.parse(qrCodeAttribute));
      } catch (_) {
        throw const EscPosParserException(
            "${"Invalid QR code ${PrinterTextParser.attrQRCodeSize}"} value");
      }
    }

    return EscPosPrinterCommands.convertQRCodeToBytes(data, size);
  }
}
