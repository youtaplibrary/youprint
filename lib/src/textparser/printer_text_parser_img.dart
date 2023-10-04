import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:youprint/src/exceptions/exception.dart';
import 'package:youprint/youprint.dart';

class PrinterTextParserImg implements PrinterTextParserElement {
  final int _length = 0;
  Uint8List _image = Uint8List(0);
  List<int> _align = [];
  int size = 0;

  PrinterTextParserImg(
    PrinterTextParserColumn printerTextParserColumn,
    String textAlign,
    HashMap<String, String> imageAttributes, {
    String? hexadecimalString,
    Uint8List? bytes,
  }) {
    Uint8List image = Uint8List(0);

    if (hexadecimalString != null) {
      image = PrinterTextParserImg.hexadecimalStringToBytes(hexadecimalString);
    }

    if (bytes != null) {
      image = bytes;
    }

    _align = EscPosPrinterCommands.textAlignLeft;
    switch (textAlign) {
      case PrinterTextParser.tagsAlignCenter:
        _align = EscPosPrinterCommands.textAlignCenter;
        break;
      case PrinterTextParser.tagsAlignRight:
        _align = EscPosPrinterCommands.textAlignRight;
        break;
    }
    _image = image;
  }

  static String imageToHexadecimalString(
    EscPosPrinterSize printerSize,
    Image image,
    bool gradient,
    int size,
  ) {
    final rescaledImage = copyResize(image, width: size);
    return PrinterTextParserImg.bytesToHexadecimalString(
      printerSize.imageToBytes(rescaledImage, gradient, size),
    );
  }

  static String base64ImageToHexadecimalString(
    EscPosPrinterSize printerSize,
    String base64Image,
    bool gradient,
    int size,
  ) {
    final Image? image = decodeImage(base64.decode(base64Image));
    if (image == null) throw const EscPosParserException('Failed to parse base64 to image');
    return PrinterTextParserImg.bytesToHexadecimalString(
      printerSize.imageToBytes(copyResize(image, width: size), gradient, size),
    );
  }

  static String bytesToHexadecimalString(List<int> bytes) {
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
    printerSocket.setAlign(Uint8List.fromList(_align)).printImage(_image);
    return this;
  }
}
