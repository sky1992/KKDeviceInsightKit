#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKWifiInfo : NSObject
+ (NSString *)wifi_name;
+ (NSString *)wifi_bssid;
+ (NSString *)is_vpn;
+ (NSString *)network_type;
+ (NSString *)is_jail_broken;
@end

NS_ASSUME_NONNULL_END
