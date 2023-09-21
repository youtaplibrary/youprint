import 'dart:math';

import 'package:youprint/src/extensions/string_extension.dart';
import 'package:youprint/src/youprint.dart';

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

  String _formattedLine(
    String label,
    String text,
    ReceiptTextStyle textStyle, {
    bool useNewLine = false,
  }) {
    return '[$label]<${textStyle.textStyleContent} ${textStyle.textSizeContent}>$text</${textStyle.textStyleContent}>${useNewLine ? '\n' : ''}';
  }

  String get content {
    final int maxCharColumn = (Youprint.printerNbrCharactersPerLine ~/ 2) - 1;
    final leftMultiLine = leftText.splitByLength(maxCharColumn);
    final rightMultiLine = rightText.splitByLength(maxCharColumn);
    final maxLine = max(leftMultiLine.length, rightMultiLine.length);

    StringBuffer stringBuffer = StringBuffer();

    for (int i = 0; i < maxLine; i++) {
      final leftLine = i < leftMultiLine.length
          ? _formattedLine('L', leftMultiLine[i], leftTextStyle)
          : _formattedLine('L', '', leftTextStyle);

      final rightLine = i < rightMultiLine.length
          ? _formattedLine('R', rightMultiLine[i], rightTextStyle, useNewLine: true)
          : _formattedLine('R', '', rightTextStyle, useNewLine: true);

      stringBuffer.write(leftLine);
      stringBuffer.write(rightLine);
    }

    return stringBuffer.toString();
  }
}
