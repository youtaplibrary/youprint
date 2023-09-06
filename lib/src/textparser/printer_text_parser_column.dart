import 'dart:collection';

import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/textparser/printer_text_parser.dart';
import 'package:youprint/src/textparser/printer_text_parser_element.dart';
import 'package:youprint/src/textparser/printer_text_parser_line.dart';
import 'package:youprint/src/textparser/printer_text_parser_string.dart';
import 'package:youprint/src/textparser/printer_text_parser_tag.dart';

class PrinterTextParserColumn {
  PrinterTextParserColumn(this._textParserLine, this._textColumn) {
    String textColumn = _textColumn;
    _line = _textParserLine;
    PrinterTextParser textParser = _line.textParser;
    List<int> textUnderlineStartColumn = textParser.getLastTextUnderline;
    List<int> textDoubleStrikeStartColumn = textParser.getLastTextDoubleStrike;
    List<int> textColorStartColumn = textParser.getLastTextColor;
    List<int> textReverseColorStartColumn = textParser.getLastTextReverseColor;

    String textAlign = PrinterTextParser.tagsAlignLeft;

    // Check the column alignment
    if (textColumn.length > 2) {
      switch (textColumn.substring(0, 3).toUpperCase()) {
        case "[${PrinterTextParser.tagsAlignLeft}]":
        case "[${PrinterTextParser.tagsAlignCenter}]":
        case "[${PrinterTextParser.tagsAlignRight}]":
          textAlign = textColumn.substring(1, 2).toUpperCase();
          textColumn = textColumn.substring(3);
      }
    }

    String trimmedTextColumn = textColumn.trim();
    bool isImgOrBarcodeLine = false;

    if (_textParserLine.getNbrColumns == 1 && trimmedTextColumn.indexOf('<') == 0) {
      // Image or Barcode Lines
      int openTagIndex = trimmedTextColumn.indexOf('<'),
          openTagEndIndex = trimmedTextColumn.indexOf('>', openTagIndex + 1) + 1;

      if (openTagIndex < openTagEndIndex) {
        PrinterTextParserTag textParserTag =
            PrinterTextParserTag(trimmedTextColumn.substring(openTagIndex, openTagEndIndex));

        switch (textParserTag.getTagName) {
          case PrinterTextParser.tagsImage:
          case PrinterTextParser.tagsBarcode:
          case PrinterTextParser.tagsQRCode:
            String closeTag = '</${textParserTag.getTagName}>';
            int closeTagPosition = trimmedTextColumn.length - closeTag.length;

            if (trimmedTextColumn.substring(closeTagPosition) == closeTag) {
              switch (textParserTag.getTagName) {
                case PrinterTextParser.tagsImage:
                  appendImage(
                    textAlign,
                    textParserTag.attributes,
                    trimmedTextColumn.substring(
                      openTagEndIndex,
                      closeTagPosition,
                    ),
                  );
                  break;
                case PrinterTextParser.tagsBarcode:
                  appendBarcode(
                    textAlign,
                    textParserTag.attributes,
                    trimmedTextColumn.substring(openTagEndIndex, closeTagPosition),
                  );
                  break;
                case PrinterTextParser.tagsQRCode:
                  appendQRCode(
                    textAlign,
                    textParserTag.attributes,
                    trimmedTextColumn.substring(openTagEndIndex, closeTagPosition),
                  );
                  break;
              }
              isImgOrBarcodeLine = true;
            }
        }
      }
    }

    if (!isImgOrBarcodeLine) {
      // If the tag is for format text
      int offset = 0;
      while (true) {
        int openTagIndex = textColumn.indexOf('<', offset), closeTagIndex = -1;
        if (openTagIndex != -1) {
          closeTagIndex = textColumn.indexOf('>', openTagIndex);
        } else {
          openTagIndex = textColumn.length;
        }
        appendStringText(textColumn.substring(offset, openTagIndex));
        if (closeTagIndex == -1) {
          break;
        }
        closeTagIndex++;
        PrinterTextParserTag textParserTag =
            PrinterTextParserTag(textColumn.substring(openTagIndex, closeTagIndex));
        if (PrinterTextParser.isTagTextFormat(textParserTag.getTagName)) {
          if (textParserTag.isCloseTag) {
            switch (textParserTag.getTagName) {
              case PrinterTextParser.tagsFormatTextBold:
                textParser.dropLastTextBold();
                break;
              case PrinterTextParser.tagsFormatTextUnderline:
                textParser.dropLastTextUnderline();
                textParser.dropLastTextDoubleStrike();
                break;
              case PrinterTextParser.tagsFormatTextFont:
                textParser.dropLastTextSize();
                textParser.dropLastTextColor();
                textParser.dropLastTextReverseColor();
                break;
            }
          } else {
            switch (textParserTag.getTagName) {
              case PrinterTextParser.tagsFormatTextBold:
                textParser.addTextBold(EscPosPrinterCommands.textWeightBold);
                break;
              case PrinterTextParser.tagsFormatTextUnderline:
                if (textParserTag.hasAttribute(PrinterTextParser.attrFormatTextUnderlineType)) {
                  switch (
                      textParserTag.getAttribute(PrinterTextParser.attrFormatTextUnderlineType)) {
                    case PrinterTextParser.attrFormatTextUnderlineTypeNormal:
                      textParser.addTextUnderline(EscPosPrinterCommands.textUnderLineLarge);
                      textParser.addTextDoubleStrike(textParser.getLastTextDoubleStrike);
                      break;
                    case PrinterTextParser.attrFormatTextUnderlineTypeDouble:
                      textParser.addTextUnderline(textParser.getLastTextUnderline);
                      textParser.addTextDoubleStrike(EscPosPrinterCommands.textDoubleStrikeOn);
                      break;
                  }
                } else {
                  textParser.addTextUnderline(EscPosPrinterCommands.textUnderLineLarge);
                  textParser.addTextDoubleStrike(textParser.getLastTextDoubleStrike);
                }
                break;
              case PrinterTextParser.tagsFormatTextFont:
                if (textParserTag.hasAttribute(PrinterTextParser.attrFormatTextFontSize)) {
                  switch (textParserTag.getAttribute(PrinterTextParser.attrFormatTextFontSize)) {
                    case PrinterTextParser.attrFormatTextFontSizeNormal:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeNormal);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeTall:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeDoubleHeight);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeWide:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeDoubleWidth);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig2:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig2);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig3:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig3);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig4:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig4);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig5:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig5);
                      break;
                    case PrinterTextParser.attrFormatTextFontSizeBig6:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeBig6);
                      break;
                    default:
                      textParser.addTextSize(EscPosPrinterCommands.textSizeNormal);
                  }
                } else {
                  textParser.addTextSize(textParser.getLastTextSize);
                }

                if (textParserTag.hasAttribute(PrinterTextParser.attrFormatTextFontColor)) {
                  switch (textParserTag.getAttribute(PrinterTextParser.attrFormatTextFontColor)) {
                    case PrinterTextParser.attrFormatTextFontColorBlack:
                      textParser.addTextColor(EscPosPrinterCommands.textColorBlack);
                      textParser.addTextReverseColor(EscPosPrinterCommands.textColorReverseOff);
                      break;
                    case PrinterTextParser.attrFormatTextFontColorBgBlack:
                      textParser.addTextColor(EscPosPrinterCommands.textColorBlack);
                      textParser.addTextReverseColor(EscPosPrinterCommands.textColorReverseOn);
                      break;
                    case PrinterTextParser.attrFormatTextFontColorRed:
                      textParser.addTextColor(EscPosPrinterCommands.textColorRed);
                      textParser.addTextReverseColor(EscPosPrinterCommands.textColorReverseOff);
                      break;
                    case PrinterTextParser.attrFormatTextFontColorBgRed:
                      textParser.addTextColor(EscPosPrinterCommands.textColorRed);
                      textParser.addTextReverseColor(EscPosPrinterCommands.textColorReverseOn);
                      break;
                    default:
                      textParser.addTextColor(EscPosPrinterCommands.textColorBlack);
                      textParser.addTextReverseColor(EscPosPrinterCommands.textColorReverseOff);
                      break;
                  }
                } else {
                  textParser.addTextColor(textParser.getLastTextColor);
                  textParser.addTextReverseColor(textParser.getLastTextReverseColor);
                }
                break;
            }
          }
          offset = closeTagIndex;
        } else {
          appendStringText('<');
          offset = openTagIndex + 1;
        }
      }

      // Define the number of spaces required for the different alignments

      int nbrCharColumn = _textParserLine.getNbrCharColumn,
          nbrCharForgetted = _textParserLine.getNbrCharForgetted,
          nbrCharColumnExceeded = _textParserLine.getNbrCharColumnExceeded,
          nbrCharTextWithoutTag = 0,
          leftSpace = 0,
          rightSpace = 0;

      for (PrinterTextParserElement? textParserElement in _elements) {
        if (textParserElement != null) {
          nbrCharTextWithoutTag += textParserElement.length();
        }
      }

      switch (textAlign) {
        case PrinterTextParser.tagsAlignLeft:
          rightSpace = nbrCharColumn - nbrCharTextWithoutTag;
          break;
        case PrinterTextParser.tagsAlignCenter:
          leftSpace = ((nbrCharColumn - nbrCharTextWithoutTag) / 2).floor();
          rightSpace = nbrCharColumn - nbrCharTextWithoutTag - leftSpace;
          break;
        case PrinterTextParser.tagsAlignRight:
          leftSpace = nbrCharColumn - nbrCharTextWithoutTag;
          break;
      }

      if (nbrCharForgetted > 0) {
        nbrCharForgetted -= 1;
        rightSpace++;
      }

      if (nbrCharColumnExceeded < 0) {
        leftSpace += nbrCharColumnExceeded;
        nbrCharColumnExceeded = 0;
        if (leftSpace < 1) {
          rightSpace += leftSpace - 1;
          leftSpace = 1;
        }
      }

      if (leftSpace < 0) {
        nbrCharColumnExceeded += leftSpace;
        leftSpace = 0;
      }
      if (rightSpace < 0) {
        nbrCharColumnExceeded += rightSpace;
        rightSpace = 0;
      }

      if (leftSpace > 0) {
        prependString(
          PrinterTextParserColumn.generateSpace(leftSpace),
          EscPosPrinterCommands.textSizeNormal,
          textColorStartColumn,
          textReverseColorStartColumn,
          EscPosPrinterCommands.textWeightNormal,
          textUnderlineStartColumn,
          textDoubleStrikeStartColumn,
        );
      }

      if (rightSpace > 0) {
        appendString(
          PrinterTextParserColumn.generateSpace(rightSpace),
          EscPosPrinterCommands.textSizeNormal,
          textParser.getLastTextColor,
          textParser.getLastTextReverseColor,
          EscPosPrinterCommands.textWeightNormal,
          textParser.getLastTextUnderline,
          textParser.getLastTextDoubleStrike,
        );
      }

      // nbrCharForgetted and nbrCharColumnExceeded is use to define number of spaces for the next columns

      _textParserLine
          .setNbrCharForgotted(nbrCharForgetted)
          .setNbrCharColumnExceeded(nbrCharColumnExceeded);
    }
  }

  final PrinterTextParserLine _textParserLine;
  final String _textColumn;

  late PrinterTextParserLine _line;
  List<PrinterTextParserElement?> _elements = [];

  PrinterTextParserColumn prependString(
    String text,
    List<int> textSize,
    List<int> textColor,
    List<int> textReverseColor,
    List<int> textBold,
    List<int> textUnderline,
    List<int> textDoubleStrike,
  ) {
    return prependElement(
      PrinterTextParserString(
        _line.getTextParser.getPrinter,
        text,
        textSize,
        textColor,
        textReverseColor,
        textBold,
        textUnderline,
        textDoubleStrike,
      ),
    );
  }

  void appendStringText(String text) {
    final textParser = _line.textParser;
    appendString(
      text,
      textParser.getLastTextSize,
      textParser.getLastTextColor,
      textParser.getLastTextReverseColor,
      textParser.getLastTextBold,
      textParser.getLastTextUnderline,
      textParser.getLastTextDoubleStrike,
    );
  }

  void appendString(
    String text,
    List<int> textSize,
    List<int> textColor,
    List<int> textReverseColor,
    List<int> textBold,
    List<int> textUnderline,
    List<int> textDoubleStrike,
  ) {
    appendElement(PrinterTextParserString(
      _line.getTextParser.getPrinter,
      text,
      textSize,
      textColor,
      textReverseColor,
      textBold,
      textUnderline,
      textDoubleStrike,
    ));
  }

  void appendImage(
    String textAlign,
    HashMap<String, String> imageAttributes,
    String hexString,
  ) {
    //TODO: appendImage in PrinterTextParserColumn
  }

  void appendBarcode(
    String textAlign,
    HashMap<String, String> barcodeAttributes,
    String code,
  ) {
    //TODO: appendBarcode in PrinterTextParserColumn
  }

  void appendQRCode(
    String textAlign,
    HashMap<String, String> qrCodeAttributes,
    String data,
  ) {
    //TODO: appendQRCode in PrinterTextParserColumn
  }

  PrinterTextParserColumn prependElement(PrinterTextParserElement element) {
    List<PrinterTextParserElement?> elementsTmp = List<PrinterTextParserElement?>.filled(
      _elements.length + 1,
      null,
    );
    elementsTmp[0] = element;
    List.copyRange(elementsTmp, 1, _elements, 0, _elements.length);
    _elements = elementsTmp;
    return this;
  }

  void appendElement(PrinterTextParserElement element) {
    List<PrinterTextParserElement?> elementsTmp = List<PrinterTextParserElement?>.filled(
      _elements.length + 1,
      null,
    );
    List.copyRange(elementsTmp, 0, _elements, 0, _elements.length);
    elementsTmp[_elements.length] = element;
    _elements = elementsTmp;
  }

  List<PrinterTextParserElement?> get getElements => _elements;

  static String generateSpace(int nbrSpace) {
    StringBuffer str = StringBuffer();
    for (int i = 0; i < nbrSpace; i++) {
      str.write(" ");
    }
    return str.toString();
  }
}
