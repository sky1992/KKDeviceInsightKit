#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceIdInfo : NSObject
+ (NSString *)device_id;
+ (NSString *)idfa;
+ (NSString *)idfv;
@end

NS_ASSUME_NONNULL_END
