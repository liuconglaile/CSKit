//
//  UIDevice+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Extended)


///MARK:=============================================================================
///MARK:设备信息
///MARK:=============================================================================
/// 设备系统版本 (e.g. 8.1)
+ (double)systemVersion;

/// 设备是否 iPad/iPad mini.
@property (nonatomic, readonly) BOOL isPad;

///该设备是否是模拟器.
@property (nonatomic, readonly) BOOL isSimulator;

/// 设备是否越狱.
@property (nonatomic, readonly) BOOL isJailbroken;

/// 设备是否可以打电话.
@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// 设备的机器型号.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModel;

/// 设备的机器型号名称. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModelName;

/// 系统的启动时间.
@property (nonatomic, readonly) NSDate *systemUptime;



///MARK:=============================================================================
///MARK:网络信息
///MARK:=============================================================================
/// 该设备的WiFi IP地址(可以为nil). e.g. @"192.168.1.111"
@property (nullable, nonatomic, readonly) NSString *ipAddressWIFI;

/// Cell设备的IP地址(可以为nil). e.g. @"10.2.2.222"
@property (nullable, nonatomic, readonly) NSString *ipAddressCell;


/**
 网络流量类型:
 
 WWAN: 无线广域网.
 例如: 3G/4G.
 
 WIFI: Wi-Fi.
 
 AWDL: Apple Wireless Direct Link (苹果无线直接链接-等网络连接).
 例如: AirDrop, AirPlay, GameKit.
 */
typedef NS_OPTIONS(NSUInteger, CSNetworkTrafficType) {
    CSNetworkTrafficTypeWWANSent     = 1 << 0,
    CSNetworkTrafficTypeWWANReceived = 1 << 1,
    CSNetworkTrafficTypeWIFISent     = 1 << 2,
    CSNetworkTrafficTypeWIFIReceived = 1 << 3,
    CSNetworkTrafficTypeAWDLSent     = 1 << 4,
    CSNetworkTrafficTypeAWDLReceived = 1 << 5,
    
    CSNetworkTrafficTypeWWAN = CSNetworkTrafficTypeWWANSent | CSNetworkTrafficTypeWWANReceived,
    CSNetworkTrafficTypeWIFI = CSNetworkTrafficTypeWIFISent | CSNetworkTrafficTypeWIFIReceived,
    CSNetworkTrafficTypeAWDL = CSNetworkTrafficTypeAWDLSent | CSNetworkTrafficTypeAWDLReceived,
    
    CSNetworkTrafficTypeALL = CSNetworkTrafficTypeWWAN |
    CSNetworkTrafficTypeWIFI |
    CSNetworkTrafficTypeAWDL,
};


/**
 获取设备网络流量字节(使用示例1-1)

 @param types 流量类型
 @return 字节计数器
 */
- (uint64_t)getNetworkTrafficBytes:(CSNetworkTrafficType)types;



///MARK:=============================================================================
///MARK:磁盘空间
///MARK:=============================================================================
/// 总磁盘空间以字节为单位. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t diskSpace;

/// 以字节为单位的可用磁盘空间. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t diskSpaceFree;

/// 以字节为单位的磁盘空间. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t diskSpaceUsed;


///MARK:=============================================================================
///MARK:内存信息
///MARK:=============================================================================
/// 总物理内存以字节为单位. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryTotal;

/// 以字节为单位使用(主动+无效+有线)存储器. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryUsed;

/// 空闲内存字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryFree;

/// 活动内存字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryActive;

/// 非活动内存字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryInactive;

/// 有线内存字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryWired;

/// 可清除内存的字节. (发生错误时返回 -1)
@property (nonatomic, readonly) int64_t memoryPurgable;


///MARK:=============================================================================
///MARK:CPU信息
///MARK:=============================================================================

/// 可用的CPU处理器数.
@property (nonatomic, readonly) NSUInteger cpuCount;

/// 当前CPU使用率,1.0表示100％. (发生错误时返回 -1)
@property (nonatomic, readonly) float cpuUsage;

/// 每个处理器的当前CPU使用量(NSNumber数组),1.0表示100％. (发生错误时为nil)
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;








/**
 密码状态枚举
 
 - CSPasscodeStatusUnknown: 密码状态不明
 - CSPasscodeStatusEnabled: 密码已启用
 - CSPasscodeStatusDisabled: 密码被禁用
 */
typedef NS_ENUM(NSUInteger, CSPasscodeStatus) {
    
    CSPasscodeStatusUnknown   = 0,
    CSPasscodeStatusEnabled   = 1,
    CSPasscodeStatusDisabled  = 2
};


/**
 确定是否该设备支持'密码Status`检查。密码校验只支持iOS 8.
 */
@property (readonly) BOOL passcodeStatusSupported;


/**
 检查并返回设备的当前状态密码.
 如果`passcodeStatusSupported`返回NO然后`LNPasscodeStatusUnknown`将被退回.
 
 */
@property (readonly) CSPasscodeStatus passcodeStatus;





@end


NS_ASSUME_NONNULL_END


/** 系统版本 */
#ifndef kSystemVersion
#define kSystemVersion [UIDevice systemVersion]
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif

#ifndef kiOS10Later
#define kiOS10Later (kSystemVersion >= 10)
#endif


///MARK: 使用示例1-1
/**

 @discussion 这是设备上次启动时间以来的一个计数器.
 用法:
 
 uint64_t bytes = [[UIDevice currentDevice] getNetworkTrafficBytes:YYNetworkTrafficTypeALL];
 NSTimeInterval time = CACurrentMediaTime();
 
 uint64_t bytesPerSecond = (bytes - _lastBytes) / (time - _lastTime);
 
 _lastBytes = bytes;
 _lastTime = time;
 
 */

