import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/textparser/printer_text_parser_line.dart';

class PrinterTextParser {
  static const String tagsAlignLeft = 'L';
  static const String tagsAlignCenter = 'C';
  static const String tagsAlignRight = 'R';
  static const List<String> tagsAlign = <String>[
    PrinterTextParser.tagsAlignLeft,
    PrinterTextParser.tagsAlignCenter,
    PrinterTextParser.tagsAlignRight,
  ];
  static const String tagsImage = 'img';
  static const String tagsBarcode = 'barcode';
  static const String tagsQRCode = 'qrcode';

  static const String attrBarcodeWidth = 'width';
  static const String attrBarcodeHeight = 'height';
  static const String attrBarcodeType = 'type';
  static const String attrBarcodeTypeEAN8 = 'ean8';
  static const String attrBarcodeTypeEAN13 = 'ean13';
  static const String attrBarcodeTypeUPCA = 'upca';
  static const String attrBarcodeTypeUPCE = 'upce';
  static const String attrBarcodeType128 = '128';
  static const String attrBarcodeTextPosition = 'text';
  static const String attrBarcodeTextPositionNone = 'none';
  static const String attrBarcodeTextPositionAbove = 'above';
  static const String attrBarcodeTextPositionBelow = 'below';

  static const String tagsFormatTextFont = 'font';
  static const String tagsFormatTextBold = 'b';
  static const String tagsFormatTextUnderline = 'u';
  static const List<String> tagsFormatText = <String>[
    PrinterTextParser.tagsFormatTextFont,
    PrinterTextParser.tagsFormatTextBold,
    PrinterTextParser.tagsFormatTextUnderline,
  ];

  static const String attrFormatTextUnderlineType = 'tyoe';
  static const String attrFormatTextUnderlineTypeNormal = 'normal';
  static const String attrFormatTextUnderlineTypeDouble = 'double';

  static const String attrFormatTextFontSize = 'size';
  static const String attrFormatTextFontSizeBig = 'big';
  static const String attrFormatTextFontSizeBig2 = 'big-2';
  static const String attrFormatTextFontSizeBig3 = 'big-3';
  static const String attrFormatTextFontSizeBig4 = 'big-4';
  static const String attrFormatTextFontSizeBig5 = 'big-5';
  static const String attrFormatTextFontSizeBig6 = 'big-6';
  static const String attrFormatTextFontSizeTall = 'tall';
  static const String attrFormatTextFontSizeWide = 'wide';
  static const String attrFormatTextFontSizeNormal = 'normal';

  static const String attrFormatTextFontColor = 'color';
  static const String attrFormatTextFontColorBlack = 'black';
  static const String attrFormatTextFontColorBgBlack = 'bg-black';
  static const String attrFormatTextFontColorRed = 'red';
  static const String attrFormatTextFontColorBgRed = 'bg-red';

  static const String attrQRCodeSize = 'size';
  static const String attrImageSize = 'size';

  static String? _regexAlignTags;

  static String? getRegexAlignTags() {
    if (PrinterTextParser._regexAlignTags == null) {
      StringBuffer regexAlignTags = StringBuffer();
      for (int i = 0; i < PrinterTextParser.tagsAlign.length; i++) {
        regexAlignTags
          ..write("|\\[")
          ..write(PrinterTextParser.tagsAlign[i])
          ..write("\\]");
      }
      PrinterTextParser._regexAlignTags = regexAlignTags.toString().substring(1);
      return PrinterTextParser._regexAlignTags;
    }
    return PrinterTextParser._regexAlignTags;
  }

  static bool isTagTextFormat(String tagName) {
    if (tagName.startsWith('/')) {
      tagName = tagName.substring(1);
    }

    for (String tag in PrinterTextParser.tagsFormatText) {
      if (tag == tagName) {
        return true;
      }
    }
    return false;
  }

  static List<List<int>> arrayByteDropLast(List<List<int>> arr) {
    if (arr.isEmpty) {
      return arr;
    }

    List<List<int>> newArr = List.filled(arr.length - 1, []);
    List.copyRange(newArr, 0, arr, 0, newArr.length);
    return newArr;
  }

