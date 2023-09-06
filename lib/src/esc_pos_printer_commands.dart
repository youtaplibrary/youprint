import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:youprint/src/esc_pos_charset_encoding.dart';

import 'connection/device_connection.dart';

class EscPosPrinterCommands {
  static const int lF = 0x0A;

  static const List<int> resetPrinter = <int>[0x1B, 0x40];

  static const List<int> textAlignLeft = <int>[0x1B, 0x61, 0x00];
  static const List<int> textAlignCenter = <int>[0x1B, 0x61, 0x01];
  static const List<int> textAlignRight = <int>[0x1B, 0x61, 0x02];

  static const List<int> textWeightNormal = <int>[0x1B, 0x45, 0x00];
  static const List<int> textWeightBold = <int>[0x1B, 0x45, 0x01];

  static const List<int> lineSpacing24 = <int>[0x1b, 0x33, 0x18];
  static const List<int> lineSpacing30 = <int>[0x1b, 0x33, 0x1e];

  static const List<int> textSizeNormal = <int>[0x1D, 0x21, 0x00];
  static const List<int> textSizeDoubleHeight = <int>[0x1D, 0x21, 0x01];
  static const List<int> textSizeDoubleWidth = <int>[0x1D, 0x21, 0x10];
  static const List<int> textSizeBig = <int>[0x1D, 0x21, 0x11];
  static const List<int> textSizeBig2 = <int>[0x1D, 0x21, 0x22];
  static const List<int> textSizeBig3 = <int>[0x1D, 0x21, 0x33];
  static const List<int> textSizeBig4 = <int>[0x1D, 0x21, 0x44];
  static const List<int> textSizeBig5 = <int>[0x1D, 0x21, 0x55];
  static const List<int> textSizeBig6 = <int>[0x1D, 0x21, 0x66];

  static const List<int> textUnderlineOff = <int>[0x1B, 0x2D, 0x00];
  static const List<int> textUnderLineOn = <int>[0x1B, 0x2D, 0x01];
  static const List<int> textUnderLineLarge = <int>[0x1B, 0x2D, 0x02];

  static const List<int> textDoubleStrikeOff = <int>[0x1B, 0x47, 0x00];
  static const List<int> textDoubleStrikeOn = <int>[0x1B, 0x47, 0x01];

  static const List<int> textColorBlack = <int>[0x1B, 0x72, 0x00];
  static const List<int> textColorRed = <int>[0x1B, 0x72, 0x01];

  static const List<int> textColorReverseOff = <int>[0x1D, 0x42, 0x00];
  static const List<int> textColorReverseOn = <int>[0x1D, 0x42, 0x01];

  static const int barcodeTypeUPCA = 65;
  static const int barcodeTypeUPCE = 66;
  static const int barcodeTypeEAN13 = 67;
  static const int barcodeTypeEAN8 = 68;
  static const int barcodeType128 = 73;

  static const int barcodeTextPositionNone = 0;
  static const int barcodeTextPositionAbove = 1;
  static const int barcodeTextPositionBelow = 2;

  static const int qrCode1 = 49;
  static const int qrCode2 = 50;

  final DeviceConnection _printerConnection;
  late final EscPosCharsetEncoding _charsetEncoding;
  bool _useEscAsteriskCommand = false;

  /// Create constructor of EscPosPrinterCommands
  /// @param [_printerConnection] an instance of a class which implement DeviceConnection

  EscPosPrinterCommands(this._printerConnection, EscPosCharsetEncoding? charsetEncoding) {
    _charsetEncoding = charsetEncoding ?? EscPosCharsetEncoding("windows-1252", 16);
  }

  static Uint8List initGSv0Command(int bytesByLine, int bitmapHeight) {
    double xH = bytesByLine / 256,
        xL = bytesByLine - (xH * 256),
        yH = bitmapHeight / 256,
        yL = bitmapHeight - (yH * 256);

    Uint8List imageBytes = Uint8List(8 + bytesByLine * bitmapHeight);
    imageBytes[0] = 0x1D;
    imageBytes[1] = 0x76;
    imageBytes[2] = 0x30;
    imageBytes[3] = 0x00;
    imageBytes[4] = xL.toInt();
    imageBytes[5] = xH.toInt();
    imageBytes[6] = yL.toInt();
    imageBytes[7] = yH.toInt();
    return imageBytes;
  }

  void reset() {
    _printerConnection.write(EscPosPrinterCommands.resetPrinter);
  }

