//
//  CSKeychain.m
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSKeychain.h"
#import <Security/Security.h>
#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>
#import <CSkit/UIDevice+Extended.h>
#else
#import "CSKitMacro.h"
#import "UIDevice+Extended.h"
#endif




/**
 转换系统状态码
 
 @param status MacTypes->(SInt32)OSStatus
 @return CSKeychain错误状态码
 */
static CSKeychainErrorCode CSKeychainErrorCodeFromOSStatus(OSStatus status) {
    switch (status) {
        case errSecUnimplemented: return CSKeychainErrorUnimplemented;
        case errSecIO: return CSKeychainErrorIO;
        case errSecOpWr: return CSKeychainErrorOpWr;
        case errSecParam: return CSKeychainErrorParam;
        case errSecAllocate: return CSKeychainErrorAllocate;
        case errSecUserCanceled: return CSKeychainErrorUserCancelled;
        case errSecBadReq: return CSKeychainErrorBadReq;
        case errSecInternalComponent: return CSKeychainErrorInternalComponent;
        case errSecNotAvailable: return CSKeychainErrorNotAvailable;
        case errSecDuplicateItem: return CSKeychainErrorDuplicateItem;
        case errSecItemNotFound: return CSKeychainErrorItemNotFound;
        case errSecInteractionNotAllowed: return CSKeychainErrorInteractionNotAllowed;
        case errSecDecode: return CSKeychainErrorDecode;
        case errSecAuthFailed: return CSKeychainErrorAuthFailed;
        default: return 0;
    }
}


/**
 根据状态码返回错误描述
 
 @param code 状态码
 @return 错误描述
 */
static NSString *CSKeychainErrorDesc(CSKeychainErrorCode code) {
    switch (code) {
        case CSKeychainErrorUnimplemented:
            return @"Function or operation not implemented.";
        case CSKeychainErrorIO:
            return @"I/O error (bummers)";
        case CSKeychainErrorOpWr:
            return @"ile already open with with write permission.";
        case CSKeychainErrorParam:
            return @"One or more parameters passed to a function where not valid.";
        case CSKeychainErrorAllocate:
            return @"Failed to allocate memory.";
        case CSKeychainErrorUserCancelled:
            return @"User canceled the operation.";
        case CSKeychainErrorBadReq:
            return @"Bad parameter or invalid state for operation.";
        case CSKeychainErrorInternalComponent:
            return @"Inrernal Component";
        case CSKeychainErrorNotAvailable:
            return @"No keychain is available. You may need to restart your computer.";
        case CSKeychainErrorDuplicateItem:
            return @"The specified item already exists in the keychain.";
        case CSKeychainErrorItemNotFound:
            return @"The specified item could not be found in the keychain.";
        case CSKeychainErrorInteractionNotAllowed:
            return @"User interaction is not allowed.";
        case CSKeychainErrorDecode:
            return @"Unable to decode the provided data.";
        case CSKeychainErrorAuthFailed:
            return @"The user name or passphrase you entered is not";
        default:
            break;
    }
    return nil;
}


/**
 获取系统错误码合适的描述
 
 @param e 状态枚举
 @return 合适的描述
 */
static NSString *CSKeychainAccessibleStr(CSKeychainAccessible e) {
    switch (e) {
        case CSKeychainAccessibleWhenUnlocked:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlocked);
        case CSKeychainAccessibleAfterFirstUnlock:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlock);
        case CSKeychainAccessibleAlways:
            return (__bridge NSString *)(kSecAttrAccessibleAlways);
        case CSKeychainAccessibleWhenPasscodeSetThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
        case CSKeychainAccessibleWhenUnlockedThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlockedThisDeviceOnly);
        case CSKeychainAccessibleAfterFirstUnlockThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly);
        case CSKeychainAccessibleAlwaysThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAlwaysThisDeviceOnly);
        default:
            return nil;
    }
}


