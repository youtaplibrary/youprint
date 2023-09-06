class EscPosPrinterSize {
  static const double inchToMM = 25.4;

  final int printerDpi;
  final double printerWidthMM;
  final int _printerNbrCharactersPerLine;
  int? printerWidthPx;
  int printerCharSizeWidthPx = 0;
  int? printerNbrCharactersPerLine;

  EscPosPrinterSize(
    this.printerDpi,
    this.printerWidthMM,
    this._printerNbrCharactersPerLine,
  ) {
    int printingWidthPx = (printerWidthMM * printerDpi / EscPosPrinterSize.inchToMM).round();
    printerWidthPx = printingWidthPx + (printingWidthPx % 8);
    printerCharSizeWidthPx = printingWidthPx ~/ _printerNbrCharactersPerLine;
  }

  int get getPrinterNbrCharactersPerLine =>
      printerNbrCharactersPerLine ?? _printerNbrCharactersPerLine;
  double get getPrinterWidthMM => printerWidthMM;
  int get getPrinterDpi => printerDpi;
  int get getPrinterWidthPx => printerWidthPx ?? 0;
  int get getPrinterCharSizeWidthPx => printerCharSizeWidthPx;
  int mmToPx(double mmSize) {
    return (mmSize * printerDpi / EscPosPrinterSize.inchToMM).round();
  }
}
