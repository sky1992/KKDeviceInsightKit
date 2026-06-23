#import <Foundation/Foundation.h>
#import "KKWifiInfo.h"
#import "KKDeviceMemoryInfo.h"
#import "KKDeviceSystemInfo.h"
#import "KKDeviceScreenInfo.h"
#import "KKDeviceBaseInfo.h"
#import "KKApplicationInfo.h"
#import "KKDeviceIdInfo.h"
#import "KKAddressBookInfo.h"
#import "KKLocationPermissionInfo.h"
#import "KKPermissionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface KKSystemServicePara : NSObject
//+ (NSDictionary<NSString *, id> *)system_service_para;
+ (void)system_service_para:(void(^)(NSDictionary<NSString *,id> * para))completion;
@end

NS_ASSUME_NONNULL_END
