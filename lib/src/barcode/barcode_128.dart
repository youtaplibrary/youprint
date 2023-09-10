import 'package:youprint/src/barcode/barcode.dart';
import 'package:youprint/youprint.dart';

class Barcode128 extends Barcode {
  Barcode128(
      EscPosPrinterSize printerSize, String code, double widthMM, double heightMM, int textPosition)
      : super(printerSize, EscPosPrinterCommands.barcodeType128, code, textPosition, widthMM,
            heightMM);

  @override
  int get getCodeLength => code.length;

  @override
  int get getColsCount => (getCodeLength + 5) * 11;
}
