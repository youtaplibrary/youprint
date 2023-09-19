import 'package:youprint/src/youprint.dart';

class ReceiptBarcode {
  ReceiptBarcode(
    this.data, {
    this.size = 20,
  });

  final String data;
  final int size;

  int get mm => Youprint.pixelToMM(size);
  String get text => "[C]<barcode type='128' height='$mm'>$data</barcode>\n";
}
