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

  String _formattedLine(String text) {
    if (textStyle.type == ReceiptTextStyleType.bold) {
      return '$_alignmentStyleContent<b><${textStyle.textStyleContent} ${textStyle.textSizeContent}>$text</${textStyle.textStyleContent}></b>\n';
    }
    return '$_alignmentStyleContent<${textStyle.textStyleContent} ${textStyle.textSizeContent}>$text</${textStyle.textStyleContent}>\n';
  }

  String get content {
    StringBuffer stringBuffer = StringBuffer();
    final int maxChar = Youprint.printerNbrCharactersPerLine;
    final multiLines = alignment == ReceiptAlignment.center ? text.splitByLength(maxChar) : [text];

    for (String line in multiLines) {
      stringBuffer.write(_formattedLine(line));
    }

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
