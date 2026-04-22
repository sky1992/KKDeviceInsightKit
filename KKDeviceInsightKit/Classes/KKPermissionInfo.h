#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KKPermissionStatus) {
    KKPermissionStatusAllowed = 0,
    KKPermissionStatusDenied = 1,
    KKPermissionStatusLimited = 2
};

@interface KKPermissionResult : NSObject
@property (nonatomic, assign) KKPermissionStatus status;
@property (nonatomic, assign) BOOL is_first_system_choice;
- (NSDictionary<NSString *, id> *)as_dictionary;
@end

@interface KKPermissionInfo : NSObject
+ (KKPermissionResult *)contacts_permission;
+ (KKPermissionResult *)camera_permission;
+ (void)notification_permission:(void(^)(KKPermissionResult *result))completion;
+ (void)request_contacts_permission:(void(^)(KKPermissionResult *result))completion;
+ (void)request_camera_permission:(void(^)(KKPermissionResult *result))completion;
@end

NS_ASSUME_NONNULL_END