  static List<List<int>> arrayBytePush(List<List<int>> arr, List<int> add) {
    List<List<int>> newArr = List.filled(arr.length + 1, []);
    List.copyRange(newArr, 0, arr, 0, arr.length);
    newArr[arr.length] = add;
    return newArr;
  }

  final EscPosPrinter _printer;
  List<List<int>> textSize = [EscPosPrinterCommands.textSizeNormal];
  List<List<int>> textColor = [EscPosPrinterCommands.textColorBlack];
  List<List<int>> textReverseColor = [EscPosPrinterCommands.textColorReverseOff];
  List<List<int>> textBold = [EscPosPrinterCommands.textWeightNormal];
  List<List<int>> textUnderline = [EscPosPrinterCommands.textUnderlineOff];
  List<List<int>> textDoubleStrike = [EscPosPrinterCommands.textDoubleStrikeOff];
  String _text = '';

  PrinterTextParser(this._printer);

  EscPosPrinter get getPrinter => _printer;

  PrinterTextParser setFormattedText(String text) {
    _text = text;
    return this;
  }

  List<int> get getLastTextSize => textSize[textSize.length - 1];

  void addTextSize(List<int> newTextSize) {
    textSize = PrinterTextParser.arrayBytePush(textSize, newTextSize);
  }

  void dropLastTextSize() {
    if (textSize.length > 1) {
      textSize = PrinterTextParser.arrayByteDropLast(textSize);
    }
  }

  List<int> get getLastTextColor => textColor[textColor.length - 1];

  void addTextColor(List<int> newTextColor) {
    textColor = PrinterTextParser.arrayBytePush(textColor, newTextColor);
  }

  void dropLastTextColor() {
    if (textColor.length > 1) {
      textColor = PrinterTextParser.arrayByteDropLast(textColor);
    }
  }

  List<int> get getLastTextReverseColor => textReverseColor[textReverseColor.length - 1];

  void addTextReverseColor(List<int> newTextReverseColor) {
    textReverseColor = PrinterTextParser.arrayBytePush(textReverseColor, newTextReverseColor);
  }

  void dropLastTextReverseColor() {
    if (textReverseColor.length > 1) {
      textReverseColor = PrinterTextParser.arrayByteDropLast(textReverseColor);
    }
  }

  List<int> get getLastTextBold => textBold[textBold.length - 1];

  void addTextBold(List<int> newTextBold) {
    textBold = PrinterTextParser.arrayBytePush(textBold, newTextBold);
  }

  void dropLastTextBold() {
    if (textBold.length > 1) {
      textBold = PrinterTextParser.arrayByteDropLast(textBold);
    }
  }

  List<int> get getLastTextUnderline => textUnderline[textUnderline.length - 1];

  void addTextUnderline(List<int> newTextUnderline) {
    textUnderline = PrinterTextParser.arrayBytePush(textUnderline, newTextUnderline);
  }

  void dropLastTextUnderline() {
    if (textUnderline.length > 1) {
      textUnderline = PrinterTextParser.arrayByteDropLast(textUnderline);
    }
  }

  List<int> get getLastTextDoubleStrike => textDoubleStrike[textDoubleStrike.length - 1];

  void addTextDoubleStrike(List<int> newTextDoubleStrike) {
    textDoubleStrike = PrinterTextParser.arrayBytePush(textDoubleStrike, newTextDoubleStrike);
  }

  void dropLastTextDoubleStrike() {
    if (textDoubleStrike.length > 1) {
      textDoubleStrike = PrinterTextParser.arrayByteDropLast(textDoubleStrike);
    }
  }

  List<PrinterTextParserLine?> parse() {
    List<String> stringLines = _text.split('\n');
    List<PrinterTextParserLine?> lines = List.filled(stringLines.length, null);
    int i = 0;
    for (String line in stringLines) {
      lines[i++] = PrinterTextParserLine(this, line);
    }
    return lines;
  }
}
