import 'dart:developer';

import 'package:fluetooth/fluetooth.dart';
import 'package:flutter/material.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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
    escPosPrinter.addTextToPrint("[L]\n" +
        "[C]<u><font size='big'>ORDER N045</font></u>\n" +
        "[C]\n" +
        "[C]================================\n" +
        "[L]\n" +
        "[L]<b>BEAUTIFUL SHIRT</b>[R]9.99€\n" +
        "[L]  + Size : S\n" +
        "[L]\n" +
        "[L]<b>AWESOME HAT</b>[R]24.99€\n" +
        "[L]  + Size : 57/58\n" +
        "[L]\n" +
        "[C]--------------------------------\n" +
        "[R]TOTAL PRICE :[R]34.98€\n" +
        "[R]TAX :[R]4.23€\n" +
        "[L]\n" +
        "[C]================================\n" +
        "[L]\n" +
        "[L]<u><font color='bg-black' size='tall'>Customer :</font></u>\n" +
        "[L]Raymond DUPONT\n" +
        "[L]5 rue des girafes\n" +
        "[L]31547 PERPETES\n" +
        "[L]Tel : +33801201456\n");
    final AsyncEscPosPrint escPosPrint = AsyncEscPosPrint();
    await escPosPrint.parsedToBytes(escPosPrinter);
    log('bytes: ${escPosPrinter.printerConnection.data.length}');
    await Fluetooth().sendBytes(escPosPrinter.printerConnection.data);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
