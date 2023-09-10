import 'package:youprint/src/esc_pos_printer_size.dart';
import 'package:youprint/src/exceptions/exception.dart';

abstract class Barcode {
  int? barcodeType;
  String code;
  int? textPosition;
  int? _colWidth;
  int? _height;

  Barcode(
    EscPosPrinterSize printerSize,
    this.barcodeType,
    this.code,
    this.textPosition,
    double widthMM,
    double heightMM,
  ) {
    _height = printerSize.mmToPx(heightMM);

    if (widthMM == 0) {
      widthMM = printerSize.getPrinterWidthMM * 0.7;
    }

    int wantedPxWidth = widthMM > printerSize.getPrinterWidthMM
            ? printerSize.getPrinterWidthPx
            : printerSize.mmToPx(widthMM),
        colWidth = (wantedPxWidth / getColsCount).round();

    if ((colWidth * getColsCount) > printerSize.getPrinterWidthPx) {
      --colWidth;
    }

    if (colWidth == 0) {
      throw const EscPosBarcodeException("Barcode is too long for the paper size.");
    }

    _colWidth = colWidth;
  }

  int get getCodeLength;
  int get getColsCount;

  int get getBarcodeType => barcodeType ?? 0;
  String get getCode => code;
  int get getHeight => _height ?? 0;
  int get getTextPosition => textPosition ?? 0;
  int get getColWidth => _colWidth ?? 0;

  void setCode(String value) {
    code = value;
  }
}
