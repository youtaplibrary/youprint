import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';
import 'package:youprint/src/youprint.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/qrcode.dart';
import 'package:zxing_lib/zxing.dart';

class HtmlConverter {
  static String convertToHtmlReceipt(String formattedText) {
    final tagPattern = RegExp(r'\[(C|L|R)\]');
    final imgPattern = RegExp(r"\[C]<img width='(\d+)'>(.*?)<\/img>");
    final qrPattern = RegExp(r"\[C]<qrcode size='(\d+)'>(.*?)<\/qrcode>");
    final barcodePattern =
        RegExp(r"\[C]<barcode type='128' width='(\d+)'>(.*?)<\/barcode>");

    final htmlBuffer = StringBuffer();

    htmlBuffer.writeln('<!DOCTYPE html>');
    htmlBuffer.writeln('<html lang="en">');
    htmlBuffer.writeln('<head>');
    htmlBuffer.writeln('<meta charset="UTF-8">');
    htmlBuffer.writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    htmlBuffer.writeln('<title>Receipt</title>');
    htmlBuffer.writeln('<style>');
    htmlBuffer.writeln('''
      body, p { margin: 0px; padding: 0px; font-family: helvetica; }
      body { background: #eee; width: 576px; font-size: 1.8em; }
      .receipt { max-width: 576px; margin: auto; background: white; }
      .container { padding: 5px 15px; }
      hr { border-top: 2px dashed black; }
      .text-center { text-align: center; }
      .text-left { text-align: left; }
      .text-right { text-align: right; }
      .full-width { width: 100%; }
      .inline-block { display: inline-block; }
      .left { float: left; }
      .right { float: right; }
      .text-small { font-size: 0.8em; }
      .text-medium { font-size: 1.2em; }
      .text-large { font-size: 1.6em; }
  ''');
    htmlBuffer.writeln('</style>');
    htmlBuffer.writeln('</head>');
    htmlBuffer.writeln('<body>');
    htmlBuffer.writeln('<div class="receipt">');
    htmlBuffer.writeln('<div class="container">');

    final lines = formattedText.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.trim() == '[C]--------------------------------') {
        // Convert this line to <hr>
        htmlBuffer.writeln('<hr>');
        continue;
      }

      if (line.trim() == '[L]') {
        // Convert this line to <br>
        htmlBuffer.writeln('<br>');
        continue;
      }

      // Handle <img> tag conversion
      final imgMatch = imgPattern.firstMatch(line);
      if (imgMatch != null) {
        final width = imgMatch.group(1);
        final base64 = imgMatch.group(2);
        final imgHtml =
            '<img src="data:image/png;base64,$base64" width="$width"/>';
        htmlBuffer.writeln('<div class="text-center">$imgHtml</div>');
        continue;
      }

      // Handle <qrcode> tag conversion
      final qrMatch = qrPattern.firstMatch(line);
      if (qrMatch != null) {
        final size = qrMatch.group(1);
        final data = qrMatch.group(2);

        final px = Youprint.mmToPx(int.tryParse(size ?? '') ?? 0);
        final base64Data = base64.encode(_convertQRCodeToBytes(
          data ?? '',
          px,
        ));

        final qrHtml =
            '<img src="data:image/png;base64,$base64Data" width="$px"/>';
        htmlBuffer.writeln('<div class="text-center">$qrHtml</div>');
        continue;
      }

      // Handle <barcode> tag conversion
      final barcodeMath = barcodePattern.firstMatch(line);
      if (barcodeMath != null) {
        final data = barcodeMath.group(2);
        final base64Data = base64.encode(_generateBarcodeImage(data ?? ''));

        final barcodeHtml = '<img src="data:image/png;base64,$base64Data"/>';
        htmlBuffer.writeln('<div class="text-center">$barcodeHtml</div>');
        continue;
      }

      final matches = tagPattern.allMatches(line);
      if (matches.length > 1) {
        // Line has multiple tags, split the content
        htmlBuffer.writeln('<p class="full-width inline-block">');
        for (var match in matches) {
          final alignment = match.group(1);
          final className = alignment == 'C'
              ? 'text-center'
              : alignment == 'L'
                  ? 'left'
                  : 'right';
          final start = match.end;
          final nextMatchStart = matches
              .skipWhile((m) => m.start <= start)
              .map((m) => m.start)
              .firstWhere((_) => true, orElse: () => line.length);

          final content = line.substring(start, nextMatchStart).trim();
          htmlBuffer.writeln('<span class="$className">$content</span>');
        }
        htmlBuffer.writeln('</p>');
      } else if (matches.isNotEmpty) {
        // Single tag line
        final match = matches.first;
        final alignment = match.group(1);
        final className = alignment == 'C'
            ? 'text-center'
            : alignment == 'L'
                ? 'text-left'
                : 'text-right';
        final content = line.replaceFirst(tagPattern, '')
          ..replaceAll("size = 'normal'", '').trim();
        htmlBuffer.writeln('<div class="$className">$content</div>');
      }
    }

    htmlBuffer.writeln('</div>');
    htmlBuffer.writeln('</div>');
    htmlBuffer.writeln('</body>');
    htmlBuffer.writeln('</html>');

    return htmlBuffer.toString();
  }

  static Uint8List _generateBarcodeImage(String code) {
    final Image image = Image(width: 400, height: 150);
    fill(image, color: ColorRgb8(255, 255, 255));
    drawBarcode(image, Barcode.code128(), code, font: arial24);
    return encodePng(image).buffer.asUint8List();
  }

  static Uint8List _convertQRCodeToBytes(String data, int size) {
    QRCodeWriter writer = QRCodeWriter();
    BitMatrix matrix;

    try {
      matrix = writer.encode(
        data,
        BarcodeFormat.qrCode,
        size,
        size,
        const EncodeHint(errorCorrectionLevel: ErrorCorrectionLevel.M),
      );
    } catch (e) {
      throw Exception("Unable to encode QR code");
    }

    Image image = Image(width: size, height: size);
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        image.setPixel(
          x,
          y,
          matrix.get(x, y) ? ColorRgb8(0, 0, 0) : ColorRgb8(255, 255, 255),
        );
      }
    }

    return encodePng(image).buffer.asUint8List();
  }
}
