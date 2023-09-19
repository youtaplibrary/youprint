import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:youprint/src/exceptions/exception.dart';
import 'package:youprint/youprint.dart';

class PrinterTextParserImg implements PrinterTextParserElement {
  int _length = 0;
  Uint8List _image = Uint8List(0);

  PrinterTextParserImg(
    PrinterTextParserColumn printerTextParserColumn,
    String textAlign, {
    String? hexadecimalString,
    Uint8List? bytes,
  }) {
    EscPosPrinter printer = printerTextParserColumn.getLine.getTextParser.getPrinter;
    Uint8List image = Uint8List(0);

    if (hexadecimalString != null) {
      image = PrinterTextParserImg.hexadecimalStringToBytes(hexadecimalString);
    }

    if (bytes != null) {
      image = bytes;
    }

    int byteWidth = (image[4] & 0xFF) + ((image[5] & 0xFF) * 256),
        width = byteWidth * 8,
        height = (image[6] & 0xFF) + (image[7] & 0xFF) * 256,
        nbrByteDiff = ((printer.getPrinterWidthPx - width) / 8).floor(),
        nbrWhiteByteToInsert = 0;

    switch (textAlign) {
      case PrinterTextParser.tagsAlignCenter:
        nbrWhiteByteToInsert = (nbrByteDiff / 2).round();
        break;
      case PrinterTextParser.tagsAlignRight:
        nbrWhiteByteToInsert = nbrByteDiff;
        break;
    }

    // nbrWhiteByteToInsert = 0;
    if (nbrWhiteByteToInsert > 0) {
      int newByteWidth = byteWidth + nbrWhiteByteToInsert;
      Uint8List newImage = EscPosPrinterCommands.initGSv0Command(newByteWidth, height);
      for (int i = 0; i < height; i++) {
        newImage.setRange(
          (newByteWidth * i + nbrWhiteByteToInsert + 8),
          (newByteWidth * i + nbrWhiteByteToInsert + 8) + byteWidth,
          image,
          (byteWidth * i + 8),
        );
      }

      image = newImage;
    }

    _length = ((byteWidth * 8) / printer.getPrinterWidthPx).ceil();
    _image = image;
  }

  static String imageToHexadecimalString(
    EscPosPrinterSize printerSize,
    Image image,
    bool gradient,
  ) {
    return PrinterTextParserImg.bytesToHexadecimalString(printerSize.imageToBytes(image, gradient));
  }

  static String base64ImageToHexadecimalString(
    EscPosPrinterSize printerSize,
    String base64Image,
    bool gradient,
  ) {
    final Image? image = decodeImage(base64.decode(base64Image));
    if (image == null) throw const EscPosParserException('Failed to parse base64 to image');
    return PrinterTextParserImg.bytesToHexadecimalString(printerSize.imageToBytes(image, gradient));
  }

  static String bytesToHexadecimalString(Uint8List bytes) {
    StringBuffer imageHexString = StringBuffer();
    for (int aByte in bytes) {
      String hexString = (aByte & 0xFF).toRadixString(16).padLeft(2, '0');
      imageHexString.write(hexString);
    }
    return imageHexString.toString();
  }

  static Uint8List hexadecimalStringToBytes(String hexString) {
    Uint8List bytes = Uint8List(hexString.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      int pos = i * 2;
      bytes[i] = int.parse(hexString.substring(pos, pos + 2), radix: 16);
    }
    return bytes;
  }

  @override
  int length() => _length;

  @override
  PrinterTextParserImg print(EscPosPrinterCommands printerSocket) {
    printerSocket.printImage(_image);
    return this;
  }
}
