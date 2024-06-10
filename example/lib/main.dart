import 'dart:convert';
import 'dart:math' as math;

import 'package:example/int_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:youprint/youprint.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youprint Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Youprint Demo'),
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
  List<FluetoothDevice> _availableDevices = [];

  bool _isScanning = false;
  bool _isPrinting = false;

  final _youprint = Youprint();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanDevices();
    });
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
    });
    final devices = await _youprint.scan();

    setState(() {
      _availableDevices = devices;
      _isScanning = false;
    });
  }

  Future<void> _connectDevice(FluetoothDevice device) async {
    await _youprint.connect(device);
  }

  Future<void> _disconnectDevice(FluetoothDevice device) async {
    final status = await _youprint.disconnect(device);

    if (status == ConnectionStatus.disconnect) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _incrementCounter({
    required FluetoothDevice device,
    int totalItems = 1,
    bool useQR = true,
    bool useLogo = true,
  }) async {
    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/image.png',
    );

    /// Example for Print Text
    ReceiptSectionText receiptText = ReceiptSectionText();

    if (useLogo) {
      receiptText.addImage(
        base64.encode(Uint8List.view(logoBytes.buffer)),
        width: 330,
      );
      receiptText.addSpacer();
    }

    /// Merchant name
    receiptText.addText(
      'MY STORE',
      size: ReceiptTextSizeType.large,
      style: ReceiptTextStyleType.bold,
    );

    receiptText.addText(
      'Wisma 46, Jakarta, Indonesia',
      size: ReceiptTextSizeType.small,
    );

    receiptText.addSpacer();

    receiptText.addLeftRightText('No. Order', '10');

    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Waktu',
      DateFormat('H:mm, dd/MM/yy').format(DateTime.now().toLocal()),
    );
    receiptText.addSpacer(useDashed: true);
    int totalAmount = 0;
    for (int i = 0; i < totalItems; i++) {
      final qty = math.Random().nextInt(50);

      CartItem cartItem;
      if (i == 5) {
        cartItem = CartItem(
          name: "Ini ceritanya nama item yang panjang banget",
          quantity: qty,
          price: 1000,
        );
      } else {
        cartItem = CartItem(
          name: "Item ${i + 1}",
          quantity: qty,
          price: 1000,
        );
      }

      receiptText.addText(
        cartItem.name,
        alignment: ReceiptAlignment.left,
        style: ReceiptTextStyleType.bold,
      );
      receiptText.addLeftRightText(
        cartItem.qtyPrice,
        cartItem.totalPrice.inIDR,
        leftSize: ReceiptTextSizeType.small,
      );
      totalAmount += cartItem.totalPrice;
    }

    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Total',
      totalAmount.inIDR,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Payment',
      'Cash',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );

    receiptText.addText('--------------------------------');

    receiptText.addText('Scan kode QR berikut untuk melakukan pembayaran.');

    if (useQR) {
      receiptText.addQR(
        '00020101021226660014ID.LINKAJA.WWW011893000112093847326702151134829309421230303UME51400014ID.CO.QRIS.WWW0211123445678900303UME5204123453033605405290005802ID5913Voopoo Seller6006SERANG61054217162670118231031696394213432071642EF81DA-ED87-44982102126281011555060301163046D09',
        size: 350,
      );
    }

    for (int i = 0; i < 2; i++) {
      await _youprint.printReceiptText(
        receiptText,
        device.id,
        useCut: true,
        feedCount: 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: _scanDevices,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: _isScanning
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: _availableDevices.length,
                itemBuilder: (context, index) {
                  final FluetoothDevice currentDevice =
                      _availableDevices[index];
                  return ListTile(
                    title: Text(currentDevice.name),
                    subtitle: Text(currentDevice.id),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final connectedDevices =
                            await _youprint.connectedDevices;
                        if (!connectedDevices.contains(currentDevice)) {
                          await _connectDevice(currentDevice);
                        } else {
                          await _disconnectDevice(currentDevice);
                        }

                        setState(() {});
                      },
                      child: FutureBuilder<bool>(
                        future: Fluetooth().isConnected(currentDevice.id),
                        builder: (context, snapshotData) {
                          final isConnected = snapshotData.data;
                          return Text(
                            isConnected == true ? 'Disconnect' : 'Connect',
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: _isScanning
          ? const SizedBox.shrink()
          : FloatingActionButton(
              onPressed: _isPrinting
                  ? null
                  : () async {
                      setState(() => _isPrinting = true);
                      final connectedDevices = await _youprint.connectedDevices;
                      for (var device in connectedDevices) {
                        await _incrementCounter(
                          device: device,
                          useQR: true,
                          useLogo: true,
                        );
                      }
                      setState(() => _isPrinting = false);
                    },
              tooltip: 'Print',
              child: _isPrinting
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.print),
            ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CartItem {
  const CartItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final int price;

  String get qtyPrice => '$quantity x ${price.inIDR}';

  int get totalPrice => quantity * price;
}
