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
        // Simulator
        @"i386": @"iPhone Simulator",
        @"x86_64": @"iPhone Simulator",
        @"arm64": @"iPhone Simulator",
        
        // iPhone
        @"iPhone4,1": @"iPhone 4S",
        @"iPhone5,1": @"iPhone 5",
        @"iPhone5,2": @"iPhone 5",
        @"iPhone5,3": @"iPhone 5c",
        @"iPhone5,4": @"iPhone 5c",
        @"iPhone6,1": @"iPhone 5s",
        @"iPhone6,2": @"iPhone 5s",
        @"iPhone7,1": @"iPhone 6 Plus",
        @"iPhone7,2": @"iPhone 6",
        @"iPhone8,1": @"iPhone 6S",
        @"iPhone8,2": @"iPhone 6S Plus",
        @"iPhone8,4": @"iPhone SE",
        @"iPhone9,1": @"iPhone 7",
        @"iPhone9,3": @"iPhone 7",
        @"iPhone9,2": @"iPhone 7 Plus",
        @"iPhone9,4": @"iPhone 7 Plus",
        @"iPhone10,1": @"iPhone 8",
        @"iPhone10,4": @"iPhone 8",
        @"iPhone10,2": @"iPhone 8 Plus",
        @"iPhone10,5": @"iPhone 8 Plus",
        @"iPhone10,3": @"iPhone X",
        @"iPhone10,6": @"iPhone X",
        @"iPhone11,2": @"iPhone XS",
        @"iPhone11,4": @"iPhone XS Max",
        @"iPhone11,6": @"iPhone XS Max",
        @"iPhone11,8": @"iPhone XR",
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
        @"iPhone12,8": @"iPhone SE",
        @"iPhone13,1": @"iPhone 12 Mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
        @"iPhone14,4": @"iPhone 13 mini",
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,6": @"iPhone SE 3",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone14,8": @"iPhone 14 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone15,5": @"iPhone 15 Plus",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPhone17,1": @"iPhone 16 Pro",
        @"iPhone17,2": @"iPhone 16 Pro Max",
        @"iPhone17,3": @"iPhone 16",
        @"iPhone17,4": @"iPhone 16 Plus",
        @"iPhone17,5": @"iPhone 16e",
        @"iPhone18,1": @"iPhone 17 Pro",
        @"iPhone18,2": @"iPhone 17 Pro Max",
        @"iPhone18,3": @"iPhone 17",
        @"iPhone18,4": @"iPhone Air",
        
        // iPad
        @"iPad2,5": @"iPad Mini",
        @"iPad2,6": @"iPad Mini",
        @"iPad2,7": @"iPad Mini",
        @"iPad3,1": @"iPad 3",
        @"iPad3,2": @"iPad 3",
        @"iPad3,3": @"iPad 3",
        @"iPad3,4": @"iPad 4",
        @"iPad3,5": @"iPad 4",
        @"iPad3,6": @"iPad 4",
        @"iPad4,1": @"iPad AIR",
        @"iPad4,2": @"iPad AIR",
        @"iPad4,3": @"iPad AIR",
        @"iPad4,4": @"iPad Mini 2",
        @"iPad4,5": @"iPad Mini 2",
        @"iPad4,6": @"iPad Mini 2",
        @"iPad4,7": @"iPad Mini 3",
        @"iPad4,8": @"iPad Mini 3",
        @"iPad4,9": @"iPad Mini 3",
        @"iPad5,1": @"iPad Mini 4",
        @"iPad5,2": @"iPad Mini 4",
        @"iPad5,3": @"iPad AIR 2",
        @"iPad5,4": @"iPad AIR 2",
        @"iPad6,3": @"iPad PRO 9.7",
        @"iPad6,4": @"iPad PRO 9.7",
        @"iPad6,7": @"iPad PRO 12.9",
        @"iPad6,8": @"iPad PRO 12.9",
        @"iPad6,11": @"iPad (5th generation)",
        @"iPad6,12": @"iPad (5th generation)",
        @"iPad7,1": @"iPad PRO 12.9",
        @"iPad7,2": @"iPad PRO 12.9",
        @"iPad7,3": @"iPad PRO 10.5",
        @"iPad7,4": @"iPad PRO 10.5",
        @"iPad7,5": @"iPad (6th Gen)",
        @"iPad7,6": @"iPad (6th Gen)",
        @"iPad7,11": @"iPad (7th Gen)",
        @"iPad7,12": @"iPad (7th Gen)",
        @"iPad8,1": @"iPad PRO 11",
        @"iPad8,2": @"iPad PRO 11",
        @"iPad8,3": @"iPad PRO 11",
        @"iPad8,4": @"iPad PRO 11",
        @"iPad8,5": @"iPad PRO 12.9",
        @"iPad8,6": @"iPad PRO 12.9",
        @"iPad8,7": @"iPad PRO 12.9",
        @"iPad8,8": @"iPad PRO 12.9",
        @"iPad8,9": @"iPad PRO 11",
        @"iPad8,10": @"iPad PRO 11",
        @"iPad8,11": @"iPad PRO 12.9",
        @"iPad8,12": @"iPad PRO 12.9",
        @"iPad11,1": @"iPad mini 5th Gen",
        @"iPad11,2": @"iPad mini 5th Gen",
        @"iPad11,3": @"iPad Air 3rd Gen",
        @"iPad11,4": @"iPad Air 3rd Gen",
        @"iPad11,6": @"iPad 8th Gen",
        @"iPad11,7": @"iPad 8th Gen",
        @"iPad13,1": @"iPad air 4th Gen",
        @"iPad13,2": @"iPad air 4th Gen"
    };
}
+ (NSString *)system_device_type_formatted_name {
    NSString *model = [self system_device_type];
    return [self model_map][model] ?: model ?: @"";
}
@end
