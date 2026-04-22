#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKRawContactItem : NSObject
@property (nonatomic, strong, nullable) NSDate *modification_time;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSArray<NSString *> *phones;
@end

@interface KKAddressBookInfo : NSObject
+ (NSString *)mobile_regex_pattern;
+ (NSArray<KKRawContactItem *> *)fetch_raw_contacts;
+ (NSArray<NSArray<NSDictionary<NSString *, NSString *> *> *> *)build_contact_batches:(NSInteger)max_count
                                                                             per_count:(NSInteger)per_count;
+ (NSArray<NSArray<NSDictionary<NSString *, NSString *> *> *> *)process_and_batch:(NSArray<KKRawContactItem *> *)raw_contacts
                                                                         max_count:(NSInteger)max_count
                                                                         per_count:(NSInteger)per_count;
@end

NS_ASSUME_NONNULL_END
