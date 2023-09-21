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

  static final PrinterFeatures _printerFeatures = PrinterFeatures();

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

  /// Register printer device name with its features.
  /// Example:
  /// ```dart
  /// BluePrintPos.addPrinterFeatures(<String, Set<PrinterFeature>>{
  ///   // The name of the device is from [FluetoothDevice.name]
  ///   const PrinterFeatureRule.allowFor('PRJ-80AT-BT'): {
  //      PrinterFeature.paperFullCut,
  //    },
  ///   // Allow all printers for this feature
  ///   PrinterFeatureRule.allowAll: {PrinterFeature.paperFullCut},
  /// });
  /// ```
  ///
  /// If [Youprint.selectedDevice] name does not match, for example, for
  /// [PrinterFeature.paperFullCut], then when printing using `useCut`
  /// it will not produce any ESC command for paper full cut.
  static void addPrinterFeatures(PrinterFeatureMap features) {
    _printerFeatures.featureMap.addAll(features);
  }

  /// Check if the printer has the feature.
  ///
  /// This will return `true` if [feature] is allowed for the printer or
  /// if [feature] is allowed for all printers.
  static bool printerHasFeatureOf(String printerName, PrinterFeature feature) {
    return _printerFeatures.hasFeatureOf(printerName, feature);
  }

  /// State to get bluetooth is connected
  bool _isConnected = false;

  /// Getter value [_isConnected]
  bool get isConnected => _isConnected;

  FluetoothDevice? _selectedDevice;

  /// Selected device after connecting
  FluetoothDevice? get selectedDevice => _selectedDevice;

  /// return bluetooth device list, handler Android and iOS in [BlueScanner]
  Future<List<FluetoothDevice>> scan() {
    return Fluetooth().getAvailableDevices();
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
      final FluetoothDevice fDevice = await Fluetooth().connect(device.id).timeout(timeout);
      _selectedDevice = fDevice;
      _isConnected = true;
      return Future<ConnectionStatus>.value(ConnectionStatus.connected);
    } on Exception catch (error) {
      log('$runtimeType - Error $error');
      _isConnected = false;
      _selectedDevice = null;
      return Future<ConnectionStatus>.value(ConnectionStatus.timeout);
    }
  }

  /// To stop communication between bluetooth device and application
  Future<ConnectionStatus> disconnect() async {
    await Fluetooth().disconnect();
    _isConnected = false;
    _selectedDevice = null;
    return ConnectionStatus.disconnect;
  }

  Future<void> printReceiptText(
    ReceiptSectionText receiptSectionText, {
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

    final BatchPrintOptions batchOptions = batchPrintOptions ?? BatchPrintOptions.full;

    final Iterable<List<Object>> startEndIter = batchOptions.getStartEnd(contentLength);

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

      await _printProcess(bytes);
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
    List<int> bytes, {
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
    await _printProcess(bytesResult);
  }

  static String base64toHexadecimal(String data) {
    final hexadecimal = PrinterTextParserImg.base64ImageToHexadecimalString(
      _escPosPrinter,
      data,
      false,
    );
    return hexadecimal;
  }

  /// This method only for print QR, only pass value on parameter [data]
  /// define [size] to size of QR, default value is 120
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
  Future<void> printQR(
    String data, {
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

    await _printProcess(bytes);
  }

  /// Reusable method for print text, image or QR based value [byteBuffer]
  /// Handler Android or iOS will use method writeBytes from ByteBuffer
  /// But in iOS more complex handler using service and characteristic
  Future<void> _printProcess(List<int> byteBuffer) async {
    try {
      if (!await Fluetooth().isConnected) {
        _isConnected = false;
        _selectedDevice = null;
        return;
      }
      await Fluetooth().sendBytes(byteBuffer);
      _escPosPrinter.clearTextsToPrint();
      _escPosPrinter.printerConnection.clearData();
    } on Exception catch (error) {
      _isConnected = false;
      _selectedDevice = null;
      _escPosPrinter.clearTextsToPrint();
      _escPosPrinter.printerConnection.clearData();
      log('$runtimeType - Error $error');
      return;
    }
  }
}
