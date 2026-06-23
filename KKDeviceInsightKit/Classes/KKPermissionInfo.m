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
    switch (s) {
        case CNAuthorizationStatusAuthorized:
            return [self result:KKPermissionStatusAllowed first:NO];
        case CNAuthorizationStatusLimited:
            return [self result:KKPermissionStatusLimited first:NO];
        default:
            return [self result:KKPermissionStatusDenied first:NO];
    }
}
+ (KKPermissionResult *)camera_permission {
    AVAuthorizationStatus s = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (s == AVAuthorizationStatusAuthorized) return [self result:KKPermissionStatusAllowed first:NO];
    return [self result:KKPermissionStatusDenied first:NO];
}

+ (KKPermissionResult *)contacts_first_permission {
    CNAuthorizationStatus s = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (s) {
        case CNAuthorizationStatusAuthorized:
            return [self result:KKPermissionStatusAllowed first:YES];
        case CNAuthorizationStatusLimited:
            return [self result:KKPermissionStatusLimited first:YES];
        default:
            return [self result:KKPermissionStatusDenied first:YES];
    }
}
+ (KKPermissionResult *)camera_first_permission {
    AVAuthorizationStatus s = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (s == AVAuthorizationStatusAuthorized) return [self result:KKPermissionStatusAllowed first:YES];
    return [self result:KKPermissionStatusDenied first:YES];
}


+ (void)notification_permission:(void(^)(KKPermissionResult *))completion {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([self result:(granted ? KKPermissionStatusAllowed : KKPermissionStatusDenied) first:YES]);
                });
            }];
            return;
        }
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self result:KKPermissionStatusAllowed first:NO]);
            });
        }
        else if (settings.authorizationStatus == UNAuthorizationStatusProvisional || settings.authorizationStatus == UNAuthorizationStatusEphemeral) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self result:KKPermissionStatusLimited first:NO]);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([self result:KKPermissionStatusDenied first:NO]);
            });
        }
    }];
}
+ (void)request_contacts_permission:(void(^)(KKPermissionResult *))completion {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self contacts_permission]);
        });
        return;
    }
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self contacts_first_permission]);
        });
    }];
}
+ (void)request_camera_permission:(void(^)(KKPermissionResult *))completion {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self camera_permission]);
        });
        return;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self camera_first_permission]);
        });
    }];
}
@end
