#import "KKDeviceScreenInfo.h"
#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

@implementation KKDeviceScreenInfo
+ (NSString *)screen_width { return [NSString stringWithFormat:@"%d", (int)[UIScreen mainScreen].bounds.size.width]; }
+ (NSString *)screen_height { return [NSString stringWithFormat:@"%d", (int)[UIScreen mainScreen].bounds.size.height]; }
+ (NSString *)battery_level {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float level = [UIDevice currentDevice].batteryLevel;
    if (level <= 0.0f) return @"-1";
    return [NSString stringWithFormat:@"%d", (int)(level * 100)];
}
+ (NSString *)charging {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState s = [UIDevice currentDevice].batteryState;
    return (s == UIDeviceBatteryStateCharging || s == UIDeviceBatteryStateFull) ? @"true" : @"false";
}
+ (NSString *)screen_resolution {
    UIScreen *s = [UIScreen mainScreen];
    return [NSString stringWithFormat:@"%d-%d", (int)(s.bounds.size.width * s.scale), (int)(s.bounds.size.height * s.scale)];
}
+ (NSString *)screen_brightness {
    CGFloat b = [UIScreen mainScreen].brightness;
    if (b < 0.0 || b > 1.0) return @"-1";
    return [NSString stringWithFormat:@"%d", (int)(b * 100)];
}
+ (NSString *)proxied {
    NSDictionary *proxySettings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    if (!proxySettings) return @"false";
    NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
    if (!url) return @"false";
    NSArray *proxies = CFBridgingRelease(CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)proxySettings));
    NSDictionary *first = proxies.firstObject;
    NSString *type = first[(NSString *)kCFProxyTypeKey];
    return [type isEqualToString:(NSString *)kCFProxyTypeNone] ? @"false" : @"true";
}
@end
