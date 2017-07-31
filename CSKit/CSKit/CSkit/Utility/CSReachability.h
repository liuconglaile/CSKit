//
//  CSReachability.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
NS_ASSUME_NONNULL_BEGIN



/**
 网络连接状态
 
 - CSReachabilityStatusNone: 无连接
 - CSReachabilityStatusWWAN: WWAN连接 (2G/3G/4G)
 - CSReachabilityStatusWiFi: WIFI连接
 */
typedef NS_ENUM(NSUInteger, CSReachabilityStatus) {
    CSReachabilityStatusNone  = 0,
    CSReachabilityStatusWWAN  = 1,
    CSReachabilityStatusWiFi  = 2,
};


/**
 WWAN连接状态
 
 - CSReachabilityWWANStatusNone: 不是WWAN连接
 - CSReachabilityWWANStatus2G: 2G (GPRS/EDGE)       10~100Kbps
 - CSReachabilityWWANStatus3G: 3G (WCDMA/HSDPA/...) 1~10Mbps
 - CSReachabilityWWANStatus4G: 4G (eHRPD/LTE)       100Mbps
 */
typedef NS_ENUM(NSUInteger, CSReachabilityWWANStatus) {
    CSReachabilityWWANStatusNone  = 0,
    CSReachabilityWWANStatus2G = 2,
    CSReachabilityWWANStatus3G = 3,
    CSReachabilityWWANStatus4G = 4,
};




/**
 CSReachability可以用来监视iOS设备的网络状态
 */
@interface CSReachability : NSObject

@property (nonatomic, readonly) SCNetworkReachabilityFlags flags;                           ///< Current flags.
@property (nonatomic, readonly) CSReachabilityStatus status;                                ///< Current status.
@property (nonatomic, readonly) CSReachabilityWWANStatus wwanStatus NS_AVAILABLE_IOS(7_0);  ///< Current WWAN status.
@property (nonatomic, readonly, getter=isReachable) BOOL reachable;                         ///< Current reachable status.

/// 网络更改时通知主线程将被调用.
@property (nullable, nonatomic, copy) void (^notifyBlock)(CSReachability *reachability);

/// 创建一个对象来检查默认路由的连接状态.
+ (instancetype)reachability;

/// 创建一个对象来检查本地WI-FI的连接状态.
+ (instancetype)reachabilityForLocalWifi DEPRECATED_MSG_ATTRIBUTE("unnecessary and potentially harmful");

/// 创建一个对象来检查给定主机名的连接.
+ (nullable instancetype)reachabilityWithHostname:(NSString *)hostname;

/**
 创建一个对象来检查给定IP地址的连接状态
 
 @param hostAddress 您可以为IPv4地址传递'struct sockaddr_in'或为IPv6地址传递'struct sockaddr_in6'
 @return 检查连接状态的对象
 */
+ (nullable instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

@end
NS_ASSUME_NONNULL_END



