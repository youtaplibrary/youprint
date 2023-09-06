import 'package:youprint/src/textparser/printer_text_parser.dart';
import 'package:youprint/src/textparser/printer_text_parser_column.dart';

class PrinterTextParserLine {
  final PrinterTextParser textParser;
  final String textLine;

  int _nbrColumns = 0;
  int _nbrCharColumn = 0;
  int _nbrCharForgetted = 0;
  int _nbrCharColumnExceeded = 0;
  List<PrinterTextParserColumn?> _columns = [];

  PrinterTextParserLine(
    this.textParser,
    this.textLine,
  ) {
    int nbrCharactersPerLine = getTextParser.getPrinter.getPrinterNbrCharactersPerLine;

    String? regexAlignTags = PrinterTextParser.getRegexAlignTags();

    if (regexAlignTags != null) {
      RegExp pattern = RegExp(regexAlignTags);
      Iterable<RegExpMatch> matcher = pattern.allMatches(textLine);
      List<String> columnsList = [];
      int lastPosition = 0;

      for (RegExpMatch match in matcher) {
        int startPosition = match.start;
        if (startPosition > 0) {
          columnsList.add(textLine.substring(lastPosition, startPosition));
        }
        lastPosition = startPosition;
      }
      columnsList.add(textLine.substring(lastPosition));

      _nbrColumns = columnsList.length;
      _nbrCharColumn = (nbrCharactersPerLine / _nbrColumns).floor();
      _nbrCharForgetted = nbrCharactersPerLine - (_nbrCharColumn * _nbrColumns);
      _nbrCharColumnExceeded = 0;
      _columns = List.filled(_nbrColumns, null);

      int i = 0;
      for (String column in columnsList) {
        _columns[i++] = PrinterTextParserColumn(this, column);
      }
    }
  }

  PrinterTextParser get getTextParser => textParser;

  List<PrinterTextParserColumn?> get getColumns => _columns;

  int get getNbrColumns => _nbrColumns;

  int get getNbrCharColumn => _nbrCharColumn;

  PrinterTextParserLine setNbrCharForgotted(int newValue) {
    _nbrCharForgetted = newValue;
    return this;
  }

  int get getNbrCharForgetted => _nbrCharForgetted;

  void setNbrCharColumnExceeded(int newValue) => _nbrCharColumnExceeded = newValue;

  int get getNbrCharColumnExceeded => _nbrCharColumnExceeded;
}
