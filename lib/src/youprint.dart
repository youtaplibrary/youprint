import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:youprint/src/extensions/bluetooth_extension.dart';
import 'package:youprint/src/receipt/receipt_image.dart';
import 'package:youprint/youprint.dart';

enum PaperSize { mm58, mm80 }

class Youprint {
  static final Youprint _instance = Youprint();

  static Youprint get instance => _instance;

  static int get printerDpi => 203;

  static double get printerWidthMM => 48.0;

  static int get printerNbrCharactersPerLine => 32;

  static String get printerServiceId => '18f0';

  static final DeviceConnection _deviceConnection = DeviceConnection();

  static final AsyncEscPosPrinter _escPosPrinter = AsyncEscPosPrinter(
    _deviceConnection,
    printerDpi,
    printerWidthMM,
    printerNbrCharactersPerLine,
  );

  /// get connected device
  List<BluetoothDevice> get connectedDevices =>
      FlutterBluePlus.connectedDevices;

  /// return bluetooth device list, handler Android and iOS in [BlueScanner]
  Future<List<BluetoothDevice>> scan() async {
    await FlutterBluePlus.startScan(
      withServices: [Guid(printerServiceId)],
      timeout: const Duration(seconds: 5),
    );

    await FlutterBluePlus.isScanning
        .where((isScanning) => isScanning == false)
        .first;

    final result = FlutterBluePlus.lastScanResults
        .map((element) => element.device)
        .where((element) => element.platformName.isNotEmpty)
        .toList();

    return result;
  }

  /// When connecting, [discoverServices] and [requestMtu]
  Future<ConnectionStatus> connect(
    BluetoothDevice device, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (device.isConnected) return ConnectionStatus.connected;
    await device.connect(autoConnect: true, mtu: null, timeout: timeout);
    await device.connectionState
        .where((val) => val == BluetoothConnectionState.connected)
        .first;
    if (Platform.isAndroid) await device.requestMtu(512);
    await device.discoverServices();
    return ConnectionStatus.connected;
  }

  /// To stop communication between bluetooth device and application
  Future<ConnectionStatus> disconnect(BluetoothDevice device) async {
    await device.disconnect();
    await device.connectionState
        .where((val) => val == BluetoothConnectionState.disconnected)
        .first;
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
    PaperSize paperSize = PaperSize.mm58,
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

  Future<Uint8List> getParsedBytes(
    ReceiptSectionText receiptSectionText, {
    int feedCount = 0,
    bool useCut = false,
    bool openDrawer = false,
    double duration = 0,
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    log('\n${receiptSectionText.getContent()}');
    _escPosPrinter.addTextToPrint(receiptSectionText.getContent());
    final bytes = await _escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: useCut,
      openDrawer: openDrawer,
    );

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();

    return bytes;
  }

  static int pxToMM(int pixel) {
    return (pixel * EscPosPrinterSize.inchToMM / printerDpi).round();
  }

  /// This method only for print image with parameter [bytes] in List<int>
  /// define [width] to custom width of image, default value is 120
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
  Future<void> printReceiptImage(
    List<int> bytes,
    String uuid, {
    int width = 120,
    int feedCount = 0,
    bool useCut = false,
    bool openDrawer = false,
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    final base64Image = base64.encode(Uint8List.fromList(bytes));
    final ReceiptImage image = ReceiptImage(base64Image);
    _escPosPrinter.addTextToPrint(image.content);
    final bytesResult = await _escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: true,
      openDrawer: openDrawer,
    );

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();
    await _printProcess(bytesResult, uuid);
  }

  static String base64toHexadecimal(String data, int size) {
    final hexadecimal = PrinterTextParserImg.base64ImageToHexadecimalString(
      _escPosPrinter,
      data,
      false,
      size,
    );
    return hexadecimal;
  }

  /// This method only for print QR, only pass value on parameter [data]
  /// define [size] to size of QR, default value is 120
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
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

  /// Reusable method for print text, image or QR based value [byteBuffer]
  /// Handler Android or iOS will use method writeBytes from ByteBuffer
  /// But in iOS more complex handler using service and characteristic
  Future<void> _printProcess(List<int> byteBuffer, String uuid) async {
    try {
      final devices = FlutterBluePlus.connectedDevices
          .where((device) => device.remoteId.str == uuid)
          .toList();

      if (devices.isEmpty) {
        _escPosPrinter.clearTextsToPrint();
        _escPosPrinter.printerConnection.clearData();

        log('$runtimeType - device not found');
        return;
      }

      final device = devices.first;

      final services = device.servicesList
          .where((element) => element.serviceUuid == Guid(printerServiceId));

      if (services.isEmpty) {
        _escPosPrinter.clearTextsToPrint();
        _escPosPrinter.printerConnection.clearData();

        log('$runtimeType - service not found');
        return;
      }

      final service = services.first;

      final characteristics =
          service.characteristics.where((c) => c.properties.write);

      if (characteristics.isEmpty) {
        _escPosPrinter.clearTextsToPrint();
        _escPosPrinter.printerConnection.clearData();

        log('$runtimeType - characteristic not found');
        return;
      }

      final c = characteristics.first;

      if (c.properties.write) {
        if (device.isConnected) {
          await c.splitWrite(byteBuffer);
        }
      }
    } on Exception catch (error) {
      log('$runtimeType PrintProcess - Error $error');
    }

    _escPosPrinter.clearTextsToPrint();
    _escPosPrinter.printerConnection.clearData();
  }
}
