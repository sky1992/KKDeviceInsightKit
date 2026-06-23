#import <Foundation/Foundation.h>
#import "KKPermissionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface KKLocationPermissionInfo : NSObject
+ (void)request_location_permission:(void(^)(KKPermissionResult *result))completion;
+ (void)request_location_coordinate_string:(void(^)(KKPermissionResult *permission, NSString *latitude, NSString *longitude))completion;
@end

NS_ASSUME_NONNULL_END
