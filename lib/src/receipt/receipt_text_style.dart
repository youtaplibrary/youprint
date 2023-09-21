import 'receipt_text_size_type.dart';
import 'receipt_text_style_type.dart';

class ReceiptTextStyle {
  const ReceiptTextStyle({
    this.type = ReceiptTextStyleType.normal,
    this.size = ReceiptTextSizeType.medium,
    this.useSpan = false,
  });

  /// [type] to define weight of text
  /// [ReceiptTextStyleType.normal] for normal weight
  /// [ReceiptTextStyleType.bold] for more weight than normal type
  final ReceiptTextStyleType type;

  /// [size] define size of text,
  final ReceiptTextSizeType size;

  /// [useSpan] used only for condition left right text
  final bool useSpan;

  /// Tag p for normal text, b for bold text and span for left right text
  /// This getter to get tag of text used
  String get textStyleContent {
    return 'font';
  }

  /// This getter to get style of alignment text
  String get textSizeContent {
    switch (size) {
      case ReceiptTextSizeType.small:
        return "size='normal'";
      case ReceiptTextSizeType.medium:
        return "size='normal'";
      case ReceiptTextSizeType.large:
        return "size='wide'";
      case ReceiptTextSizeType.extraLarge:
        return "size='wide'";
      default:
        return "size='normal'";
    }
  }
}
