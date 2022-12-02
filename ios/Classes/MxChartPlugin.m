#import "MxChartPlugin.h"
#if __has_include(<mx_chart/mx_chart-Swift.h>)
#import <mx_chart/mx_chart-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mx_chart-Swift.h"
#endif

@implementation MxChartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMxChartPlugin registerWithRegistrar:registrar];
}
@end
