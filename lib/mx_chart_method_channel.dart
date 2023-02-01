import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mx_chart_platform_interface.dart';

/// An implementation of [MxChartPlatform] that uses method channels.
class MethodChannelMxChart extends MxChartPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mx_chart');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
