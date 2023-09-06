import 'package:youprint/src/connection/device_connection.dart';
import 'package:youprint/src/esc_pos_printer_commands.dart';
import 'package:youprint/src/esc_pos_printer_size.dart';
import 'package:youprint/src/exceptions/esc_pos_encoding_exception.dart';
import 'package:youprint/src/textparser/printer_text_parser.dart';
import 'package:youprint/src/textparser/printer_text_parser_column.dart';
import 'package:youprint/src/textparser/printer_text_parser_element.dart';
import 'package:youprint/src/textparser/printer_text_parser_line.dart';
import 'package:youprint/src/textparser/printer_text_parser_string.dart';

import 'esc_pos_charset_encoding.dart';

class EscPosPrinter extends EscPosPrinterSize {
  final DeviceConnection printerConnection;
  final EscPosCharsetEncoding? charsetEncoding;
  final EscPosPrinterCommands? printer;
  EscPosPrinter(
    this.printerConnection,
    this.charsetEncoding,
    this.printer,
    int printerDpi,
    double printerWidthMM,
    int printerNbrCharactersPerLine,
  ) : super(printerDpi, printerWidthMM, printerNbrCharactersPerLine) {
    _printer = printer ??
        EscPosPrinterCommands(
          printerConnection,
          charsetEncoding,
        );
  }

  Future<EscPosPrinter?> printFormattedText(String text, int dotsFeedPaper) async {
    if (_printer == null || printerNbrCharactersPerLine == 0) {
      return this;
    }
    PrinterTextParser textParser = PrinterTextParser(this);
    List<PrinterTextParserLine?> linesParsed = textParser.setFormattedText(text).parse();
    _printer?.reset();

    for (PrinterTextParserLine? line in linesParsed) {
      if (line != null) {
        List<PrinterTextParserColumn?> columns = line.getColumns;
        PrinterTextParserElement? lastElement;
        for (PrinterTextParserColumn? column in columns) {
          if (column == null) throw const EscPosEncodingException('Failed to parse');
          List<PrinterTextParserElement?> elements = column.getElements;
          for (PrinterTextParserElement? element in elements) {
            if (element != null) {
              if (_printer != null) {
                element.print(_printer!);
                lastElement = element;
              }
            }
          }
        }

        if (lastElement is PrinterTextParserString) {
          _printer?.newLine();
        }
      }
    }
    _printer?.feedPaper(dotsFeedPaper);
    return this;
  }

  EscPosPrinter? printFormattedTextAndCut(
    String text, {
    double? mmFeedPaper,
    int? dotsFeedPaper,
  }) {
    if (mmFeedPaper != null) {
      dotsFeedPaper = mmToPx(mmFeedPaper);
    }

    if (dotsFeedPaper != null) {
      if (_printer == null || printerNbrCharactersPerLine == 0) {
        return this;
      }

      printFormattedText(text, dotsFeedPaper);
      _printer?.cutPaper();
      return this;
    }
    return this;
  }

  EscPosPrinterCommands? _printer;

  EscPosCharsetEncoding? get getEncoding => _printer?.getCharsetEncoding;
}
