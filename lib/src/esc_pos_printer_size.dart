import 'package:image/image.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';

class EscPosPrinterSize {
  static const double inchToMM = 25.4;

  final int printerDpi;
  final double printerWidthMM;
  final int _printerNbrCharactersPerLine;
  int printerWidthPx = 0;
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

  List<int> imageToBytes(Image image, bool gradient) {
    bool isSizeEdit = false;
    int bitmapWidth = image.width,
        bitmapHeight = image.height,
        maxWidth = printerWidthPx,
        maxHeight = 256;

    if (bitmapWidth > maxWidth) {
      bitmapHeight = ((bitmapHeight) * (maxWidth) / (bitmapWidth)).round();
      bitmapWidth = maxWidth;
      isSizeEdit = true;
    }
    if (bitmapHeight > maxHeight) {
      bitmapWidth = ((bitmapWidth) * (maxHeight) / (bitmapHeight)).round();
      bitmapHeight = maxHeight;
      isSizeEdit = true;
    }

    if (isSizeEdit) {
      image = copyResize(image, width: bitmapWidth, height: bitmapHeight);
    }

    return EscPosPrinterCommands.imageToBytes(image);
  }

  int get getPrinterNbrCharactersPerLine =>
      printerNbrCharactersPerLine ?? _printerNbrCharactersPerLine;
  double get getPrinterWidthMM => printerWidthMM;
  int get getPrinterDpi => printerDpi;
  int get getPrinterWidthPx => printerWidthPx;
  int get getPrinterCharSizeWidthPx => printerCharSizeWidthPx;
  int mmToPx(double mmSize) {
    return (mmSize * printerDpi / EscPosPrinterSize.inchToMM).round();
  }
}
