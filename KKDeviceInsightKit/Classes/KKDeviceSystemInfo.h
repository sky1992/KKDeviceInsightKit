#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceSystemInfo : NSObject
+ (NSString *)debugger;
+ (NSString *)time_zone;
+ (NSString *)system_current_time;
+ (NSString *)system_name;
+ (NSString *)device_name;
+ (NSString *)system_version;
+ (NSString *)system_device_type;
+ (NSString *)system_device_type_formatted_name;
@end

NS_ASSUME_NONNULL_END
