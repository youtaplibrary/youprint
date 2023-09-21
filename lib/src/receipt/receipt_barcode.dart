import 'package:youprint/src/youprint.dart';

class ReceiptBarcode {
  ReceiptBarcode(
    this.data, {
    this.size = 20,
  });

  final String data;
  final int size;

  int get mm => Youprint.pxToMM(size);
  String get content => "[C]<barcode type='128' width='$mm'>$data</barcode>\n";
}
