import 'package:youprint/src/barcode/barcode.dart';
import 'package:youprint/src/exceptions/exception.dart';

class BarcodeNumber extends Barcode {
  BarcodeNumber(
    super.printerSize,
    super._barcodeType,
    super.code,
    super._textPosition,
    super.widthMM,
    super.heightMM,
  ) {
    checkCode();
  }

  void checkCode() {
    int codeLength = getCodeLength - 1;

    if (code.length < codeLength) {
      throw const EscPosBarcodeException("Code is too short for the barcode type.");
    }

    try {
      String code = this.code.substring(0, codeLength);
      int totalBarcodeKey = 0;
      for (int i = 0; i < codeLength; i++) {
        int pos = codeLength - 1 - i, intCode = int.parse(code.substring(pos, pos + 1), radix: 10);
        if (i % 2 == 0) {
          intCode = 3 * intCode;
        }
        totalBarcodeKey += intCode;
      }

      String barcodeKey = (10 - (totalBarcodeKey % 10)).toString();
      if (barcodeKey.length == 2) {
        barcodeKey = "0";
      }

      this.code = code + barcodeKey;
    } on FormatException catch (_) {
      throw const EscPosBarcodeException("Invalid barcode number");
    }
  }

  @override
  int get getCodeLength => getCode.length;

  @override
  int get getColsCount => getCodeLength * 7 + 11;
}
