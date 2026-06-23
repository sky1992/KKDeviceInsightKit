#import "KKDeviceIdInfo.h"
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation KKDeviceIdInfo
+ (NSString *)device_id {
    NSString *bundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] ?: @"unknown.bundle";
    NSString *key = [NSString stringWithFormat:@"%@.id.some.app", bundle];
    NSString *saved = [self fetch_device_id:key];
    if (saved.length > 0) return saved;
    NSString *newID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (newID.length == 0) newID = @"null";
    [self save_device_id:newID for_key:key];
    return newID;
}
+ (void)save_device_id:(NSString *)ref for_key:(NSString *)key {
    NSMutableDictionary *q = [@{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: key,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock
    } mutableCopy];
    SecItemDelete((__bridge CFDictionaryRef)q);
    NSData *data = [ref dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return;
    q[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)q, NULL);
}
+ (nullable NSString *)fetch_device_id:(NSString *)key {
    NSDictionary *q = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: key,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
        (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    CFTypeRef obj = NULL;
    OSStatus s = SecItemCopyMatching((__bridge CFDictionaryRef)q, &obj);
    if (s != errSecSuccess || !obj) return nil;
    NSData *data = CFBridgingRelease(obj);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (NSString *)idfa {
    __block NSString *value = @"null";
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
            value = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: @"null";
        }
    }];
    return value;
}
+ (NSString *)idfv { return [[[UIDevice currentDevice] identifierForVendor] UUIDString] ?: @"null"; }
@end
