import 'package:youprint/src/barcode/barcode_number.dart';
import 'package:youprint/youprint.dart';

class BarcodeEAN8 extends BarcodeNumber {
  BarcodeEAN8(
      EscPosPrinterSize printerSize, String code, double widthMM, double heightMM, int textPosition)
      : super(printerSize, EscPosPrinterCommands.barcodeTypeEAN8, code, textPosition, widthMM,
            heightMM);

  @override
  int get getCodeLength => 8;
}
