import 'models.dart';

typedef PrinterFeatureMap = Map<PrinterFeatureRule, Set<PrinterFeature>>;

enum PrinterFeature {
  paperFullCut,
}

class PrinterFeatures {
  final PrinterFeatureMap featureMap = <PrinterFeatureRule, Set<PrinterFeature>>{};

  bool hasFeatureOf(String printerName, PrinterFeature feature) {
    const PrinterFeatureRule allowAllRule = PrinterFeatureRule.allowAll;
    final PrinterFeatureRule allowRule = PrinterFeatureRule.allowFor(printerName);
    return featureMap[allowAllRule]?.contains(feature) == true ||
        featureMap[allowRule]?.contains(feature) == true;
  }
}
