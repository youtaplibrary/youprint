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
    String text = '';
    if (leftText.length > 16) {
      final multiLine = splitStringByLength(leftText, 16);

      for (String line in multiLine) {
        text +=
            '[L]<${leftTextStyle.textStyleContent} ${leftTextStyle.textSizeContent}>$line</${leftTextStyle.textStyleContent}>\n';
      }
    } else {
      text +=
          '[L]<${leftTextStyle.textStyleContent} ${leftTextStyle.textSizeContent}>$leftText</${leftTextStyle.textStyleContent}>';
    }

    if (rightText.length > 16) {
      final multiLine = splitStringByLength(rightText, 16);
      for (String line in multiLine) {
        text +=
            '[R]<${rightTextStyle.textStyleContent} ${rightTextStyle.textSizeContent}>$line</${rightTextStyle.textStyleContent}>\n';
      }
    } else {
      text +=
          '[R]<${rightTextStyle.textStyleContent} ${rightTextStyle.textSizeContent}>$rightText</${rightTextStyle.textStyleContent}>';
    }
    return '$text\n';
  }

  List<String> splitStringByLength(String str, int length) =>
      [str.substring(0, length), str.substring(length)];
}
