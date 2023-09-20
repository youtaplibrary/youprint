import 'package:youprint/youprint.dart';

import 'collection_style.dart';
import 'receipt_text_style.dart';

class ReceiptText {
  ReceiptText(
    this.text, {
    this.textStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      size: ReceiptTextSizeType.medium,
    ),
    this.alignment = ReceiptAlignment.center,
  });

  final String text;
  final ReceiptTextStyle textStyle;
  final ReceiptAlignment alignment;

  String get content {
    StringBuffer stringBuffer = StringBuffer();
    if (alignment == ReceiptAlignment.center) {
      if (text.length > 32) {
        final multiLines = text.splitByLength(32);
        for (String line in multiLines) {
          stringBuffer
            ..write(_alignmentStyleContent)
            ..write("<${textStyle.textStyleContent} ${textStyle.textSizeContent}>")
            ..write(line)
            ..write("</${textStyle.textStyleContent}>\n");
        }
        return stringBuffer.toString();
      }
    }
    stringBuffer
      ..write(_alignmentStyleContent)
      ..write("<${textStyle.textStyleContent} ${textStyle.textSizeContent}>")
      ..write(text)
      ..write("</${textStyle.textStyleContent}>\n");

    return stringBuffer.toString();
  }

  String get _alignmentStyleContent {
    if (alignment == ReceiptAlignment.left) {
      return CollectionStyle.textLeft;
    } else if (alignment == ReceiptAlignment.right) {
      return CollectionStyle.textRight;
    }
    return CollectionStyle.textCenter;
  }
}
