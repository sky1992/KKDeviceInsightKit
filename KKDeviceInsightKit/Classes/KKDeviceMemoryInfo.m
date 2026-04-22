#import "KKDeviceMemoryInfo.h"
#import <mach/mach.h>

@implementation KKDeviceMemoryInfo
+ (double)total_memory {
    double total = (double)[NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0;
    NSInteger toNearest = 256;
    NSInteger rem = ((NSInteger)total) % toNearest;
    if (rem >= toNearest / 2) total = ((NSInteger)total - rem) + 256;
    else total = ((NSInteger)total - rem);
    return total <= 0 ? -1 : total;
}
+ (NSString *)total_memory_gb { return [NSString stringWithFormat:@"%.6f", [self total_memory] / 1024.0]; }
+ (NSString *)can_use_memory {
    double totalGB = (double)[NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0 / 1024.0;
    vm_size_t pageSize = 0;
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t count = (mach_msg_type_number_t)(sizeof(vm_statistics64_data_t) / sizeof(integer_t));
    if (host_page_size(mach_host_self(), &pageSize) != KERN_SUCCESS) return @"-1";
    kern_return_t result = host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vmStats, &count);
    if (result != KERN_SUCCESS) return @"-1";
    double used = (double)(vmStats.active_count + vmStats.inactive_count + vmStats.wire_count) * (double)pageSize;
    double free = MAX(0.0, totalGB - used / 1024.0 / 1024.0 / 1024.0);
    return [NSString stringWithFormat:@"%.6f", free];
}
+ (int64_t)long_disk_space {
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *n = attrs[NSFileSystemSize];
    return n ? n.longLongValue : -1;
}
+ (int64_t)long_free_disk_space {
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *n = attrs[NSFileSystemFreeSize];
    return n ? n.longLongValue : -1;
}
+ (NSString *)format_memory:(int64_t)space {
    if (space <= 0) return @"0";
    return [NSString stringWithFormat:@"%.6f", (double)space / 1024.0 / 1024.0 / 1024.0];
}
+ (NSString *)disk_space { return [self format_memory:[self long_disk_space]]; }
+ (NSString *)free_disk_space { return [self format_memory:[self long_free_disk_space]]; }
@end
