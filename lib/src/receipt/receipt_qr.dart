import 'package:youprint/src/youprint.dart';

class ReceiptQR {
  ReceiptQR(
    this.data, {
    this.size = 20,
  });

  final String data;
  final int size;

  int get mm => Youprint.pixelToMM(size);
  String get text => "[C]<qrcode size='$mm'>$data</qrcode>\n";
}
