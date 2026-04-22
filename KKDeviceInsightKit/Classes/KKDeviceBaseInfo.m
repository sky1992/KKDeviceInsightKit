#import "KKDeviceBaseInfo.h"

@implementation KKDeviceBaseInfo
+ (NSString *)number_random {
    NSString *chars = @"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *r = [NSMutableString stringWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
        uint32_t idx = arc4random_uniform((uint32_t)chars.length);
        [r appendFormat:@"%C", [chars characterAtIndex:idx]];
    }
    return r;
}
+ (NSString *)number_processors { return [NSString stringWithFormat:@"%ld", (long)[NSProcessInfo processInfo].processorCount]; }
+ (NSString *)language {
    NSString *lang = [NSLocale preferredLanguages].firstObject;
    if (lang.length == 0) return @"null";
    return [[lang componentsSeparatedByString:@"-"] firstObject] ?: @"null";
}
@end
