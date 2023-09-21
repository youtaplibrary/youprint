import 'package:youprint/src/youprint.dart';

class ReceiptQR {
  ReceiptQR(
    this.data, {
    this.size = 20,
  });

  final String data;
  final int size;

  int get mm => Youprint.pxToMM(size);
  String get content => "[C]<qrcode size='$mm'>$data</qrcode>\n";
}
