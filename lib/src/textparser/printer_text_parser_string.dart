import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:youprint/src/esc_pos_charset_encoding.dart';
import 'package:youprint/src/esc_pos_printer.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/exceptions/esc_pos_encoding_exception.dart';
import 'package:youprint/src/textparser/printer_text_parser_element.dart';

class PrinterTextParserString implements PrinterTextParserElement {
  final EscPosPrinter _printer;
  final String _text;
  final List<int> _textSize;
  final List<int> _textColor;
  final List<int> _textReverseColor;
  final List<int> _textBold;
  final List<int> _textUnderline;
  final List<int> _textDoubleStrike;

  PrinterTextParserString(
    this._printer,
    this._text,
    this._textSize,
    this._textColor,
    this._textReverseColor,
    this._textBold,
    this._textUnderline,
    this._textDoubleStrike,
  );

  @override
  int length() {
    EscPosCharsetEncoding? charsetEncoding = _printer.getEncoding;

    int coef = 1;

    if (listEquals(_textSize, EscPosPrinterCommands.textSizeDoubleWidth) ||
        listEquals(_textSize, EscPosPrinterCommands.textSizeBig)) {
      coef = 2;
    } else if (listEquals(_textSize, EscPosPrinterCommands.textSizeBig2)) {
      coef = 3;
    } else if (listEquals(_textSize, EscPosPrinterCommands.textSizeBig3)) {
      coef = 4;
    } else if (listEquals(_textSize, EscPosPrinterCommands.textSizeBig4)) {
      coef = 5;
    } else if (listEquals(_textSize, EscPosPrinterCommands.textSizeBig5)) {
      coef = 6;
    } else if (listEquals(_textSize, EscPosPrinterCommands.textSizeBig6)) {
      coef = 7;
    }

    if (charsetEncoding != null) {
      try {
        return utf8.encode(_text).length * coef;
      } catch (e) {
        throw EscPosEncodingException('PrinterTextParserString: ${e.toString()}');
      }
    }

    return _text.length * coef;
  }

  @override
  void print(EscPosPrinterCommands printerSocket) {
    printerSocket.printText(
      _text,
      _textSize,
      _textColor,
      _textReverseColor,
      _textBold,
      _textUnderline,
      _textDoubleStrike,
    );
  }
}
