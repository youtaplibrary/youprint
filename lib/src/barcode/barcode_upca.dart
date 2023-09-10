import 'package:youprint/src/barcode/barcode_number.dart';
import 'package:youprint/youprint.dart';

class BarcodeUPCA extends BarcodeNumber {
  BarcodeUPCA(
      EscPosPrinterSize printerSize, String code, double widthMM, double heightMM, int textPosition)
      : super(printerSize, EscPosPrinterCommands.barcodeTypeUPCA, code, textPosition, widthMM,
            heightMM);

  @override
  int get getCodeLength => 12;
}
