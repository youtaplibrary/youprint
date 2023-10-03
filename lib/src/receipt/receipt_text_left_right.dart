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
    this.prefixText = '',
    this.prefixTextStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      useSpan: true,
    ),
    this.maxCharLeftText,
  });

  final String leftText;
  final String rightText;
  final ReceiptTextStyle leftTextStyle;
  final ReceiptTextStyle rightTextStyle;
  final String prefixText;
  final ReceiptTextStyle prefixTextStyle;
  final int? maxCharLeftText;

  String _formattedLine(
    String label,
    String text,
    ReceiptTextStyle textStyle, {
    int index = 0,
    bool useNewLine = false,
  }) {
    if (prefixText.isNotEmpty && label == 'L' && index == 0) {
      if (prefixTextStyle.type == ReceiptTextStyleType.bold) {
        text = '<b>$prefixText</b>$text';
      } else {
        text = prefixText + text;
      }
    } else if (prefixText.isNotEmpty && label == 'L') {
      // 32 is ASCII for space
      final spaces = String.fromCharCode(32) * prefixText.length;
      text = spaces + text;
    }
    return '[$label]<${textStyle.textStyleContent} ${textStyle.textSizeContent}>$text</${textStyle.textStyleContent}>${useNewLine ? '\n' : ''}';
  }

  String get content {
    final int maxCharLine = Youprint.printerNbrCharactersPerLine;
    final int maxCharColumn = maxCharLine - (maxCharLeftText ?? (maxCharLine ~/ 2)) - 1;
    final leftMultiLine = leftText.splitByLength(
      maxCharLeftText ?? maxCharColumn,
      numSpace: prefixText.length,
    );

    final rightMultiLine = rightText.splitByLength(maxCharColumn);
    final maxLine = max(leftMultiLine.length, rightMultiLine.length);

    StringBuffer stringBuffer = StringBuffer();

    for (int i = 0; i < maxLine; i++) {
      final leftLine = i < leftMultiLine.length
          ? _formattedLine('L', leftMultiLine[i], leftTextStyle, index: i)
          : _formattedLine('L', '', leftTextStyle, index: i);

      final rightLine = i < rightMultiLine.length
          ? _formattedLine('R', rightMultiLine[i], rightTextStyle, useNewLine: true)
          : _formattedLine('R', '', rightTextStyle, useNewLine: true);

      stringBuffer.write(leftLine);
      stringBuffer.write(rightLine);
    }

    return stringBuffer.toString();
  }
}
