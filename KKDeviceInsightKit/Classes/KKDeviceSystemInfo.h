#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceSystemInfo : NSObject
+ (NSString *)debugger;
+ (NSString *)time_zone;
+ (NSString *)total_boot_time_wake;
+ (nullable NSString *)system_uptime:(NSDateComponentsFormatterUnitsStyle)units_style;
+ (NSString *)system_boot_up_time;
+ (NSString *)system_last_up_time;
+ (NSString *)system_current_time;
+ (NSString *)system_name;
+ (NSString *)device_name;
+ (NSString *)system_version;
+ (NSString *)system_device_type;
+ (NSString *)system_device_type_formatted_name;
@end

NS_ASSUME_NONNULL_END
