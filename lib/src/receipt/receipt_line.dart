import 'package:youprint/src/youprint.dart';

class ReceiptLine {
  ReceiptLine({this.count = 1, this.useDashed = false});

  /// [count] to decide how much line without are used, empty or dashed line
  final int count;

  /// [useDashed] to use empty or dashed line style. Default value is false
  final bool useDashed;

  /// Get the tag of html, empty line use <br> and dashed line use <hr>
  /// For loop will generate how much line will printed
  String get content {
    String concatString = '';
    for (int i = 0; i < count; i++) {
      concatString += useDashed ? _dashedLine : _emptyLine;
    }
    return concatString;
  }

  String get _generateDashed =>
      List.generate(Youprint.printerNbrCharactersPerLine, (_) => '-').join();

  /// Tag <hr>
  String get _dashedLine => '[C]$_generateDashed\n';

  /// <br>
  String get _emptyLine => '[L]\n';
}
