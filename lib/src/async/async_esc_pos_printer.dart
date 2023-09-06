import 'package:youprint/src/connection/device_connection.dart';
import 'package:youprint/src/esc_pos_printer_size.dart';

class AsyncEscPosPrinter extends EscPosPrinterSize {
  final DeviceConnection printerConnection;

  AsyncEscPosPrinter(
    this.printerConnection,
    int printerDpi,
    double printerWidthMM,
    int printerNbrCharactersPerLine,
  ) : super(printerDpi, printerWidthMM, printerNbrCharactersPerLine);

  List<String?> textsToPrint = [];

  AsyncEscPosPrinter setTextsToPrint(List<String?> textsToPrint) {
    this.textsToPrint = textsToPrint;
    return this;
  }

  AsyncEscPosPrinter? addTextToPrint(String? textToPrint) {
    if (textToPrint != null) {
      List<String?> tmp = List.filled(textToPrint.length + 1, null);
      List.copyRange(tmp, 0, textsToPrint, 0, textsToPrint.length);
      tmp[textsToPrint.length] = textToPrint;
      textsToPrint = tmp;
      return this;
    }
    return this;
  }
}
