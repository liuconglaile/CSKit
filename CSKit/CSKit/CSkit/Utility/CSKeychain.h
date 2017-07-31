//
//  CSKeychain.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSKeychainItem;
NS_ASSUME_NONNULL_BEGIN


///MARK: ===================================================
///MARK: 当前类常用枚举
///MARK: ===================================================


/**
 CSKeychain API中的错误代码
 
 - CSKeychainErrorUnimplemented: 功能或操作未实现
 - CSKeychainErrorIO: I/O错误(bummers)
 - CSKeychainErrorOpWr: 文件已打开,具有写入权限
 - CSKeychainErrorParam: 传递给无效的函数的一个或多个参数
 - CSKeychainErrorAllocate: 无法分配内存
 - CSKeychainErrorUserCancelled: 用户取消操作
 - CSKeychainErrorBadReq: 错误的参数或无效的操作
 - CSKeychainErrorInternalComponent: Internal...
 - CSKeychainErrorNotAvailable: 无钥匙串可用.您可能需要重新启动计算机
 - CSKeychainErrorDuplicateItem: 指定的项目已经存在于钥匙串中
 - CSKeychainErrorItemNotFound: 在钥匙串中找不到指定的项目
 - CSKeychainErrorInteractionNotAllowed: 不允许用户交互
 - CSKeychainErrorDecode: 无法解码提供的数据
 - CSKeychainErrorAuthFailed: 您输入的用户名或密码不正确
 */
typedef NS_ENUM (NSUInteger, CSKeychainErrorCode) {
    CSKeychainErrorUnimplemented = 1,
    CSKeychainErrorIO,
    CSKeychainErrorOpWr,
    CSKeychainErrorParam,
    CSKeychainErrorAllocate,
    CSKeychainErrorUserCancelled,
    CSKeychainErrorBadReq,
    CSKeychainErrorInternalComponent,
    CSKeychainErrorNotAvailable,
    CSKeychainErrorDuplicateItem,
    CSKeychainErrorItemNotFound,
    CSKeychainErrorInteractionNotAllowed,
    CSKeychainErrorDecode,
    CSKeychainErrorAuthFailed,
};



/**
 当查询返回项目的数据时,如果项目的数据在设备解锁发生之前不可用,则将返回错误errSecInteractionNotAllowed
 
 - CSKeychainAccessibleNone: <#CSKeychainAccessibleNone description#>
 
 - CSKeychainAccessibleWhenUnlocked:
   项目数据只能在设备解锁时才能访问.
   这是建议用于只有在应用程序处于前台时才可以访问的项目.使用此属性的项目将在使用加密备份时迁移到新设备
 
 - CSKeychainAccessibleAfterFirstUnlock:
   只有在重新启动设备被解锁后才能访问项目数据.
   这对于需要由后台应用程序访问的项目是推荐的.具有此属性的项目将在使用加密备份时迁移到新设备
 
 - CSKeychainAccessibleAlways:
   无论设备的锁定状态如何,始终可以访问项目数据.
   除系统使用外,不建议使用此功能.具有此属性的项目将在使用加密备份时迁移到新设备
 
 - CSKeychainAccessibleWhenPasscodeSetThisDeviceOnly:
   项目数据只能在设备解锁时才能访问.
   此类仅在设备上设置了密码时可用.对于只有在应用程序处于前台时才需要访问的项目,这是建议的.
   具有此属性的项目将永远不会迁移到新设备,因此在备份恢复到新设备后,这些项目将会丢失.
   没有密码的设备上没有任何项目可以存储在此类中.禁用设备密码将导致此类中的所有项目被删除
 
 - CSKeychainAccessibleWhenUnlockedThisDeviceOnly:
   项目数据只能在设备解锁时才能访问.
   这是建议用于只有在应用程序处于前台时才可以访问的项目.
   具有此属性的项目将永远不会迁移到新设备,因此在备份恢复到新设备后,这些项目将会丢失
 
 - CSKeychainAccessibleAfterFirstUnlockThisDeviceOnly:
   只有在重新启动设备被解锁后才能访问项目数据.
   对于需要后台应用程序访问的项目,建议这样做.
   具有此属性的项目将永远不会迁移到新设备,因此在备份恢复到新设备后,这些项目将丢失
 
 - CSKeychainAccessibleAlwaysThisDeviceOnly:
   无论设备的锁定状态如何,始终可以访问项目数据.
   除系统使用外,不建议使用此选项.
   具有此属性的项目将不会迁移到新设备,因此在备份恢复到新设备后,这些项目将丢失
 */
typedef NS_ENUM (NSUInteger, CSKeychainAccessible) {
    CSKeychainAccessibleNone = 0,
    CSKeychainAccessibleWhenUnlocked,
    CSKeychainAccessibleAfterFirstUnlock,
    CSKeychainAccessibleAlways,
    CSKeychainAccessibleWhenPasscodeSetThisDeviceOnly,
    CSKeychainAccessibleWhenUnlockedThisDeviceOnly,
    CSKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    CSKeychainAccessibleAlwaysThisDeviceOnly,
};


/**
 该项目是否可以同步
 
 - CSKeychainQuerySynchronizationModeAny: 默认,不关心同步
 - CSKeychainQuerySynchronizationModeNo:  不同步
 - CSKeychainQuerySynchronizationModeYes: 添加可以同步到其他设备的新项目,或从查询获取同步的结果
 */
