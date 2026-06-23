#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKWifiInfo : NSObject
+ (NSString *)is_vpn;
+ (NSString *)is_jail_broken;
+ (void)wifi_info:(void(^)(NSString * _Nullable ssid, NSString * _Nullable bssid, NSString * _Nullable net))completion;
@end

NS_ASSUME_NONNULL_END
