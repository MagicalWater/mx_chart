import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mx_chart/mx_chart_method_channel.dart';

void main() {
  MethodChannelMxChart platform = MethodChannelMxChart();
  const MethodChannel channel = MethodChannel('mx_chart');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
