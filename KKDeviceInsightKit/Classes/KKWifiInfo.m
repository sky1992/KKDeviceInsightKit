#import "KKWifiInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
//#import <CFNetwork/CFNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <NetworkExtension/NetworkExtension.h>

@implementation KKWifiInfo

+ (void)wifi_info:(void(^)(NSString * _Nullable ssid, NSString * _Nullable bssid, NSString * _Nullable net))completion {
    [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
        NSString *ssid = currentNetwork.SSID ?: @"null";
        NSString *bssid = currentNetwork.BSSID ?: @"null";
        NSString *net = @"0";
        if (![ssid isEqualToString:@"null"]) {
            net = @"1";
        }else {
            net = [self network_info];
        }
        completion(ssid, bssid, net);
    }];
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

+ (NSString *)is_jail_broken {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
                  [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"];
    return exists ? @"true" : @"false";
}
@end
