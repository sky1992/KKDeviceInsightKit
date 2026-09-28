#import "KKWifiInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <NetworkExtension/NetworkExtension.h>
#import <Network/Network.h>

@implementation KKWifiInfo

+ (void)wifi_info:(void(^)(NSString * _Nullable ssid, NSString * _Nullable bssid, NSString * _Nullable net))completion {
    [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
        NSString *ssid = currentNetwork.SSID ?: @"null";
        NSString *bssid = currentNetwork.BSSID ?: @"null";
        NSString *net = @"0";
        if (![ssid isEqualToString:@"null"]) {
            net = @"1";
        }else {
            net = [self network_type];
        }
        completion(ssid, bssid, net);
    }];
}

+ (NSString *)network_type {
    __block NSString *net = @"0";
    nw_path_monitor_t monitor = nw_path_monitor_create();
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("nw.monitor.queue", DISPATCH_QUEUE_SERIAL);
    
    nw_path_monitor_set_queue(monitor, queue);
    
    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
            net = @"1";
        } else if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
            net = [self network_info];
        } else {
            net = @"0";
        }
        dispatch_semaphore_signal(semaphore);
        nw_path_monitor_cancel(monitor);
    });
    
    nw_path_monitor_start(monitor);
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, timeout);
    
    return net;
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
