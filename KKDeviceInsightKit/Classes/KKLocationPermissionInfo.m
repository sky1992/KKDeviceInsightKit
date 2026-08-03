#import "KKLocationPermissionInfo.h"
#import <CoreLocation/CoreLocation.h>

@interface KKLocationDelegateOC : NSObject <CLLocationManagerDelegate>
@property (nonatomic, copy, nullable) void (^permission_completion)(KKPermissionResult *);
@property (nonatomic, copy, nullable) void (^coordinate_completion)(KKPermissionResult *, NSString *, NSString *);
@property (nonatomic, assign) BOOL has_returned_coordinate;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation KKLocationDelegateOC
- (instancetype)init { if (self = [super init]) { _lock = [NSLock new]; } return self; }
@end

@implementation KKLocationPermissionInfo
static CLLocationManager *_kk_loc_mgr = nil;
static KKLocationDelegateOC *_kk_loc_delegate = nil;
+ (void)initialize {
    if (self == [KKLocationPermissionInfo class]) {
        _kk_loc_mgr = [CLLocationManager new];
        _kk_loc_delegate = [KKLocationDelegateOC new];
        _kk_loc_mgr.delegate = _kk_loc_delegate;
    }
}

+ (KKPermissionResult *)location_permission {
    CLAuthorizationStatus s = _kk_loc_mgr.authorizationStatus;
    KKPermissionResult *r = [KKPermissionResult new];
    if (s == kCLAuthorizationStatusAuthorizedAlways || s == kCLAuthorizationStatusAuthorizedWhenInUse) {
        r.status = KKPermissionStatusAllowed;
    }else {
        r.status = KKPermissionStatusDenied;
    }
    r.is_first_system_choice = NO;
    return r;
}

+ (KKPermissionResult *)location_change_permission {
    CLAuthorizationStatus s = _kk_loc_mgr.authorizationStatus;
    KKPermissionResult *r = [KKPermissionResult new];
    if (s == kCLAuthorizationStatusAuthorizedAlways || s == kCLAuthorizationStatusAuthorizedWhenInUse) {
        r.status = KKPermissionStatusAllowed;
    }else {
        r.status = KKPermissionStatusDenied;
    }
    r.is_first_system_choice = YES;
    return r;
}

+ (void)request_location_permission:(void(^)(KKPermissionResult *))completion {
    CLAuthorizationStatus s = _kk_loc_mgr.authorizationStatus;
    KKPermissionResult *r = [KKPermissionResult new];
    if (s == kCLAuthorizationStatusAuthorizedAlways || s == kCLAuthorizationStatusAuthorizedWhenInUse) {
        r.status = KKPermissionStatusAllowed;
    }else {
        r.status = KKPermissionStatusDenied;
    }
    r.is_first_system_choice = YES;
    if (s != kCLAuthorizationStatusNotDetermined) {
        completion(r);
        return;
    }
    _kk_loc_delegate.permission_completion = completion;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_kk_loc_mgr requestWhenInUseAuthorization];
    });
}

+ (void)request_location_coordinate_string:(void(^)(KKPermissionResult *, NSString *, NSString *))completion {
    CLAuthorizationStatus s = _kk_loc_mgr.authorizationStatus;
    void (^start)(void) = ^{
        [_kk_loc_delegate.lock lock];
        _kk_loc_delegate.coordinate_completion = completion;
        _kk_loc_delegate.has_returned_coordinate = NO;
        [_kk_loc_delegate.lock unlock];
        dispatch_async(dispatch_get_main_queue(), ^{ [_kk_loc_mgr requestLocation]; });
    };
    if (s == kCLAuthorizationStatusAuthorizedAlways || s == kCLAuthorizationStatusAuthorizedWhenInUse) {
        start(); return;
    }
    if (s == kCLAuthorizationStatusNotDetermined) {
        [self request_location_permission:^(KKPermissionResult *result) {
            if (result.status != KKPermissionStatusAllowed) {
                completion(result, @"", @"");
                return;
            }
            start();
        }];
        return;
    }
    completion([self location_permission], @"", @"");
}
@end

@implementation KKLocationDelegateOC (Callbacks)

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if ([manager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    if (self.permission_completion) {
        void (^cb)(KKPermissionResult *) = self.permission_completion;
        self.permission_completion = nil;
        cb([KKLocationPermissionInfo location_change_permission]);
    }
}

- (void)finishCoordinateOnce:(NSString *)lat lon:(NSString *)lon {
    [self.lock lock];
    if (self.has_returned_coordinate) { [self.lock unlock]; return; }
    self.has_returned_coordinate = YES;
    void (^cb)(KKPermissionResult *, NSString *, NSString *) = self.coordinate_completion;
    self.coordinate_completion = nil;
    [self.lock unlock];
    if (cb) cb([KKLocationPermissionInfo location_permission], lat, lon);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *loc = locations.lastObject;
    if (!loc) { [self finishCoordinateOnce:@"" lon:@""]; return; }
    NSString *lat = [NSString stringWithFormat:@"%.6f", loc.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%.6f", loc.coordinate.longitude];
    [self finishCoordinateOnce:lat lon:lon];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self finishCoordinateOnce:@"" lon:@""];
}
@end
