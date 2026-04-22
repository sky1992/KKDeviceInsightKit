#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceMemoryInfo : NSObject
+ (double)total_memory;
+ (NSString *)total_memory_gb;
+ (NSString *)can_use_memory;
+ (NSString *)disk_space;
+ (NSString *)free_disk_space;
@end

NS_ASSUME_NONNULL_END
