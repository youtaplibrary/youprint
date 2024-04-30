import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fluetooth/fluetooth.dart';
import 'package:flutter/services.dart';
import 'package:youprint/src/receipt/receipt_image.dart';
import 'package:youprint/youprint.dart';

export 'package:fluetooth/fluetooth.dart' show FluetoothDevice;

enum PaperSize { mm58, mm80 }

class Youprint {
  static final Youprint _instance = Youprint();

  static Youprint get instance => _instance;

  static int get printerDpi => 203;

  static double get printerWidthMM => 48.0;

  static int get printerNbrCharactersPerLine => 32;

  static final DeviceConnection _deviceConnection = DeviceConnection();

  static final AsyncEscPosPrinter _escPosPrinter = AsyncEscPosPrinter(
    _deviceConnection,
    printerDpi,
    printerWidthMM,
    printerNbrCharactersPerLine,
  );

  List<FluetoothDevice> _connectedDevices = [];

  /// get connected device
  List<FluetoothDevice> get connectedDevices => _connectedDevices;

  /// return bluetooth device list, handler Android and iOS in [BlueScanner]
  Future<List<FluetoothDevice>> scan() {
    return Fluetooth().getAvailableDevices();
  }

  Future<List<FluetoothDevice>> getConnectedDevices() {
    return Fluetooth().getConnectedDevice();
  }

  /// When connecting, reassign value [selectedDevice] from parameter [device]
  /// and if connection time more than [timeout]
  /// will return [ConnectionStatus.timeout]
  /// When connection success, will return [ConnectionStatus.connected]
  Future<ConnectionStatus> connect(
    FluetoothDevice device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await Fluetooth().connect(device.id).timeout(timeout);
      await Fluetooth().getConnectedDevice().then((devices) {
        _connectedDevices = devices;
      });
      return Future<ConnectionStatus>.value(ConnectionStatus.connected);
    } on Exception catch (error) {
      log('$runtimeType - Error $error');
      return Future<ConnectionStatus>.value(ConnectionStatus.timeout);
    }
  }

  /// To stop communication between bluetooth device and application
  Future<ConnectionStatus> disconnect(String uuid) async {
    await Fluetooth().disconnectDevice(uuid);
    await Fluetooth().getConnectedDevice().then((devices) {
      _connectedDevices = devices;
    });
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

      await _printProcess(bytes, uuid);
    }
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

    await _printProcess(bytes, uuid);
  }

  /// Reusable method for print text, image or QR based value [byteBuffer]
  /// Handler Android or iOS will use method writeBytes from ByteBuffer
  /// But in iOS more complex handler using service and characteristic
  Future<void> _printProcess(List<int> byteBuffer, String uuid) async {
    try {
      if (!await Fluetooth().isConnected(uuid)) {
        return;
      }
      await Fluetooth().sendBytes(byteBuffer, uuid);
      _escPosPrinter.clearTextsToPrint();
      _escPosPrinter.printerConnection.clearData();
    } on Exception catch (error) {
      _escPosPrinter.clearTextsToPrint();
      _escPosPrinter.printerConnection.clearData();
      log('$runtimeType - Error $error');
      return;
    }
  }
}
