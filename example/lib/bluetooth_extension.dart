import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// split write should be used with caution.
//    1. due to splitting, `characteristic.read()` will return partial data.
//    2. it can only be used *with* response to avoid data loss
//    3. The characteristic must be designed to support split data
extension SplitWrite on BluetoothCharacteristic {
  Future<void> splitWrite(List<int> value, {int timeout = 15}) async {
    int chunk = device.mtuNow > 512 ? 512 : device.mtuNow;

    chunk = chunk - 3; // 3 bytes ble overhead

    for (int i = 0; i < value.length; i += chunk) {
      List<int> subValue = value.sublist(i, min(i + chunk, value.length));
      await write(
        subValue,
        withoutResponse: false,
        timeout: timeout,
        allowLongWrite: true,
      );
    }
  }
}
