// import 'dart:math' as math;

import 'package:example/int_extension.dart';
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

  final _youprint = Youprint();

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

  Future<void> _incrementCounter({
    int totalItems = 10,
    bool useQR = true,
    bool useLogo = true,
    bool useBarcode = true,
  }) async {
    if (_isBusy) {
      return;
    }

    // /// Example for Print Image
    // final ByteData logoBytes = await rootBundle.load(
    //   'assets/image.png',
    // );
    //
    // /// Example for Print Text
    // final ReceiptSectionText receiptText = ReceiptSectionText();
    //
    // if (useLogo) {
    //   receiptText.addImage(
    //     base64.encode(Uint8List.view(logoBytes.buffer)),
    //     width: 480,
    //   );
    //   receiptText.addSpacer();
    // }
    //
    // /// Merchant name
    // receiptText.addText(
    //   'MY STORE',
    //   size: ReceiptTextSizeType.large,
    //   style: ReceiptTextStyleType.bold,
    // );
    //
    // receiptText.addText(
    //   'Wisma 46, Jakarta, Indonesia',
    //   size: ReceiptTextSizeType.small,
    // );
    //
    // receiptText.addSpacer();
    //
    // receiptText.addLeftRightText('No. Order', '10');
    //
    // receiptText.addSpacer(useDashed: true);
    // receiptText.addLeftRightText(
    //   'Waktu',
    //   DateFormat('H:mm, dd/MM/yy').format(DateTime.now().toLocal()),
    // );
    // receiptText.addSpacer(useDashed: true);
    // int totalAmount = 0;
    // for (int i = 0; i < totalItems; i++) {
    //   final qty = math.Random().nextInt(50);
    //
    //   CartItem cartItem;
    //   if (i == 5) {
    //     cartItem = CartItem(
    //       name: "Ini ceritanya nama item yang panjang banget",
    //       quantity: qty,
    //       price: 1000,
    //     );
    //   } else {
    //     cartItem = CartItem(
    //       name: "Item ${i + 1}",
    //       quantity: qty,
    //       price: 1000,
    //     );
    //   }
    //
    //   receiptText.addText(
    //     cartItem.name,
    //     alignment: ReceiptAlignment.left,
    //     style: ReceiptTextStyleType.bold,
    //   );
    //   receiptText.addLeftRightText(
    //     cartItem.qtyPrice,
    //     cartItem.totalPrice.inIDR,
    //     leftSize: ReceiptTextSizeType.small,
    //   );
    //   totalAmount += cartItem.totalPrice;
    // }
    //
    // receiptText.addSpacer(useDashed: true);
    // receiptText.addLeftRightText(
    //   'Total',
    //   totalAmount.inIDR,
    //   rightStyle: ReceiptTextStyleType.bold,
    // );
    // receiptText.addSpacer(useDashed: true);
    // receiptText.addLeftRightText(
    //   'Payment',
    //   'Cash',
    //   leftStyle: ReceiptTextStyleType.normal,
    //   rightStyle: ReceiptTextStyleType.normal,
    // );
    //
    // await _youprint.printReceiptText(receiptText, feedCount: 1);
    //
    // if (useQR) {
    //   /// Example for print QR
    //   await _youprint.printQR(
    //     '00020101021226660014ID.LINKAJA.WWW011893600911002144000102151904161014400010303UBE51440014ID.CO.QRIS.WWW02151904161014400010303UBE52041234530336054032605802ID5924Jaya Abadi Cabang Serang6006SERANG6105421716267011823094169531974558207163bfecd4d55ed402c98210212628101155103030116304D44D',
    //     size: 480,
    //     feedCount: 1,
    //   );
    // }
    //
    // if (useBarcode) {
    //   final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    //   receiptSecondText.addSpacer();
    //   receiptSecondText.addBarcode('831254784551', size: 400);
    //   await _youprint.printReceiptText(receiptSecondText, feedCount: 1);
    // }

    ReceiptSectionText receiptSectionText = ReceiptSectionText();
    receiptSectionText.addLeftRightText(
      'Trail ID',
      '20231313123812381238123812',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );
    receiptSectionText.addLeftRightText(
      'Penambahan Harga',
      'Rp.5500',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );

    await _youprint.printReceiptText(receiptSectionText, feedCount: 1);
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
