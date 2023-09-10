import 'package:youprint/src/barcode/barcode_number.dart';
import 'package:youprint/youprint.dart';

class BarcodeEAN13 extends BarcodeNumber {
  BarcodeEAN13(
      EscPosPrinterSize printerSize, String code, double widthMM, double heightMM, int textPosition)
      : super(printerSize, EscPosPrinterCommands.barcodeTypeEAN13, code, textPosition, widthMM,
            heightMM);

  @override
  int get getCodeLength => 13;
}
