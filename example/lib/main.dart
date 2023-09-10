import 'dart:developer';

import 'package:fluetooth/fluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:youprint/youprint.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This widget is the root of your application.
  bool _isBusy = false;
  List<FluetoothDevice>? _devices;
  FluetoothDevice? _connectedDevice;

  Future<void> _refreshPrinters() async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    final List<FluetoothDevice> devices = await Fluetooth().getAvailableDevices();
    setState(() {
      _devices = devices;
      _isBusy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshPrinters();
  }

  Future<void> _connect(FluetoothDevice device) async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    final FluetoothDevice connectedDevice = await Fluetooth().connect(
      device.id,
    );

    setState(() {
      _isBusy = false;
      _connectedDevice = connectedDevice;
    });
  }

  Future<void> _disconnect() async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    await Fluetooth().disconnect();
    setState(() {
      _isBusy = false;
      _connectedDevice = null;
    });
  }

  @override
  void dispose() {
    Fluetooth().disconnect();
    super.dispose();
  }

  Future<void> _incrementCounter() async {
    if (_isBusy) {
      return;
    }
    final DeviceConnection deviceConnection = DeviceConnection();
    final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
    final ByteData logoBytes = await rootBundle.load('assets/logo.png');
    final resize = img.copyResize(img.decodeImage(logoBytes.buffer.asUint8List())!, width: 150);
    StringBuffer bufferText = StringBuffer()
      ..write("[C]<img>")
      ..write(PrinterTextParserImg.imageToHexadecimalString(escPosPrinter, resize, false))
      ..write("</img>\n")
      ..write("[C]<u><font size='big'>ORDER N045</font></u>\n")
      ..write("[C]\n")
      ..write("[C]================================\n")
      ..write("[L]\n")
      ..write("[L]<b>BEAUTIFUL SHIRT</b>[R]9.99€\n")
      ..write("[L]  + Size : S\n")
      ..write("[L]\n")
      ..write("[L]<b>AWESOME HAT</b>[R]24.99€\n")
      ..write("[L]  + Size : 57/58\n")
      ..write("[L]\n")
      ..write("[C]--------------------------------\n")
      ..write("[R]TOTAL PRICE :[R]34.98€\n")
      ..write("[R]TAX :[R]4.23€\n")
      ..write("[L]\n")
      ..write("[C]================================\n")
      ..write("[L]\n")
      ..write("[L]<u><font color='bg-black' size='tall'>Customer :</font></u>\n")
      ..write("[L]Raymond DUPONT\n")
      ..write("[L]5 rue des girafes\n")
      ..write("[L]31547 PERPETES\n")
      ..write("[L]Tel : +33801201456\n")
      ..write("[L]\n")
      ..write("[C]<barcode type='ean13' height='10'>831254784551</barcode>\n")
      ..write("[C]<qrcode>youtap.id</qrcode>\n");
    escPosPrinter.addTextToPrint(bufferText.toString());
    final AsyncEscPosPrint escPosPrint = AsyncEscPosPrint();
    escPosPrint.parsedToBytes(escPosPrinter);

    log('bytes: ${escPosPrinter.printerConnection.data}');
    await Fluetooth().sendBytes(escPosPrinter.printerConnection.data);
    // await Fluetooth().sendBytes(EscPosPrinterCommands.printQRCode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _devices?.length ?? 0,
          itemBuilder: (context, index) {
            final FluetoothDevice currentDevice = _devices![index];
            return ListTile(
              title: Text(currentDevice.name),
              subtitle: Text(currentDevice.id),
              trailing: ElevatedButton(
                onPressed: _connectedDevice == currentDevice
                    ? _disconnect
                    : _connectedDevice == null && !_isBusy
                        ? () => _connect(currentDevice)
                        : null,
                child: Text(
                  _connectedDevice == currentDevice ? 'Disconnect' : 'Connect',
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectedDevice == null ? _refreshPrinters : _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
