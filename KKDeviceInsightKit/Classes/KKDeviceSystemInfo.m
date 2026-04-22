#import "KKDeviceSystemInfo.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <sys/utsname.h>

@implementation KKDeviceSystemInfo
+ (NSString *)debugger {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc info;
    size_t size = sizeof(info);
    memset(&info, 0, sizeof(info));
    int ret = sysctl(mib, 4, &info, &size, NULL, 0);
    if (ret != 0) return @"false";
    return ((info.kp_proc.p_flag & P_TRACED) != 0) ? @"true" : @"false";
}
+ (NSString *)time_zone { return [NSTimeZone localTimeZone].name ?: @""; }
+ (NSString *)total_boot_time_wake { return [NSString stringWithFormat:@"%lld", (long long)([NSProcessInfo processInfo].systemUptime * 1000)]; }
+ (nullable NSString *)system_uptime:(NSDateComponentsFormatterUnitsStyle)units_style {
    NSDateComponentsFormatter *f = [[NSDateComponentsFormatter alloc] init];
    f.unitsStyle = units_style;
    return [f stringFromTimeInterval:[NSProcessInfo processInfo].systemUptime];
}
+ (NSString *)system_boot_up_time {
    struct timeval boottime, now;
    size_t size = sizeof(boottime);
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) == -1 || boottime.tv_sec == 0) return @"-1";
    gettimeofday(&now, NULL);
    int64_t uptime = (int64_t)(now.tv_sec - boottime.tv_sec) * 1000 + (int64_t)(now.tv_usec - boottime.tv_usec) / 1000;
    return [NSString stringWithFormat:@"%lld", uptime];
}
+ (NSString *)system_last_up_time {
    int64_t up = [[self system_boot_up_time] longLongValue];
    if (up <= 0) return @"-1";
    NSTimeInterval interval = up / 1000.0;
    NSDate *boot = [NSDate dateWithTimeIntervalSinceNow:-interval];
    return [NSString stringWithFormat:@"%lld", (long long)(boot.timeIntervalSince1970 * 1000)];
}
+ (NSString *)system_current_time { return [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)]; }
+ (NSString *)system_name { return [UIDevice currentDevice].systemName ?: @""; }
+ (NSString *)device_name { return [UIDevice currentDevice].name ?: @""; }
+ (NSString *)system_version { return [UIDevice currentDevice].systemVersion ?: @""; }
+ (NSString *)system_device_type {
    struct utsname u;
    uname(&u);
    return [NSString stringWithCString:u.machine encoding:NSUTF8StringEncoding] ?: @"";
}
+ (NSDictionary *)model_map {
    return @{
        @"i386": @"iPhone Simulator", @"x86_64": @"iPhone Simulator", @"arm64": @"iPhone Simulator",
        @"iPhone15,4": @"iPhone 15", @"iPhone15,5": @"iPhone 15 Plus", @"iPhone16,1": @"iPhone 15 Pro", @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPhone17,1": @"iPhone 16 Pro", @"iPhone17,2": @"iPhone 16 Pro Max", @"iPhone17,3": @"iPhone 16", @"iPhone17,4": @"iPhone 16 Plus",
        @"iPad13,1": @"iPad air 4th Gen", @"iPad13,2": @"iPad air 4th Gen"
    };
}
+ (NSString *)system_device_type_formatted_name {
    NSString *model = [self system_device_type];
    return [self model_map][model] ?: model ?: @"";
}
@end
