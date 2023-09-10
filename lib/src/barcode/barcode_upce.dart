import 'package:youprint/src/barcode/barcode.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/esc_pos_printer_size.dart';
import 'package:youprint/src/exceptions/esc_pos_barcode_exception.dart';

class BarcodeUPCE extends Barcode {
  BarcodeUPCE(
      EscPosPrinterSize printerSize, String code, double widthMM, double heightMM, int textPosition)
      : super(printerSize, EscPosPrinterCommands.barcodeTypeUPCE, code, textPosition, widthMM,
            heightMM) {
    checkCode();
  }

  @override
  int get getCodeLength => 6;

  @override
  int get getColsCount => getCodeLength * 7 + 16;

  void checkCode() {
    int codeLength = getCodeLength;

    if (code.length < codeLength) {
      throw const EscPosBarcodeException("Code is too short for the barcode type.");
    }

    try {
      code = code.substring(0, codeLength);
      for (int i = 0; i < codeLength; i++) {
        int.tryParse(code.substring(i, i + 1), radix: 10);
      }
    } on FormatException catch (_) {
      throw const EscPosBarcodeException("Invalid barcode number");
    }
  }
}
