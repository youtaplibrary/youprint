import 'package:example/int_extension.dart';
import 'package:fluetooth/fluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // final ReceiptSectionText receiptSectionText = ReceiptSectionText();
    // receiptSectionText.addSpacer();
    // // receiptSectionText.addLeftRightText("TrailID", "202309X001695178");
    // receiptSectionText.addLeftRightText("TrailID", "202309X001695178604015");
    // await _youprint.printReceiptText(receiptSectionText);

    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/logo.png',
    );

    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();

    // if (useLogo) {
    //   receiptText.addImage(
    //     base64.encode(Uint8List.view(logoBytes.buffer)),
    //     width: 150,
    //   );
    //   receiptText.addSpacer();
    // }
    //
    // /// Merchant name
    // receiptText.addText(
    //   'MY STORE',
    //   size: ReceiptTextSizeType.large,
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
    //   receiptText.addText(cartItem.name, alignment: ReceiptAlignment.left);
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
    // receiptText.addSpacer(count: 2);

    receiptText.addLeftRightText("Trail ID coba dulu ya", "123456789123456");
    receiptText.addText(
      'Jl. Kenangan yang ceritanya panjang banget sampe gak muat nih satu baris, Indonesia',
      alignment: ReceiptAlignment.center,
    );

    await _youprint.printReceiptText(receiptText, feedCount: 1);

    // if (useQR) {
    //   /// Example for print QR
    //   await _youprint.printQR('www.youtap.id', size: 250, feedCount: 1);
    // }
    //
    // if (useBarcode) {
    //   final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    //   receiptSecondText.addSpacer();
    //   receiptSecondText.addBarcode('1234567890', size: 400);
    //   await _youprint.printReceiptText(receiptSecondText, feedCount: 1);
    // }
  }
  // final DeviceConnection deviceConnection = DeviceConnection();
  // final AsyncEscPosPrinter escPosPrinter = AsyncEscPosPrinter(deviceConnection, 203, 48.0, 32);
  // final ByteData logoBytes = await rootBundle.load('assets/logo.png');
  // final resize = img.copyResize(img.decodeImage(logoBytes.buffer.asUint8List())!, width: 150);
  // StringBuffer bufferText = StringBuffer()
  //   ..write("[C]<img>")
  //   ..write(PrinterTextParserImg.imageToHexadecimalString(escPosPrinter, resize, false))
  //   ..write("</img>\n")
  //   ..write("[C]<u><font size='big'>ORDER N045</font></u>\n")
  //   ..write("[C]\n")
  //   ..write("[C]================================\n")
  //   ..write("[L]\n")
  //   ..write("[L]<b>BEAUTIFUL SHIRT</b>[R]9.99€\n")
  //   ..write("[L]  + Size : S\n")
  //   ..write("[L]\n")
  //   ..write("[L]<b>AWESOME HAT</b>[R]24.99€\n")
  //   ..write("[L]  + Size : 57/58\n")
  //   ..write("[L]\n")
  //   ..write("[C]--------------------------------\n")
  //   ..write("[R]TOTAL PRICE :[R]34.98€\n")
  //   ..write("[R]TAX :[R]4.23€\n")
  //   ..write("[L]\n")
  //   ..write("[C]================================\n")
  //   ..write("[L]\n")
  //   ..write("[L]<u><font color='bg-black' size='tall'>Customer :</font></u>\n")
  //   ..write("[L]Raymond DUPONT\n")
  //   ..write("[L]5 rue des girafes\n")
  //   ..write("[L]31547 PERPETES\n")
  //   ..write("[L]Tel : +33801201456\n")
  //   ..write("[L]\n")
  //   ..write("[C]<barcode type='ean13' height='10'>831254784551</barcode>\n")
  //   ..write("[L]\n")
  //   ..write("[C]<qrcode>youtap.id</qrcode>\n");
  // escPosPrinter.addTextToPrint(bufferText.toString());
  // final bytes = await escPosPrinter.parsedToBytes();
  // await Fluetooth().sendBytes(bytes);
  // await Fluetooth().sendBytes(EscPosPrinterCommands.printQRCode());

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
