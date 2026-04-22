#import "KKWifiInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CFNetwork/CFNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation KKWifiInfo
+ (NSString *)wifi_name {
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    if (![interfaces isKindOfClass:[NSArray class]]) return @"null";
    for (NSString *interface in interfaces) {
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface));
        NSString *ssid = info[@"SSID"];
        if (ssid.length > 0) return ssid;
    }
    return @"null";
}
+ (NSString *)wifi_bssid {
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    if (![interfaces isKindOfClass:[NSArray class]]) return @"null";
    for (NSString *interface in interfaces) {
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface));
        NSString *bssid = info[@"BSSID"];
        if (bssid.length > 0) return bssid;
    }
    return @"null";
}
+ (NSString *)is_vpn {
    NSDictionary *proxy = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSDictionary *scoped = proxy[@"__SCOPED__"];
    if (![scoped isKindOfClass:[NSDictionary class]]) return @"false";
    NSArray *prefixes = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
    for (NSString *key in scoped.allKeys) {
        NSString *lower = key.lowercaseString;
        for (NSString *p in prefixes) if ([lower hasPrefix:p]) return @"true";
    }
    return @"false";
}
+ (NSString *)network_info {
    NSString *radio = [CTTelephonyNetworkInfo new].serviceCurrentRadioAccessTechnology.allValues.firstObject;
    if (!radio) return @"0";
    if ([radio isEqualToString:CTRadioAccessTechnologyNR] || [radio isEqualToString:CTRadioAccessTechnologyNRNSA]) return @"5";
    if ([radio isEqualToString:CTRadioAccessTechnologyLTE]) return @"4";
    if ([radio isEqualToString:CTRadioAccessTechnologyWCDMA] || [radio isEqualToString:CTRadioAccessTechnologyHSDPA]) return @"3";
    if ([radio isEqualToString:CTRadioAccessTechnologyGPRS] || [radio isEqualToString:CTRadioAccessTechnologyEdge]) return @"2";
    return @"0";
}
+ (NSString *)network_type {
    if (![[self wifi_name] isEqualToString:@"null"]) return @"1";
    NSString *mobile = [self network_info];
    return [mobile isEqualToString:@"0"] ? @"0" : mobile;
}
+ (NSString *)is_jail_broken {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
                  [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"];
    return exists ? @"true" : @"false";
}
@end
