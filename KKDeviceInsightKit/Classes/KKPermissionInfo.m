#import "KKPermissionInfo.h"
#import <Contacts/Contacts.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@implementation KKPermissionResult
- (NSDictionary<NSString *,id> *)as_dictionary {
    NSString *status = @"denied";
    if (self.status == KKPermissionStatusAllowed) status = @"allowed";
    else if (self.status == KKPermissionStatusLimited) status = @"limited";
    return @{@"status": status, @"is_first_system_choice": @(self.is_first_system_choice)};
}
@end

@implementation KKPermissionInfo
+ (KKPermissionResult *)result:(KKPermissionStatus)status first:(BOOL)first {
    KKPermissionResult *r = [KKPermissionResult new];
    r.status = status;
    r.is_first_system_choice = first;
    return r;
}
+ (KKPermissionResult *)contacts_permission {
    CNAuthorizationStatus s = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (s == CNAuthorizationStatusAuthorized) return [self result:KKPermissionStatusAllowed first:NO];
    if (s == CNAuthorizationStatusLimited) return [self result:KKPermissionStatusLimited first:NO];
    if (s == CNAuthorizationStatusNotDetermined) return [self result:KKPermissionStatusDenied first:YES];
    return [self result:KKPermissionStatusDenied first:NO];
}
+ (KKPermissionResult *)camera_permission {
    AVAuthorizationStatus s = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (s == AVAuthorizationStatusAuthorized) return [self result:KKPermissionStatusAllowed first:NO];
    if (s == AVAuthorizationStatusNotDetermined) return [self result:KKPermissionStatusDenied first:YES];
    return [self result:KKPermissionStatusDenied first:NO];
}
+ (void)notification_permission:(void(^)(KKPermissionResult *))completion {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                completion([self result:(granted ? KKPermissionStatusAllowed : KKPermissionStatusDenied) first:YES]);
            }];
            return;
        }
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) completion([self result:KKPermissionStatusAllowed first:NO]);
        else if (settings.authorizationStatus == UNAuthorizationStatusProvisional || settings.authorizationStatus == UNAuthorizationStatusEphemeral) completion([self result:KKPermissionStatusLimited first:NO]);
        else completion([self result:KKPermissionStatusDenied first:NO]);
    }];
}
+ (void)request_contacts_permission:(void(^)(KKPermissionResult *))completion {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusNotDetermined) {
        completion([self contacts_permission]); return;
    }
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        completion([self contacts_permission]);
    }];
}
+ (void)request_camera_permission:(void(^)(KKPermissionResult *))completion {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusNotDetermined) {
        completion([self camera_permission]); return;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        completion([self camera_permission]);
    }];
}
@end
