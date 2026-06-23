#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKRawContactItem : NSObject
@property (nonatomic, strong, nullable) NSDate *modification_time;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSArray<NSString *> *phones;
@end

@interface KKAddressBookInfo : NSObject
+ (BOOL)is_valid_mobile_phone:(NSString *)phone;
+ (NSString *)normalize_india_local_prefix:(NSString *)phone;
+ (NSArray<NSArray<NSDictionary<NSString *, NSString *> *> *> *)build_contact_batches:(NSInteger)max_count
                                                                             per_count:(NSInteger)per_count;
@end

NS_ASSUME_NONNULL_END
