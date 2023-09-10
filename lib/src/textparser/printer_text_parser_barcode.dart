import 'dart:collection';
import 'dart:typed_data';

import 'package:youprint/src/barcode/barcode.dart';
import 'package:youprint/src/barcode/barcode_128.dart';
import 'package:youprint/src/barcode/barcode_ean13.dart';
import 'package:youprint/src/barcode/barcode_ean8.dart';
import 'package:youprint/src/barcode/barcode_upca.dart';
import 'package:youprint/src/barcode/barcode_upce.dart';
import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/exceptions/exception.dart';
import 'package:youprint/src/textparser/textparser.dart';

class PrinterTextParserBarcode implements PrinterTextParserElement {
  Barcode? _barcode;
  int? _length;
  List<int> _align = [];

  PrinterTextParserBarcode(PrinterTextParserColumn printerTextParserColumn, String textAlign,
      HashMap<String, String> barcodeAttributes, String code) {
    EscPosPrinter printer = printerTextParserColumn.getLine.getTextParser.getPrinter;
    code = code.trim();
    _align = EscPosPrinterCommands.textAlignLeft;
    switch (textAlign) {
      case PrinterTextParser.tagsAlignCenter:
        _align = EscPosPrinterCommands.textAlignCenter;
        break;
      case PrinterTextParser.tagsAlignRight:
        _align = EscPosPrinterCommands.textAlignRight;
        break;
    }

    _length = printer.getPrinterNbrCharactersPerLine;
    double height = 10.0;

    if (barcodeAttributes.containsKey(PrinterTextParser.attrBarcodeHeight)) {
      String? barcodeAttribute = barcodeAttributes[PrinterTextParser.attrBarcodeHeight];

      if (barcodeAttribute == null) {
        throw const EscPosParserException(
            "Invalid barcode attribute: ${PrinterTextParser.attrBarcodeHeight}");
      }

      try {
        height = double.parse(barcodeAttribute);
      } on FormatException catch (_) {
        throw const EscPosParserException(
            "Invalid barcode ${PrinterTextParser.attrBarcodeHeight} value");
      }
    }

    double width = 0.0;
    if (barcodeAttributes.containsKey(PrinterTextParser.attrBarcodeWidth)) {
      String? barcodeAttribute = barcodeAttributes[PrinterTextParser.attrBarcodeWidth];

      if (barcodeAttribute == null) {
        throw const EscPosParserException(
            "Invalid barcode attribute: ${PrinterTextParser.attrBarcodeWidth}");
      }

      try {
        width = double.parse(barcodeAttribute);
      } on FormatException catch (_) {
        throw const EscPosParserException(
            "Invalid barcode ${PrinterTextParser.attrBarcodeWidth} value");
      }
    }

    int textPosition = EscPosPrinterCommands.barcodeTextPositionBelow;
    if (barcodeAttributes.containsKey(PrinterTextParser.attrBarcodeTextPosition)) {
      String? barcodeAttribute = barcodeAttributes[PrinterTextParser.attrBarcodeTextPosition];

      if (barcodeAttribute == null) {
        throw const EscPosParserException(
            "Invalid barcode attribute: ${PrinterTextParser.attrBarcodeTextPosition}");
      }

      switch (barcodeAttribute) {
        case PrinterTextParser.attrBarcodeTextPositionNone:
          textPosition = EscPosPrinterCommands.barcodeTextPositionNone;
          break;
        case PrinterTextParser.attrBarcodeTextPositionAbove:
          textPosition = EscPosPrinterCommands.barcodeTextPositionAbove;
          break;
      }
    }

    String? barcodeType = PrinterTextParser.attrBarcodeTypeEAN13;

    if (barcodeAttributes.containsKey(PrinterTextParser.attrBarcodeType)) {
      barcodeType = barcodeAttributes[PrinterTextParser.attrBarcodeType];

      if (barcodeType == null) {
        throw const EscPosParserException(
            "Invalid barcode attribute : ${PrinterTextParser.attrBarcodeType}");
      }
    }

    switch (barcodeType) {
      case PrinterTextParser.attrBarcodeTypeEAN8:
        _barcode = BarcodeEAN8(printer, code, width, height, textPosition);
        break;
      case PrinterTextParser.attrBarcodeTypeEAN13:
        _barcode = BarcodeEAN13(printer, code, width, height, textPosition);
        break;
      case PrinterTextParser.attrBarcodeTypeUPCA:
        _barcode = BarcodeUPCA(printer, code, width, height, textPosition);
        break;
      case PrinterTextParser.attrBarcodeTypeUPCE:
        _barcode = BarcodeUPCE(printer, code, width, height, textPosition);
        break;
      case PrinterTextParser.attrBarcodeType128:
        _barcode = Barcode128(printer, code, width, height, textPosition);
        break;
      default:
        throw const EscPosParserException(
            "Invalid barcode attribute : ${PrinterTextParser.attrBarcodeType}");
    }
  }

  @override
  int length() => _length ?? 0;

  @override
  PrinterTextParserBarcode print(EscPosPrinterCommands printerSocket) {
    printerSocket
        .setAlign(Uint8List.fromList(_align))
        .printBarcode(_barcode)
        .setAlign(Uint8List.fromList(EscPosPrinterCommands.textAlignLeft));
    return this;
  }
}