  EscPosPrinterCommands setAlign(Uint8List align) {
    _printerConnection.write(align);
    return this;
  }

  List<int> _currentTextSize = Uint8List(0);
  List<int> _currentTextColor = Uint8List(0);
  List<int> _currentTextReverseColor = Uint8List(0);
  List<int> _currentTextBold = Uint8List(0);
  List<int> _currentTextUnderline = Uint8List(0);
  List<int> _currentTextDoubleStrike = Uint8List(0);

  EscPosPrinterCommands printText(
    String text,
    List<int>? textSize,
    List<int>? textColor,
    List<int>? textReverseColor,
    List<int>? textBold,
    List<int>? textUnderline,
    List<int>? textDoubleStrike,
  ) {
    textSize ??= EscPosPrinterCommands.textSizeNormal;
    textColor ??= EscPosPrinterCommands.textColorBlack;
    textReverseColor ??= EscPosPrinterCommands.textColorReverseOff;
    textBold ??= EscPosPrinterCommands.textWeightNormal;
    textUnderline ??= EscPosPrinterCommands.textUnderlineOff;
    textDoubleStrike ??= EscPosPrinterCommands.textDoubleStrikeOff;

    List<int> textBytes = utf8.encode(text);
    _printerConnection.write(_charsetEncoding.getCommand);

    if (!listEquals(_currentTextSize, textSize)) {
      _printerConnection.write(textSize);
      _currentTextSize = textSize;
    }

    if (!listEquals(_currentTextDoubleStrike, textDoubleStrike)) {
      _printerConnection.write(textDoubleStrike);
      _currentTextDoubleStrike = textDoubleStrike;
    }

    if (!listEquals(_currentTextUnderline, textUnderline)) {
      _printerConnection.write(textUnderline);
      _currentTextUnderline = textUnderline;
    }

    if (!listEquals(_currentTextBold, textBold)) {
      _printerConnection.write(textBold);
      _currentTextBold = textBold;
    }

    if (!listEquals(_currentTextColor, textColor)) {
      _printerConnection.write(textColor);
      _currentTextColor = textColor;
    }

    if (!listEquals(_currentTextReverseColor, textReverseColor)) {
      _printerConnection.write(textReverseColor);
      _currentTextReverseColor = textReverseColor;
    }

    _printerConnection.write(textBytes);

    return this;
  }

  void printAllCharsetsEncodingCharacters() {
    for (int charsetId = 0; charsetId < 256; ++charsetId) {
      printCharsetEncodingCharacters(charsetId);
    }
  }

  void printCharsetsEncodingCharactersWithId(List<int> charsetsId) {
    for (int charsetId in charsetsId) {
      printCharsetEncodingCharacters(charsetId);
    }
  }

