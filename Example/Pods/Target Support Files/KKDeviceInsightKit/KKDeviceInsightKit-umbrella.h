#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KKAddressBookInfo.h"
#import "KKApplicationInfo.h"
#import "KKDeviceBaseInfo.h"
#import "KKDeviceIdInfo.h"
#import "KKDeviceMemoryInfo.h"
#import "KKDeviceScreenInfo.h"
#import "KKDeviceSystemInfo.h"
#import "KKLocationPermissionInfo.h"
#import "KKOCVersions.h"
#import "KKPermissionInfo.h"
#import "KKSystemServicePara.h"
#import "KKWifiInfo.h"

FOUNDATION_EXPORT double KKDeviceInsightKitVersionNumber;
FOUNDATION_EXPORT const unsigned char KKDeviceInsightKitVersionString[];

