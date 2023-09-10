import 'package:huaweicloud_iot_device_sdk/src/time_util.dart';
import 'package:test/test.dart';

void main() {
  test(
      'TimeUtil.getTimestamp returns the current timestamp in the correct format',
      () {
    final timestamp = TimeUtil.getTimestamp();
    final regex = RegExp(r'^\d{10}$');
    expect(regex.hasMatch(timestamp), isTrue);
  });
}