/**
 根据系统描述返回状态枚举
 
 @param s 错误描述
 @return 状态枚举
 */
static CSKeychainAccessible CSKeychainAccessibleEnum(NSString *s) {
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlocked])
        return CSKeychainAccessibleWhenUnlocked;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlock])
        return CSKeychainAccessibleAfterFirstUnlock;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlways])
        return CSKeychainAccessibleAlways;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly])
        return CSKeychainAccessibleWhenPasscodeSetThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
        return CSKeychainAccessibleWhenUnlockedThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly])
        return CSKeychainAccessibleAfterFirstUnlockThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlwaysThisDeviceOnly])
        return CSKeychainAccessibleAlwaysThisDeviceOnly;
    return CSKeychainAccessibleNone;
}


/**
 根据同步模式返回操作描述
 
 @param mode 同步模式
 @return CFStringRef操作描述
 */
static id CSKeychainQuerySynchonizationID(CSKeychainQuerySynchronizationMode mode) {
    switch (mode) {
        case CSKeychainQuerySynchronizationModeAny:
            return (__bridge id)(kSecAttrSynchronizableAny);
        case CSKeychainQuerySynchronizationModeNo:
            return (__bridge id)kCFBooleanFalse;
        case CSKeychainQuerySynchronizationModeYes:
            return (__bridge id)kCFBooleanTrue;
        default:
            return (__bridge id)(kSecAttrSynchronizableAny);
    }
}

static CSKeychainQuerySynchronizationMode CSKeychainQuerySynchonizationEnum(NSNumber *num) {
    if ([num isEqualToNumber:@NO])  return CSKeychainQuerySynchronizationModeNo;
    if ([num isEqualToNumber:@YES]) return CSKeychainQuerySynchronizationModeYes;
    return CSKeychainQuerySynchronizationModeAny;
}










@interface CSKeychainItem ()
@property (nonatomic, readwrite, strong) NSDate *modificationDate;
@property (nonatomic, readwrite, strong) NSDate *creationDate;
@end

@implementation CSKeychainItem

- (void)setPasswordObject:(id <NSCoding> )object {
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}

