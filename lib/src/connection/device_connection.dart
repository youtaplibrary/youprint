import 'dart:typed_data';

class DeviceConnection {
  Uint8List _data = Uint8List(0);

  void write(List<int> bytes) {
    List<int> data = Uint8List(bytes.length + _data.length);
    data.setRange(0, _data.length, _data, 0);
    data.setRange(_data.length, _data.length + bytes.length, bytes, 0);
    _data = Uint8List.fromList(data);
  }

  void clearData() => _data = Uint8List(0);

  Uint8List getData() => _data;
}
