#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceScreenInfo : NSObject
+ (NSString *)screen_width;
+ (NSString *)screen_height;
+ (NSString *)battery_level;
+ (NSString *)charging;
+ (NSString *)screen_resolution;
+ (NSString *)screen_brightness;
+ (NSString *)proxied;
@end

NS_ASSUME_NONNULL_END