- (id <NSCoding> )passwordObject {
    if ([self.passwordData length]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}

- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)password {
    if ([self.passwordData length]) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSMutableDictionary *)queryDic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    dic[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    
    if (![UIDevice currentDevice].isSimulator) {
        /**
         如果在iPhone模拟器上运行,请删除该访问组.
         因为模拟器构建的应用程序未签名,因此没有钥匙串访问组用于模拟器进行检查.
         这意味着所有应用程序可以在模拟器上运行时看到所有钥匙串项.
         如果SecItem包含访问组属性,则模拟器上的SecItemAdd和SecItemUpdate将返回-25243(errSecNoAccessForItem).
         访问组属性将被包含在SecItemCopyMatching返回的项中,这就是为什么我们需要在更新item之前删除它。
         */
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (kiOS7Later) {
        dic[(__bridge id)kSecAttrSynchronizable] = CSKeychainQuerySynchonizationID(self.synchronizable);
    }
    
    return dic;
}

- (NSMutableDictionary *)dic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    dic[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    if (self.label) dic[(__bridge id)kSecAttrLabel] = self.label;
    
    if (![UIDevice currentDevice].isSimulator) {
        /**
         如果在iPhone模拟器上运行,请删除该访问组.
         因为模拟器构建的应用程序未签名,因此没有钥匙串访问组用于模拟器进行检查.
         这意味着所有应用程序可以在模拟器上运行时看到所有钥匙串项.
         如果SecItem包含访问组属性,则模拟器上的SecItemAdd和SecItemUpdate将返回-25243(errSecNoAccessForItem).
         访问组属性将被包含在SecItemCopyMatching返回的项中,这就是为什么我们需要在更新item之前删除它。
         */
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (kiOS7Later) {
        dic[(__bridge id)kSecAttrSynchronizable] = CSKeychainQuerySynchonizationID(self.synchronizable);
    }
    
    if (self.accessible) dic[(__bridge id)kSecAttrAccessible] = CSKeychainAccessibleStr(self.accessible);
    if (self.passwordData) dic[(__bridge id)kSecValueData] = self.passwordData;
    if (self.type) dic[(__bridge id)kSecAttrType] = self.type;
    if (self.creater) dic[(__bridge id)kSecAttrCreator] = self.creater;
    if (self.comment) dic[(__bridge id)kSecAttrComment] = self.comment;
    if (self.descr) dic[(__bridge id)kSecAttrDescription] = self.descr;
    
    return dic;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (dic.count == 0) return nil;
    self = self.init;
    
    self.service = dic[(__bridge id)kSecAttrService];
    self.account = dic[(__bridge id)kSecAttrAccount];
    self.passwordData = dic[(__bridge id)kSecValueData];
    self.label = dic[(__bridge id)kSecAttrLabel];
    self.type = dic[(__bridge id)kSecAttrType];
    self.creater = dic[(__bridge id)kSecAttrCreator];
    self.comment = dic[(__bridge id)kSecAttrComment];
    self.descr = dic[(__bridge id)kSecAttrDescription];
    self.modificationDate = dic[(__bridge id)kSecAttrModificationDate];
    self.creationDate = dic[(__bridge id)kSecAttrCreationDate];
    self.accessGroup = dic[(__bridge id)kSecAttrAccessGroup];
    self.accessible = CSKeychainAccessibleEnum(dic[(__bridge id)kSecAttrAccessible]);
    self.synchronizable = CSKeychainQuerySynchonizationEnum(dic[(__bridge id)kSecAttrSynchronizable]);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CSKeychainItem *item = [CSKeychainItem new];
    item.service = self.service;
    item.account = self.account;
    item.passwordData = self.passwordData;
    item.label = self.label;
    item.type = self.type;
    item.creater = self.creater;
    item.comment = self.comment;
    item.descr = self.descr;
    item.modificationDate = self.modificationDate;
    item.creationDate = self.creationDate;
    item.accessGroup = self.accessGroup;
    item.accessible = self.accessible;
    item.synchronizable = self.synchronizable;
    return item;
}

- (NSString *)description {
    NSMutableString *str = @"".mutableCopy;
    [str appendString:@"CSKeychainItem:{\n"];
    if (self.service) [str appendFormat:@"  service:%@,\n", self.service];
    if (self.account) [str appendFormat:@"  service:%@,\n", self.account];
    if (self.password) [str appendFormat:@"  service:%@,\n", self.password];
    if (self.label) [str appendFormat:@"  service:%@,\n", self.label];
    if (self.type) [str appendFormat:@"  service:%@,\n", self.type];
    if (self.creater) [str appendFormat:@"  service:%@,\n", self.creater];
    if (self.comment) [str appendFormat:@"  service:%@,\n", self.comment];
    if (self.descr) [str appendFormat:@"  service:%@,\n", self.descr];
    if (self.modificationDate) [str appendFormat:@"  service:%@,\n", self.modificationDate];
    if (self.creationDate) [str appendFormat:@"  service:%@,\n", self.creationDate];
    if (self.accessGroup) [str appendFormat:@"  service:%@,\n", self.accessGroup];
    [str appendString:@"}"];
    return str;
}

@end





@implementation CSKeychain

+ (NSString *)getPasswordForService:(NSString *)serviceName
                            account:(NSString *)account
                              error:(NSError **)error {
    if (!serviceName || !account) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return nil;
    }
    
    CSKeychainItem *item = [CSKeychainItem new];
    item.service = serviceName;
    item.account = account;
    CSKeychainItem *result = [self selectOneItem:item error:error];
    return result.password;
}

+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account {
    return [self getPasswordForService:serviceName account:account error:NULL];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName
                         account:(NSString *)account
                           error:(NSError **)error {
    if (!serviceName || !account) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    CSKeychainItem *item = [CSKeychainItem new];
    item.service = serviceName;
    item.account = account;
    return [self deleteItem:item error:error];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    return [self deletePasswordForService:serviceName account:account error:NULL];
}

+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account
              error:(NSError **)error {
    if (!password || !serviceName || !account) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return NO;
    }
    CSKeychainItem *item = [CSKeychainItem new];
    item.service = serviceName;
    item.account = account;
    CSKeychainItem *result = [self selectOneItem:item error:NULL];
    if (result) {
        result.password = password;
        return [self updateItem:result error:error];
    } else {
        item.password = password;
        return [self insertItem:item error:error];
    }
}

+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account {
    return [self setPassword:password forService:serviceName account:account error:NULL];
}

+ (BOOL)insertItem:(CSKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account || !item.passwordData) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item dic];
    OSStatus status = status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess) {
        if (error) *error = [CSKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)insertItem:(CSKeychainItem *)item {
    return [self insertItem:item error:NULL];
}

+ (BOOL)updateItem:(CSKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account || !item.passwordData) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item queryDic];
    NSMutableDictionary *update = [item dic];
    [update removeObjectForKey:(__bridge id)kSecClass];
    if (!query || !update) return NO;
    OSStatus status = status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    if (status != errSecSuccess) {
        if (error) *error = [CSKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)updateItem:(CSKeychainItem *)item {
    return [self updateItem:item error:NULL];
}

+ (BOOL)deleteItem:(CSKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item dic];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess) {
        if (error) *error = [CSKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)deleteItem:(CSKeychainItem *)item {
    return [self deleteItem:item error:NULL];
}

+ (CSKeychainItem *)selectOneItem:(CSKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account) {
        if (error) *error = [CSKeychain errorWithCode:errSecParam];
        return nil;
    }
    
    NSMutableDictionary *query = [item dic];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess) {
        if (error) *error = [[self class] errorWithCode:status];
        return nil;
    }
    if (!result) return nil;
    
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID()) {
        dic = (__bridge NSDictionary *)(result);
    } else if (CFGetTypeID(result) == CFArrayGetTypeID()){
        dic = [(__bridge NSArray *)(result) firstObject];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    if (!dic.count) return nil;
    return [[CSKeychainItem alloc] initWithDic:dic];
}

