//
//  UIApplication+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 权限类型枚举
 
 - CSPermissionTypeBluetoothLE: 蓝牙权限
 - CSPermissionTypeCalendar: 日历权限
 - CSPermissionTypeContacts: 联系人权限
 - CSPermissionTypeLocation: 位置权限
 - CSPermissionTypeMicrophone: 麦克风权限
 - CSPermissionTypeMotion: 运动信息权限
 - CSPermissionTypePhotos: 相册权限
 - CSPermissionTypeReminders: 推送提醒权限
 */
typedef NS_ENUM(NSUInteger, CSPermissionType) {
    CSPermissionTypeBluetoothLE,
    CSPermissionTypeCalendar,
    CSPermissionTypeContacts,
    CSPermissionTypeLocation,
    CSPermissionTypeMicrophone,
    CSPermissionTypeMotion,
    CSPermissionTypePhotos,
    CSPermissionTypeReminders,
};



/**
 访问权限设置枚举
 
 - CSPermissionAccessDenied: 访问权限被拒绝
 - CSPermissionAccessGranted: 访问权限已允许
 - CSPermissionAccessRestricted: 访问权限被限制
 - CSPermissionAccessUnknown: 访问权限未知
 - CSPermissionAccessUnsupported: 访问权限不支持
 - CSPermissionAccessMissingFramework: 访问权限缺少框架
 */
typedef NS_ENUM(NSUInteger, CSPermissionAccess) {
    CSPermissionAccessDenied,
    CSPermissionAccessGranted,
    CSPermissionAccessRestricted,
    CSPermissionAccessUnknown,
    CSPermissionAccessUnsupported,
    CSPermissionAccessMissingFramework
};



@interface UIApplication (Extended)

/// 此应用程序沙箱中的'Documents文档'文件夹.
@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

/// 此应用程序沙箱中的'Caches缓存'文件夹
@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

/// 此应用程序沙箱中的'Library文库'文件夹.
@property (nonatomic, readonly) NSURL *libraryURL;
@property (nonatomic, readonly) NSString *libraryPath;

/// 应用程序的捆绑名称(在SpringBoard中显示).
@property (nullable, nonatomic, readonly) NSString *appBundleName;

/// 应用程序的Bundle ID. 例如'com.ibireme.CSKit'
@property (nullable, nonatomic, readonly) NSString *appBundleID;

/// 应用程序的版本.例如'1.2.0'
@property (nullable, nonatomic, readonly) NSString *appVersion;

/// 应用程序的版本号.例如'123'
@property (nullable, nonatomic, readonly) NSString *appBuildVersion;

/// 这个程序是否被盗版 (不是从苹果商店里安装的).
@property (nonatomic, readonly) BOOL isPirated;

/// 该程序是否正在调试(调试器附件).
@property (nonatomic, readonly) BOOL isBeingDebugged;

/// 程序运行实际使用内存字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryUsage;

/// 当前线程CPU使用率,1.0表示100％.(发生错误时为-1)
@property (nonatomic, readonly) float cpuUsage;


/**
 递增活动的网络请求数.如果这个数字在递增前为0,这将开始状态栏网络活动指示符动画.这种方法是线程安全的.
 此方法在App Extension中无效.
 */
- (void)incrementNetworkActivityCount;

/** 获取应用大小 */
- (NSString *)applicationSize;

/**
 减少活动网络请求的数量.如果此数字在递减后变为0,这将停止状态栏网络活动指示器动画.这种方法是线程安全的.
 此方法在App Extension中无效.
 */
- (void)decrementNetworkActivityCount;


/// 在App Extension中返回YES.
+ (BOOL)isAppExtension;

/// 与sharedApplication(共享应用程序)相同,但在App Extension中返回无效.
+ (nullable UIApplication *)sharedExtensionApplication;

/** 获取键盘 Frame */
- (CGRect)keyboardFrame;
/** 消除键盘 */
- (void)dismissKeyboard;

/** 开始网络活动 */
- (void)beganNetworkActivity;
/** 结束网络活动指示 */
- (void)endedNetworkActivity;


//检查服务的许可.无法检查麦克风或运动而不要求用户许可
-(CSPermissionAccess)hasAccessToBluetoothLE;
-(CSPermissionAccess)hasAccessToCalendar;
-(CSPermissionAccess)hasAccessToContacts;
-(CSPermissionAccess)hasAccessToLocation;
-(CSPermissionAccess)hasAccessToPhotos;
-(CSPermissionAccess)hasAccessToReminders;

//MARK:有回调要求许可

/* 请求访问日历 */
-(void)requestAccessToCalendarWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;
/* 请求访问联系人 */
-(void)requestAccessToContactsWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;
/* 请求访问麦克风 */
-(void)requestAccessToMicrophoneWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;
/* 请求访问照片 */
-(void)requestAccessToPhotosWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;
/* 请求打开提醒推送 */
-(void)requestAccessToRemindersWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;

//MARK:实例方法
/* 请求访问定位 */
-(void)requestAccessToLocationWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied;

//无故障回调
/* 请求访问运动 */
-(void)requestAccessToMotionWithSuccess:(void(^)(void))accessGranted;

//Needs investigating - unsure whether it can be implemented because of required delegate callbacks
//-(void)requestAccessToBluetoothLEWithSuccess:(void(^)())accessGranted;


@end

NS_ASSUME_NONNULL_END

