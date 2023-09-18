import 'dart:typed_data';

class DeviceConnection {
  List<int> data = [];

  void write(List<int> bytes) {
    List<int> data = Uint8List(bytes.length + this.data.length);
    data.setRange(0, this.data.length, this.data, 0);
    data.setRange(this.data.length, this.data.length + bytes.length, bytes, 0);
    this.data = data;
  }
}
