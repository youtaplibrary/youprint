import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:youprint/src/barcode/barcode.dart';
import 'package:youprint/src/esc_pos_charset_encoding.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/qrcode.dart' as qr;
import 'package:zxing_lib/zxing.dart';

import 'connection/device_connection.dart';
import 'exceptions/esc_pos_barcode_exception.dart';
import 'exceptions/esc_pos_encoding_exception.dart';

class EscPosPrinterCommands {
  static const int lF = 0x0A;

  static const List<int> resetPrinter = <int>[0x1B, 0x40];

  static const List<int> textAlignLeft = <int>[0x1B, 0x61, 0x00];
  static const List<int> textAlignCenter = <int>[0x1B, 0x61, 0x01];
  static const List<int> textAlignRight = <int>[0x1B, 0x61, 0x02];

  static const List<int> textWeightNormal = <int>[0x1B, 0x45, 0x00];
  static const List<int> textWeightBold = <int>[0x1B, 0x45, 0x01];

  static const List<int> lineSpacing16 = <int>[0x1b, 0x33, 0x10];
  static const List<int> lineSpacing24 = <int>[0x1b, 0x33, 0x18];
  static const List<int> lineSpacing30 = <int>[0x1b, 0x33, 0x1e];
  static const List<int> resetLineSpacing = <int>[0x1b, 0x32];

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

  /// Create constructor of EscPosPrinterCommands
  /// @param [_printerConnection] an instance of a class which implement DeviceConnection

  EscPosPrinterCommands(this._printerConnection, EscPosCharsetEncoding? charsetEncoding) {
    _charsetEncoding = charsetEncoding ?? EscPosCharsetEncoding("windows-1252", 16);
  }

  static Uint8List initGSv0Command(int bytesByLine, int imageHeight) {
    int xH = bytesByLine ~/ 256,
        xL = bytesByLine - (xH * 256),
        yH = imageHeight ~/ 256,
        yL = imageHeight - (yH * 256);

    Uint8List imageBytes = Uint8List(8 + bytesByLine * imageHeight);
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

  static List<Uint8List> convertGsv0ToEscAsterisk(Uint8List bytes) {
    int xL = bytes[4] & 0xFF,
        xH = bytes[5] & 0xFF,
        yL = bytes[6] & 0xFF,
        yH = bytes[7] & 0xFF,
        bytesByLine = xH * 256 + xL,
        dotsByLine = bytesByLine * 8,
        nH = dotsByLine ~/ 256,
        nL = dotsByLine % 256,
        imageHeight = yH * 256 + yL,
        imageLineHeightCount = (imageHeight / 24.0).ceil(),
        imageBytesSize = 6 + bytesByLine * 24;

    List<Uint8List> returnedBytes = List.filled(imageLineHeightCount + 2, Uint8List(0));
    returnedBytes[0] = Uint8List.fromList(EscPosPrinterCommands.lineSpacing16);
    for (int i = 0; i < imageLineHeightCount; ++i) {
      int pxBaseRow = i * 24;
      Uint8List imageBytes = Uint8List(imageBytesSize);
      imageBytes[0] = 0x1B;
      imageBytes[1] = 0x2A;
      imageBytes[2] = 0x21;
      imageBytes[3] = nL;
      imageBytes[4] = nH;
      for (int j = 5; j < imageBytes.length; ++j) {
        int imgByte = j - 5,
            byteRow = imgByte % 3,
            pxColumn = imgByte ~/ 3,
            bitColumn = 1 << (7 - pxColumn % 8),
            pxRow = pxBaseRow + byteRow * 8;
        for (int k = 0; k < 8; ++k) {
          int indexBytes = bytesByLine * (pxRow + k) + pxColumn ~/ 8 + 8;

          if (indexBytes >= bytes.length) {
            break;
          }

          bool isBlack = (bytes[indexBytes] & bitColumn) == bitColumn;
          if (isBlack) {
            imageBytes[j] |= 1 << 7 - k;
          }
        }
      }
      imageBytes[imageBytes.length - 1] = EscPosPrinterCommands.lF;
      returnedBytes[i + 1] = imageBytes;
    }
    returnedBytes[returnedBytes.length - 1] = Uint8List.fromList(
      EscPosPrinterCommands.lineSpacing16,
    );
    return returnedBytes;
  }

  static Uint8List convertQRCodeToBytes(String data, int size) {
    qr.QRCodeWriter writer = qr.QRCodeWriter();
    BitMatrix matrix;

    size = size > 360 ? 360 : size;

    try {
      matrix = writer.encode(
        data,
        BarcodeFormat.qrCode,
        size,
        size,
        const EncodeHint(
          characterSet: "ISO-8859-1",
          errorCorrectionLevel: qr.ErrorCorrectionLevel.M,
        ),
      );
    } catch (e) {
      throw const EscPosBarcodeException("Unable to encode QR code");
    }

    Image image = Image(size, size, channels: Channels.rgb);
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        //-16777216 is black -1 is white
        image.setPixel(x, y, matrix.get(x, y) ? -16777216 : -1);
      }
    }