+ (CSKeychainItem *)selectOneItem:(CSKeychainItem *)item {
    return [self selectOneItem:item error:NULL];
}

+ (NSArray *)selectItems:(CSKeychainItem *)item error:(NSError **)error {
    NSMutableDictionary *query = [item dic];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
        return nil;
    }
    
    NSMutableArray *res = [NSMutableArray new];
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID()) {
        dic = (__bridge NSDictionary *)(result);
        CSKeychainItem *item = [[CSKeychainItem alloc] initWithDic:dic];
        if (item) [res addObject:item];
    } else if (CFGetTypeID(result) == CFArrayGetTypeID()){
        for (NSDictionary *dic in (__bridge NSArray *)(result)) {
            CSKeychainItem *item = [[CSKeychainItem alloc] initWithDic:dic];
            if (item) [res addObject:item];
        }
    }
    
    return res;
}

+ (NSArray *)selectItems:(CSKeychainItem *)item {
    return [self selectItems:item error:NULL];
}

+ (NSError *)errorWithCode:(OSStatus)osCode {
    CSKeychainErrorCode code = CSKeychainErrorCodeFromOSStatus(osCode);
    NSString *desc = CSKeychainErrorDesc(code);
    NSDictionary *userInfo = desc ? @{ NSLocalizedDescriptionKey : desc } : nil;
    return [NSError errorWithDomain:@"com.ibireme.CSKit.keychain" code:code userInfo:userInfo];
}

@end












