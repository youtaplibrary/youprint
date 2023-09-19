import 'package:youprint/src/youprint.dart';

import 'collection_style.dart';
import 'receipt.dart';

class ReceiptImage {
  ReceiptImage(
    this.base64, {
    this.alignment = ReceiptAlignment.center,
    this.width = 120,
  });

  final String base64;
  final int width;
  final ReceiptAlignment alignment;

  String get text =>
      "$_alignmentStyle<img size='$width'>${Youprint.base64toHexadecimal(base64)}</img>\n";

  String get _alignmentStyle {
    if (alignment == ReceiptAlignment.left) {
      return CollectionStyle.textLeft;
    } else if (alignment == ReceiptAlignment.right) {
      return CollectionStyle.textRight;
    }
    return CollectionStyle.textCenter;
  }
}