    return Uint8List.fromList(imageToBytes(image));
  }

  static List<int> imageToBytes(Image imageSrc) {
    List<int> bytes = [];

    final Image image = Image.from(imageSrc);

    invert(image);
    flip(image, Flip.horizontal);
    final Image imageRotated = copyRotate(image, 270);

    // height vertical density use 1 for low
    const int lineHeight = 3;
    final List<List<int>> blobs = _toColumnFormat(imageRotated, lineHeight * 8);

    // Compress according to line density
    // Line height contains 8 or 24 pixels of src image
    // Each blobs[i] contains greyscale bytes [0-255]
    // const int pxPerLine = 24 ~/ lineHeight;
    for (int blobInd = 0; blobInd < blobs.length; blobInd++) {
      blobs[blobInd] = _packBitsIntoBytes(blobs[blobInd]);
    }

    final int heightPx = imageRotated.height;

    // set high density, use 0 for low density
    const int densityByte = 33;
    final List<int> header = [0x1B, 0x2A];
    header.add(densityByte);
    header.addAll(_intLowHigh(heightPx, 2));

    // Adjust line spacing (for 16-unit line feeds): ESC 3 0x10 (HEX: 0x1b 0x33 0x10)
    bytes += lineSpacing16;
    for (int i = 0; i < blobs.length; ++i) {
      bytes += List.from(header)
        ..addAll(blobs[i])
        ..addAll('\n'.codeUnits);
    }
    // Reset line spacing: ESC 2 (HEX: 0x1b 0x32)
    bytes += resetLineSpacing;

    return bytes;
  }

  /// Generate multiple bytes for a number: In lower and higher parts, or more parts as needed.
  ///
  /// [value] Input number
  /// [bytesNb] The number of bytes to output (1 - 4)
  static List<int> _intLowHigh(int value, int bytesNb) {
    final dynamic maxInput = 256 << (bytesNb * 8) - 1;

    if (bytesNb < 1 || bytesNb > 4) {
      throw Exception('Can only output 1-4 bytes');
    }
    if (value < 0 || value > maxInput) {
      throw Exception('Number is too large. Can only output up to $maxInput in $bytesNb bytes');
    }

    final List<int> res = <int>[];
    int buf = value;
    for (int i = 0; i < bytesNb; ++i) {
      res.add(buf % 256);
      buf = buf ~/ 256;
    }
    return res;
  }

  static List<int> _packBitsIntoBytes(List<int> bytes) {
    const pxPerLine = 8;
    final List<int> res = <int>[];
    const threshold = 127; // set the greyscale -> b/w threshold here
    for (int i = 0; i < bytes.length; i += pxPerLine) {
      int newVal = 0;
      for (int j = 0; j < pxPerLine; j++) {
        newVal = _transformUint32Bool(
          newVal,
          pxPerLine - j,
          bytes[i + j] > threshold,
        );
      }
      res.add(newVal ~/ 2);
    }
    return res;
  }

  /// Replaces a single bit in a 32-bit unsigned integer.
  static int _transformUint32Bool(int uint32, int shift, bool newValue) {
    return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) | ((newValue ? 1 : 0) << shift);
  }

  /// Extract slices of an image as equal-sized blobs of column-format data.
  ///
  /// [image] Image to extract from
  /// [lineHeight] Printed line height in dots
  static List<List<int>> _toColumnFormat(Image imgSrc, int lineHeight) {
    final Image image = Image.from(imgSrc); // make a copy

    // Determine new width: closest integer that is divisible by lineHeight
    final int widthPx = (image.width + lineHeight) - (image.width % lineHeight);
    final int heightPx = image.height;

    // Create a black bottom layer
    final biggerImage = copyResize(image, width: widthPx, height: heightPx);
    fill(biggerImage, 0);
    // Insert source image into bigger one
    drawImage(biggerImage, image, dstX: 0, dstY: 0);

    int left = 0;
    final List<List<int>> blobs = [];

    while (left < widthPx) {
      final Image slice = copyCrop(biggerImage, left, 0, lineHeight, heightPx);
      final Uint8List bytes = slice.getBytes(format: Format.luminance);
      blobs.add(bytes);
      left += lineHeight;
    }

    return blobs;
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

  EscPosPrinterCommands printImage(Uint8List image) {
    _printerConnection.write(image);
    return this;
  }

  EscPosPrinterCommands printQRCode(int qrCodeType, String text, int size) {
    if (size < 1) {
      size = 1;
    } else if (size > 16) {
      size = 16;
    }

    try {
      List<int> textBytes = utf8.encode(text);

      int commandLength = textBytes.length + 3, pL = commandLength % 256, pH = commandLength ~/ 256;

      _printerConnection.write([0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, qrCodeType, 0x00]);
      _printerConnection.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size]);
      _printerConnection.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30]);

      Uint8List qrCodeCommand = Uint8List(textBytes.length + 8);
      List<int> qrBytes = [0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30];
      qrCodeCommand.setRange(0, 8, qrBytes, 0);

      qrCodeCommand.setRange(8, 8 + textBytes.length, textBytes, 0);
      setAlign(Uint8List.fromList(EscPosPrinterCommands.textAlignCenter));
      _printerConnection.write(qrCodeCommand);
      _printerConnection.write([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    } catch (e) {
      throw EscPosEncodingException(e.toString());
    }
    return this;
  }

  EscPosPrinterCommands printBarcode(Barcode? barcode) {
    if (barcode == null) {
      return this;
    }

    String code = barcode.getCode;
    int barcodeLength = barcode.getCodeLength;
    Uint8List barcodeCommand = Uint8List(barcodeLength + 4);
    barcodeCommand.setRange(
        0, 4, Uint8List.fromList([0x1D, 0x6B, barcode.getBarcodeType, barcodeLength]), 0);

    for (int i = 0; i < barcodeLength; i++) {
      barcodeCommand[i + 4] = code.codeUnitAt(i);
    }

    _printerConnection.write([0x1D, 0x48, barcode.getTextPosition]);
    _printerConnection.write([0x1D, 0x77, barcode.getColWidth]);
    _printerConnection.write([0x1D, 0x68, barcode.getHeight]);
    _printerConnection.write(barcodeCommand);
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
      _printerConnection.write([0x1B, 0x64, dots]);
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
