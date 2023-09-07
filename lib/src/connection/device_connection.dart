import 'dart:typed_data';

class DeviceConnection {
  List<int> data = [];

  /// Add data to send.
  ///
  ///  public void write(byte[] bytes) {
  //         byte[] data = new byte[bytes.length + this.data.length];
  //         System.arraycopy(this.data, 0, data, 0, this.data.length);
  // this.data = source
  // first 0 = sourcePos
  // data = destination
  // 0 = destinationPos
  // this.data.length = length
  //         System.arraycopy(bytes, 0, data, this.data.length, bytes.length);
  //         this.data = data;
  //     }
  void write(List<int> bytes) {
    List<int> data = Uint8List(bytes.length + this.data.length);
    data.setRange(0, this.data.length, this.data, 0);
    data.setRange(this.data.length, this.data.length + bytes.length, bytes, 0);
    this.data = data;
  }
}
