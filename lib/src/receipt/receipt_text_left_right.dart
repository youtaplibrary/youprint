import 'dart:math';

import 'package:youprint/src/extensions/string_extension.dart';

import 'receipt_text_style.dart';
import 'receipt_text_style_type.dart';

class ReceiptTextLeftRight {
  ReceiptTextLeftRight(
    this.leftText,
    this.rightText, {
    this.leftTextStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      useSpan: true,
    ),
    this.rightTextStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      useSpan: true,
    ),
  });

  final String leftText;
  final String rightText;
  final ReceiptTextStyle leftTextStyle;
  final ReceiptTextStyle rightTextStyle;

  String get content {
    StringBuffer stringBuffer = StringBuffer();
    final leftMultiLine = leftText.splitByLength(15);
    final rightMultiLine = rightText.splitByLength(15);
    final maxLine = max(leftMultiLine.length, rightMultiLine.length);

    for (int i = 0; i < maxLine; i++) {
      if (i > leftMultiLine.length - 1) {
        String leftLine = '[L]';
        stringBuffer.write(leftLine);
      } else {
        String leftLine = leftMultiLine[i];
        stringBuffer
          ..write("[L]")
          ..write("<${leftTextStyle.textStyleContent} ${leftTextStyle.textSizeContent}>")
          ..write(leftLine)
          ..write("</${leftTextStyle.textStyleContent}>");
      }

      if (i > rightMultiLine.length - 1) {
        String rightLine = '\n';
        stringBuffer.write(rightLine);
      } else {
        String rightLine = rightMultiLine[i];
        stringBuffer
          ..write("[R]")
          ..write("<${rightTextStyle.textStyleContent} ${rightTextStyle.textSizeContent}>")
          ..write(rightLine)
          ..write("</${rightTextStyle.textStyleContent}>\n");
      }
    }

    print(stringBuffer.toString());
    return stringBuffer.toString();
  }
}
