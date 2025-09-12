import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:fluetooth_plus/fluetooth.dart';
import 'package:flutter/services.dart';
import 'package:youprint/src/receipt/receipt_image.dart';
import 'package:youprint/youprint.dart';

export 'package:fluetooth_plus/fluetooth.dart' show FluetoothDevice;

enum PaperSize { mm58, mm80 }

class Youprint {
  Youprint._internal() {
    _initializePrinter();
  }

  static final Youprint _instance = Youprint._internal();

  static Youprint get instance => _instance;

  static const int printerDpi = 203;

  PaperSize _paperSize = PaperSize.mm58;

  PaperSize get paperSize => _paperSize;

  final DeviceConnection _deviceConnection = DeviceConnection();

  late AsyncEscPosPrinter _escPosPrinter;

  List<FluetoothDevice> _connectedDevices = [];

  List<FluetoothDevice> get connectedDevices => _connectedDevices;

  void setPaperSize(PaperSize paperSize) {
    _paperSize = paperSize;
    _initializePrinter();
  }

  void _initializePrinter() {
    _escPosPrinter = AsyncEscPosPrinter(
      _deviceConnection,
      printerDpi,
      printerWidth,
      printerNbrCharactersPerLine,
    );
  }

  double get printerWidth {
    switch (_paperSize) {
      case PaperSize.mm58:
        return 48.0;
      case PaperSize.mm80:
        return 72.0;
    }
  }

  int get printerNbrCharactersPerLine {
    switch (_paperSize) {
      case PaperSize.mm58:
        return 32;
      case PaperSize.mm80:
        return 48;
    }
  }

  Future<List<FluetoothDevice>> scan() {
    return Fluetooth().getAvailableDevices();
  }

  Future<List<FluetoothDevice>> getConnectedDevices() {
    return Fluetooth().getConnectedDevice();
  }

  Future<ConnectionStatus> connect(
    FluetoothDevice device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await Fluetooth().connect(device.id).timeout(timeout);
      _connectedDevices = await Fluetooth().getConnectedDevice();
      return ConnectionStatus.connected;
    } on Exception catch (error) {
      log('$runtimeType - Error $error');
      return ConnectionStatus.timeout;
    }
  }

  Future<ConnectionStatus> disconnect(String uuid) async {
    await Fluetooth().disconnectDevice(uuid);
    _connectedDevices = await Fluetooth().getConnectedDevice();
    return ConnectionStatus.disconnect;
  }

  Future<void> printReceiptText(
    ReceiptSectionText receiptSectionText,
    String uuid, {
    int feedCount = 0,
    bool useCut = false,
    bool useRaster = false,
    bool openDrawer = false,
    double duration = 0,
    double? textScaleFactor,
    BatchPrintOptions? batchPrintOptions,
  }) async {
    log('\n${receiptSectionText.getContent()}');
    final int contentLength = receiptSectionText.contentLength;

    final BatchPrintOptions batchOptions =
        batchPrintOptions ?? BatchPrintOptions.full;

    final Iterable<List<Object>> startEndIter =
        batchOptions.getStartEnd(contentLength);

    for (final List<Object> startEnd in startEndIter) {
      final ReceiptSectionText section = receiptSectionText.getSection(
        startEnd[0] as int,
        startEnd[1] as int,
      );

      final bool isEndOfBatch = startEnd[2] as bool;
      _escPosPrinter.addTextToPrint(section.getContent());
      final bytes = await _escPosPrinter.parsedToBytes(
        feedCount: isEndOfBatch ? feedCount : batchOptions.feedCount,
        useCut: isEndOfBatch ? useCut : batchOptions.useCut,
        openDrawer: openDrawer,
      );

      _escPosPrinter.clearTextsToPrint();
      _escPosPrinter.printerConnection.clearData();

      await _printProcess(bytes, uuid);
    }
  }

  int pxToMM(int pixel) {
    return (pixel * EscPosPrinterSize.inchToMM / printerDpi).round();
  }

  int mmToPx(int mm) {
    return (mm * printerDpi / EscPosPrinterSize.inchToMM).round();
  }

  Future<void> printReceiptImage(
    List<int> bytes,
    String uuid, {
    int width = 120,
    int feedCount = 0,
    bool useCut = false,
    bool openDrawer = false,
  }) async {
    final base64Image = base64.encode(Uint8List.fromList(bytes));
    final ReceiptImage image = ReceiptImage(base64Image);
    _escPosPrinter.addTextToPrint(image.content);
    final bytesResult = await _escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: useCut,
      openDrawer: openDrawer,
    );

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();
    await _printProcess(bytesResult, uuid);
  }

  String base64toHexadecimal(String data, int size) {
    final hexadecimal = PrinterTextParserImg.base64ImageToHexadecimalString(
      _escPosPrinter,
      data,
      false,
      size,
    );
    return hexadecimal;
  }

  Future<void> printQR(
    String data,
    String uuid, {
    int size = 120,
    int feedCount = 0,
    bool useCut = false,
    bool openDrawer = false,
  }) async {
    final ReceiptQR qr = ReceiptQR(data, size: size.toInt());
    _escPosPrinter.addTextToPrint(qr.content);
    final bytes = await _escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: useCut,
      openDrawer: openDrawer,
    );

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();

    await _printProcess(bytes, uuid);
  }

  Future<void> _printProcess(List<int> byteBuffer, String uuid) async {
    try {
      if (!await Fluetooth().isConnected(uuid)) {
        return;
      }
      await Fluetooth().sendBytes(byteBuffer, uuid);
    } on Exception catch (error) {
      log('$runtimeType PrintProcess - Error $error');
    }

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();
  }

  String convertToHtml(String formattedText) {
    try {
      return HtmlConverter.convertToHtmlReceipt(formattedText);
    } catch (_) {
      return '';
    }
  }
}
