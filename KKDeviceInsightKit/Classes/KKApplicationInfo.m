#import "KKApplicationInfo.h"
#import <UIKit/UIKit.h>

@implementation KKApplicationInfo
+ (NSString *)application_version {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
}
+ (NSString *)application_simulator {
    return ([[self application_version] containsString:@"Simulator"]) ? @"true" : @"false";
}
@end