typedef NS_ENUM (NSUInteger, CSKeychainQuerySynchronizationMode) {
    CSKeychainQuerySynchronizationModeAny = 0,
    CSKeychainQuerySynchronizationModeNo,
    CSKeychainQuerySynchronizationModeYes,
} NS_AVAILABLE_IOS (7_0);





/**
 系统钥匙串API的封装.
 参考来源于[SSKeychain](https://github.com/soffes/sskeychain)
 */
@interface CSKeychain : NSObject

///MARK: ===================================================
///MARK: 钥匙串的便捷方法
///MARK: ===================================================

/**
 返回给定帐户和服务器的密码,如果找不到或者发生错误,则返回'nil'.

 如果发生错误,则将此指针设置为包含错误信息的实际错误对象.
 如果不想要错误信息,则可以为此参数指定nil.请参见CSKeychainErrorCode
 
 @param serviceName 服务器名称.该值不能为 nil
 @param account     账号.该值不能为 nil
 @param error       在输入时,指向错误对象的指针.
 @return 密码字符串,未找到或发生错误时为nil.
 */
+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account
                                       error:(NSError **)error;
+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account;

/**
 从钥匙串中删除密码

 @param serviceName 服务器名称.该值不能为 nil
 @param account     账号.该值不能为 nil
 @param error       在输入时,指向错误对象的指针.
 @return 是否成功
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;

/**
 插入或更新给定帐户和服务的密码

 @param password    新密码
 @param serviceName 服务器名称.该值不能为 nil
 @param account     账号.该值不能为 nil
 @param error       在输入时,指向错误对象的指针.
 @return 是否成功
 */
+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account
              error:(NSError **)error;
+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account;


///MARK: ===================================================
///MARK: 钥匙串的完整查询(类似SQL)
///MARK: ===================================================

/**
 插入一项钥匙串
 需要serviceName,account,password.如果有项目已存在,则出现错误并插入失败
 
 @param item    要插入的item
 @param error   在输入时,指向错误对象的指针.
 @return 是否成功
 */
+ (BOOL)insertItem:(CSKeychainItem *)item error:(NSError **)error;
+ (BOOL)insertItem:(CSKeychainItem *)item;


/**
 更新钥匙串中的Item
 需要serviceName,account,password.如果有项目已存在,则出现错误并插入失败
 
 @param item    要插入的item
 @param error   在输入时,指向错误对象的指针.
 @return 是否成功
 */
+ (BOOL)updateItem:(CSKeychainItem *)item error:(NSError **)error;
+ (BOOL)updateItem:(CSKeychainItem *)item;


/**
 删除钥匙串item

 @param item    要删除的item
 @param error   在删除时,指向错误对象的指针.
 @return 是否成功
 */
+ (BOOL)deleteItem:(CSKeychainItem *)item error:(NSError **)error;
+ (BOOL)deleteItem:(CSKeychainItem *)item;


/**
 找到钥匙串中的item

 @param item    要查找的item
 @param error   在查找时,指向错误对象的指针.
 @return 一个 item 或者 nil
 */
+ (nullable CSKeychainItem *)selectOneItem:(CSKeychainItem *)item error:(NSError **)error;
+ (nullable CSKeychainItem *)selectOneItem:(CSKeychainItem *)item;


/**
 查询找到所有相匹配的item

 @param item 查询的item
 @param error   在查找时,指向错误对象的指针.
 @return CSKeychainItem数组
 */
+ (nullable NSArray<CSKeychainItem *> *)selectItems:(CSKeychainItem *)item error:(NSError **)error;
+ (nullable NSArray<CSKeychainItem *> *)selectItems:(CSKeychainItem *)item;

@end

/**
 包装钥匙串 item/查询.
 */
@interface CSKeychainItem : NSObject <NSCopying>

@property (nullable, nonatomic, copy) NSString *service; ///< kSecAttrService
@property (nullable, nonatomic, copy) NSString *account; ///< kSecAttrAccount
@property (nullable, nonatomic, copy) NSData *passwordData; ///< kSecValueData
@property (nullable, nonatomic, copy) NSString *password; ///< shortcut for `passwordData`
@property (nullable, nonatomic, copy) id <NSCoding> passwordObject; ///< shortcut for `passwordData`

@property (nullable, nonatomic, copy) NSString *label; ///< kSecAttrLabel
@property (nullable, nonatomic, copy) NSNumber *type; ///< kSecAttrType (FourCC)
@property (nullable, nonatomic, copy) NSNumber *creater; ///< kSecAttrCreator (FourCC)
@property (nullable, nonatomic, copy) NSString *comment; ///< kSecAttrComment
@property (nullable, nonatomic, copy) NSString *descr; ///< kSecAttrDescription
@property (nullable, nonatomic, readonly, strong) NSDate *modificationDate; ///< kSecAttrModificationDate
@property (nullable, nonatomic, readonly, strong) NSDate *creationDate; ///< kSecAttrCreationDate
@property (nullable, nonatomic, copy) NSString *accessGroup; ///< kSecAttrAccessGroup

@property (nonatomic) CSKeychainAccessible accessible; ///< kSecAttrAccessible
@property (nonatomic) CSKeychainQuerySynchronizationMode synchronizable NS_AVAILABLE_IOS(7_0); ///< kSecAttrSynchronizable

@end


NS_ASSUME_NONNULL_END