  void printCharsetEncodingCharacters(int charsetId) {
    _printerConnection.write([0x1B, 0x74, charsetId]);
    _printerConnection.write(EscPosPrinterCommands.textSizeNormal);
    _printerConnection.write(EscPosPrinterCommands.textColorBlack);
    _printerConnection.write(EscPosPrinterCommands.textColorReverseOff);
    _printerConnection.write(EscPosPrinterCommands.textWeightNormal);
    _printerConnection.write(EscPosPrinterCommands.textUnderlineOff);
    _printerConnection.write(EscPosPrinterCommands.textDoubleStrikeOff);
    _printerConnection.write(utf8.encode(':::: Charset n°$charsetId : '));
    _printerConnection.write([
      0x00,
      0x01,
      0x02,
      0x03,
      0x04,
      0x05,
      0x06,
      0x07,
      0x08,
      0x09,
      0x0A,
      0x0B,
      0x0C,
      0x0D,
      0x0E,
      0x0F,
      0x10,
      0x11,
      0x12,
      0x13,
      0x14,
      0x15,
      0x16,
      0x17,
      0x18,
      0x19,
      0x1A,
      0x1B,
      0x1C,
      0x1D,
      0x1E,
      0x1F,
      0x20,
      0x21,
      0x22,
      0x23,
      0x24,
      0x25,
      0x26,
      0x27,
      0x28,
      0x29,
      0x2A,
      0x2B,
      0x2C,
      0x2D,
      0x2E,
      0x2F,
      0x30,
      0x31,
      0x32,
      0x33,
      0x34,
      0x35,
      0x36,
      0x37,
      0x38,
      0x39,
      0x3A,
      0x3B,
      0x3C,
      0x3D,
      0x3E,
      0x3F,
      0x40,
      0x41,
      0x42,
      0x43,
      0x44,
      0x45,
      0x46,
      0x47,
      0x48,
      0x49,
      0x4A,
      0x4B,
      0x4C,
      0x4D,
      0x4E,
      0x4F,
      0x50,
      0x51,
      0x52,
      0x53,
      0x54,
      0x55,
      0x56,
      0x57,
      0x58,
      0x59,
      0x5A,
      0x5B,
      0x5C,
      0x5D,
      0x5E,
      0x5F,
      0x60,
      0x61,
      0x62,
      0x63,
      0x64,
      0x65,
      0x66,
      0x67,
      0x68,
      0x69,
      0x6A,
      0x6B,
      0x6C,
      0x6D,
      0x6E,
      0x6F,
      0x70,
      0x71,
      0x72,
      0x73,
      0x74,
      0x75,
      0x76,
      0x77,
      0x78,
      0x79,
      0x7A,
      0x7B,
      0x7C,
      0x7D,
      0x7E,
      0x7F,
      0x80,
      0x81,
      0x82,
      0x83,
      0x84,
      0x85,
      0x86,
      0x87,
      0x88,
      0x89,
      0x8A,
      0x8B,
      0x8C,
      0x8D,
      0x8E,
      0x8F,
      0x90,
      0x91,
      0x92,
      0x93,
      0x94,
      0x95,
      0x96,
      0x97,
      0x98,
      0x99,
      0x9A,
      0x9B,
      0x9C,
      0x9D,
      0x9E,
      0x9F,
      0xA0,
      0xA1,
      0xA2,
      0xA3,
      0xA4,
      0xA5,
      0xA6,
      0xA7,
      0xA8,
      0xA9,
      0xAA,
      0xAB,
      0xAC,
      0xAD,
      0xAE,
      0xAF,
      0xB0,
      0xB1,
      0xB2,
      0xB3,
      0xB4,
      0xB5,
      0xB6,
      0xB7,
      0xB8,
      0xB9,
      0xBA,
      0xBB,
      0xBC,
      0xBD,
      0xBE,
      0xBF,
      0xC0,
      0xC1,
      0xC2,
      0xC3,
      0xC4,
      0xC5,
      0xC6,
      0xC7,
      0xC8,
      0xC9,
      0xCA,
      0xCB,
      0xCC,
      0xCD,
      0xCE,
      0xCF,
      0xD0,
      0xD1,
      0xD2,
      0xD3,
      0xD4,
      0xD5,
      0xD6,
      0xD7,
      0xD8,
      0xD9,
      0xDA,
      0xDB,
      0xDC,
      0xDD,
      0xDE,
      0xDF,
      0xE0,
      0xE1,
      0xE2,
      0xE3,
      0xE4,
      0xE5,
      0xE6,
      0xE7,
      0xE8,
      0xE9,
      0xEA,
      0xEB,
      0xEC,
      0xED,
      0xEE,
      0xEF,
      0xF0,
      0xF1,
      0xF2,
      0xF3,
      0xF4,
      0xF5,
      0xF6,
      0xF7,
      0xF8,
      0xF9,
      0xFA,
      0xFB,
      0xFC,
      0xFD,
      0xFE,
      0xFF
    ]);
    _printerConnection.write(
      [
        EscPosPrinterCommands.lF,
        EscPosPrinterCommands.lF,
        EscPosPrinterCommands.lF,
        EscPosPrinterCommands.lF
      ],
    );
  }

  void useEscAsteriskCommand(bool enable) {
    _useEscAsteriskCommand = enable;
  }

  EscPosPrinterCommands? newLine() {
    return newLineAlign(null);
  }

  EscPosPrinterCommands? newLineAlign(List<int>? align) {
    _printerConnection.write([EscPosPrinterCommands.lF]);
    if (align != null) {
      _printerConnection.write(align);
    }
    return this;
  }

  void feedPaper(int dots) {
    if (dots > 0) {
      _printerConnection.write([0x1B, 0x4A, dots]);
    }
  }

  void cutPaper() {
    _printerConnection.write([0x1D, 0x56, 0x01]);
  }

  void openCashBox() {
    _printerConnection.write([0x1B, 0x70, 0x00, 0x3C, 0xFF]);
  }

  EscPosCharsetEncoding get getCharsetEncoding => _charsetEncoding;
}
