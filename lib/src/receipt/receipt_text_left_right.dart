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

  String get html =>
      '[L]<${leftTextStyle.textStyleHTML} ${leftTextStyle.textSizeHtml}>$leftText</${leftTextStyle.textStyleHTML}>[R]<${rightTextStyle.textStyleHTML} ${rightTextStyle.textSizeHtml}>$rightText</${rightTextStyle.textStyleHTML}>\n';
}
