#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKSystemServicePara : NSObject
+ (void)system_service_para:(void(^)(NSDictionary<NSString *,id> * para))completion;
@end

NS_ASSUME_NONNULL_END
