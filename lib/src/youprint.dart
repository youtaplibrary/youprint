import 'dart:async';
import 'dart:developer';

import 'package:fluetooth/fluetooth.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:youprint/src/receipt/receipt_image.dart';
import 'package:youprint/youprint.dart';

export 'package:fluetooth/fluetooth.dart' show FluetoothDevice;

enum PaperSize { mm58, mm80 }

class Youprint {
  static final Youprint _instance = Youprint();

  static Youprint get instance => _instance;

  static final PrinterFeatures _printerFeatures = PrinterFeatures();

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
    log(receiptSectionText.getContent());

    final int contentLength = receiptSectionText.contentLength;

    final BatchPrintOptions batchOptions = batchPrintOptions ?? BatchPrintOptions.full;

    final Iterable<List<Object>> startEndIter = batchOptions.getStartEnd(contentLength);

    for (final List<Object> startEnd in startEndIter) {
      final DeviceConnection deviceConnection = DeviceConnection();
      final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
      final ReceiptSectionText section = receiptSectionText.getSection(
        startEnd[0] as int,
        startEnd[1] as int,
      );

      final bool isEndOfBatch = startEnd[2] as bool;
      escPosPrinter.addTextToPrint(section.getContent());
      final bytes = await escPosPrinter.parsedToBytes(
        feedCount: isEndOfBatch ? feedCount : batchOptions.feedCount,
        useCut: isEndOfBatch ? useCut : batchOptions.useCut,
        openDrawer: openDrawer,
      );

      await _printProcess(bytes);
    }
  }

  static int pixelToMM(int pixel) {
    const double inchToMM = 25.4;
    const double printerDPI = 203;
    return (pixel * inchToMM / printerDPI).round();
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
    final DeviceConnection deviceConnection = DeviceConnection();
    final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
    final resize = img.copyResize(
      img.decodeImage(Uint8List.fromList(bytes))!,
      width: width,
    );
    final hexadecimal = PrinterTextParserImg.imageToHexadecimalString(escPosPrinter, resize, false);
    final ReceiptImage image = ReceiptImage(hexadecimal);
    escPosPrinter.addTextToPrint(image.text);
    final bytesResult = await escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: true,
      openDrawer: openDrawer,
    );
    await _printProcess(bytesResult);
  }

  static String base64toHexadecimal(String data) {
    final DeviceConnection deviceConnection = DeviceConnection();
    final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
    final hexadecimal = PrinterTextParserImg.base64ImageToHexadecimalString(
      escPosPrinter,
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
    final DeviceConnection deviceConnection = DeviceConnection();
    final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
    final ReceiptQR qr = ReceiptQR(data, size: size.toInt());
    escPosPrinter.addTextToPrint(qr.text);
    final bytes = await escPosPrinter.parsedToBytes(
      feedCount: feedCount,
      useCut: useCut,
      openDrawer: openDrawer,
    );
    _printProcess(bytes);
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
    } on Exception catch (error) {
      log('$runtimeType - Error $error');
    }
  }

  // /// This method to convert byte from [data] into as image canvas.
  // /// It will automatically set width and height based [paperSize].
  // /// [customWidth] to print image with specific width
  // /// [feedCount] to generate byte buffer as feed in receipt.
  // /// [useCut] to cut of receipt layout as byte buffer.
  // Future<List<int>> _getBytes(
  //   List<int> data, {
  //   PaperSize paperSize = PaperSize.mm58,
  //   int customWidth = 0,
  //   int feedCount = 0,
  //   bool useCut = false,
  //   bool useRaster = false,
  //   bool openDrawer = false,
  // }) async {
  //   List<int> bytes = <int>[];
  //   final CapabilityProfile profile = await CapabilityProfile.load();
  //   final Generator generator = Generator(paperSize, profile);
  //   final img.Image _resize = img.copyResize(
  //     img.decodeImage(data)!,
  //     width: customWidth > 0 ? customWidth : paperSize.width,
  //   );
  //   final bool canFullCut = printerHasFeatureOf(
  //     _selectedDevice!.name,
  //     PrinterFeature.paperFullCut,
  //   );
  //   if (openDrawer) {
  //     bytes += generator.drawer();
  //   }
  //   if (useRaster) {
  //     bytes += generator.imageRaster(_resize);
  //   } else {
  //     bytes += generator.image(_resize);
  //   }
  //   if (feedCount > 0) {
  //     bytes += generator.feed(feedCount);
  //   }
  //   if (useCut && canFullCut) {
  //     bytes += generator.cut();
  //   }
  //   return bytes;
  // }

  /// This method to convert byte from [data] into as image canvas.
  /// It will automatically set width and height based [paperSize].
  /// [customWidth] to print image with specific width
  /// [feedCount] to generate byte buffer as feed in receipt.
  /// [useCut] to cut of receipt layout as byte buffer.
  // Future<List<int>> _getBytesFromEscPos(
  //   List<int> data, {
  //   PaperSize paperSize = PaperSize.mm58,
  //   int customWidth = 0,
  //   int feedCount = 0,
  //   bool useCut = false,
  //   bool openDrawer = false,
  //   bool isQR = false,
  // }) async {
  //   List<int> bytes = data;
  //   // final CapabilityProfile profile = await CapabilityProfile.load();
  //   // final Generator generator = Generator(paperSize, profile);
  //   //
  //   // if (isQR) {
  //   //   bytes = <int>[];
  //   //   final img.Image _resize = img.copyResize(
  //   //     img.decodeImage(data)!,
  //   //     width: customWidth > 0 ? customWidth : paperSize.width,
  //   //   );
  //   //   bytes += generator.image(_resize);
  //   // }
  //
  //   final bool canFullCut = printerHasFeatureOf(
  //     _selectedDevice!.name,
  //     PrinterFeature.paperFullCut,
  //   );
  //   if (openDrawer) {
  //     bytes += generator.drawer();
  //   }
  //   if (feedCount > 0) {
  //     bytes += generator.feed(feedCount);
  //   }
  //   if (useCut && canFullCut) {
  //     bytes += generator.cut();
  //   }
  //   return bytes;
  // }

  /// Handler to generate QR image from [text] and set the [size].
  /// Using painter and convert to [Image] object and return as [Uint8List]
  // Future<Uint8List> _getQRImage(String text, double size) async {}

  //
  // static Future<String?> getImageHexadecimal({
  //   required String content,
  //   int? width,
  // }) async {
  //   final Map<String, dynamic> arguments = <String, dynamic>{
  //     'content': content,
  //     'width': width,
  //   };
  //   String? results;
  //   try {
  //     results = await _channel.invokeMethod<String>('convertImageToHexadecimal', arguments);
  //   } on Exception catch (e) {
  //     log('[method:parserTextToBytes]: $e');
  //     throw Exception('Error: $e');
  //   }
  //   return results;
  // }
  //
  // /// Converts HTML content to bytes
  // ///
  // /// [content] the html text
  // ///
  // /// [duration] the delay duration before converting the html to bytes.
  // /// defaults to 0.
  // ///
  // /// [textScaleFactor] the text scale factor (must be > 0 or null).
  // /// note that this currently only works on Android.
  // /// defaults to system's font settings.
  // static Future<Uint8List> contentToImage({
  //   required String content,
  //   double duration = 0,
  //   double? textScaleFactor,
  // }) async {
  //   assert(
  //     textScaleFactor == null || textScaleFactor > 0,
  //     '`textScaleFactor` must be either null or more than zero.',
  //   );
  //   final Map<String, dynamic> arguments = <String, dynamic>{
  //     'content': content,
  //     'duration': Platform.isIOS ? 2000 : duration,
  //     'textScaleFactor': textScaleFactor,
  //   };
  //   Uint8List results = Uint8List.fromList(<int>[]);
  //   try {
  //     results =
  //         await _channel.invokeMethod('contentToImage', arguments) ?? Uint8List.fromList(<int>[]);
  //   } on Exception catch (e) {
  //     log('[method:contentToImage]: $e');
  //     throw Exception('Error: $e');
  //   }
  //   return results;
  // }
}
