import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mx_chart_method_channel.dart';

abstract class MxChartPlatform extends PlatformInterface {
  /// Constructs a MxChartPlatform.
  MxChartPlatform() : super(token: _token);

  static final Object _token = Object();

  static MxChartPlatform _instance = MethodChannelMxChart();

  /// The default instance of [MxChartPlatform] to use.
  ///
  /// Defaults to [MethodChannelMxChart].
  static MxChartPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MxChartPlatform] when
  /// they register themselves.
  static set instance(MxChartPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
