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
    List.copyRange(data, 0, this.data, 0, this.data.length);
    List.copyRange(data, this.data.length, bytes, 0, bytes.length);
    this.data = data;
  }
}
