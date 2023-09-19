import 'package:flutter/foundation.dart';

abstract class PrinterFeatureRule {
  const factory PrinterFeatureRule.allowFor(
    String printerName,
  ) = _AllowingPrinterFeatureRule;

  static const PrinterFeatureRule allowAll = _AllowAllPrinterFeatureRule();
}

@immutable
class _AllowingPrinterFeatureRule implements PrinterFeatureRule {
  const _AllowingPrinterFeatureRule(this.printerName);

  final String printerName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _AllowingPrinterFeatureRule &&
            other.printerName == printerName;
  }

  @override
  int get hashCode => Object.hash(runtimeType, printerName.hashCode);
}

class _AllowAllPrinterFeatureRule implements PrinterFeatureRule {
  const _AllowAllPrinterFeatureRule();
}
