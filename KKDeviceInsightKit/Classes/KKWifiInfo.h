#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKWifiInfo : NSObject
+ (void)wifi_info:(void(^)(NSString * _Nullable ssid, NSString * _Nullable bssid))completion;
+ (NSString *)is_vpn;
+ (NSString *)network_type;
+ (NSString *)is_jail_broken;
@end

NS_ASSUME_NONNULL_END
