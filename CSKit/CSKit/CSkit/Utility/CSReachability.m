//
//  CSReachability.m
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSReachability.h"
#import <objc/message.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>



static CSReachabilityStatus CSReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags, BOOL allowWWAN) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return CSReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
        (flags & kSCNetworkReachabilityFlagsTransientConnection)) {
        return CSReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) && allowWWAN) {
        return CSReachabilityStatusWWAN;
    }
    
    return CSReachabilityStatusWiFi;
}

static void CSReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    CSReachability *self = ((__bridge CSReachability *)info);
    if (self.notifyBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notifyBlock(self);
        });
    }
}



@interface CSReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef ref;
@property (nonatomic, assign) BOOL scheduled;
@property (nonatomic, assign) BOOL allowWWAN;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

@end

@implementation CSReachability

+ (dispatch_queue_t)sharedQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.yykit.reachability", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (instancetype)init {
    /*
     请参阅Apple的连接状态实现和自述:
     地址0.0.0.0,哪个连接状态被视为特殊令牌.使其能够实际监控IPv4和IPv6两者的一般路由状态.
     https://developer.apple.com/library/ios/samplecode/Reachability/Listings/ReadMe_md.html#//apple_ref/doc/uid/DTS40007324-ReadMe_md-DontLinkElementID_11
     */
    struct sockaddr_in zero_addr;
    bzero(&zero_addr, sizeof(zero_addr));
    zero_addr.sin_len = sizeof(zero_addr);
    zero_addr.sin_family = AF_INET;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zero_addr);
    return [self initWithRef:ref];
}

- (instancetype)initWithRef:(SCNetworkReachabilityRef)ref {
    if (!ref) return nil;
    self = super.init;
    if (!self) return nil;
    _ref = ref;
    _allowWWAN = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        _networkInfo = [CTTelephonyNetworkInfo new];
    }
    return self;
}

- (void)dealloc {
    self.notifyBlock = nil;
    self.scheduled = NO;
    CFRelease(self.ref);
}

- (void)setScheduled:(BOOL)scheduled {
    if (_scheduled == scheduled) return;
    _scheduled = scheduled;
    if (scheduled) {
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        SCNetworkReachabilitySetCallback(self.ref, CSReachabilityCallback, &context);
        SCNetworkReachabilitySetDispatchQueue(self.ref, [self.class sharedQueue]);
    } else {
        SCNetworkReachabilitySetDispatchQueue(self.ref, NULL);
    }
}

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.ref, &flags);
    return flags;
}

- (CSReachabilityStatus)status {
    return CSReachabilityStatusFromFlags(self.flags, self.allowWWAN);
}

- (CSReachabilityWWANStatus)wwanStatus {
    if (!self.networkInfo) return CSReachabilityWWANStatusNone;
    NSString *status = self.networkInfo.currentRadioAccessTechnology;
    if (!status) return CSReachabilityWWANStatusNone;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{CTRadioAccessTechnologyGPRS : @(CSReachabilityWWANStatus2G),  // 2.5G   171Kbps
                CTRadioAccessTechnologyEdge : @(CSReachabilityWWANStatus2G),  // 2.75G  384Kbps
                CTRadioAccessTechnologyWCDMA : @(CSReachabilityWWANStatus3G), // 3G     3.6Mbps/384Kbps
                CTRadioAccessTechnologyHSDPA : @(CSReachabilityWWANStatus3G), // 3.5G   14.4Mbps/384Kbps
                CTRadioAccessTechnologyHSUPA : @(CSReachabilityWWANStatus3G), // 3.75G  14.4Mbps/5.76Mbps
                CTRadioAccessTechnologyCDMA1x : @(CSReachabilityWWANStatus3G), // 2.5G
                CTRadioAccessTechnologyCDMAEVDORev0 : @(CSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevA : @(CSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevB : @(CSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyeHRPD : @(CSReachabilityWWANStatus3G),
                CTRadioAccessTechnologyLTE : @(CSReachabilityWWANStatus4G)}; // LTE:3.9G 150M/75M  LTE-Advanced:4G 300M/150M
    });
    NSNumber *num = dic[status];
    if (num) return num.unsignedIntegerValue;
    else return CSReachabilityWWANStatusNone;
}

- (BOOL)isReachable {
    return self.status != CSReachabilityStatusNone;
}

+ (instancetype)reachability {
    return self.new;
}

+ (instancetype)reachabilityForLocalWifi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    CSReachability *one = [self reachabilityWithAddress:(const struct sockaddr *)&localWifiAddress];
    one.allowWWAN = NO;
    return one;
}

+ (instancetype)reachabilityWithHostname:(NSString *)hostname {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    return [[self alloc] initWithRef:ref];
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    return [[self alloc] initWithRef:ref];
}

- (void)setNotifyBlock:(void (^)(CSReachability *reachability))notifyBlock {
    _notifyBlock = [notifyBlock copy];
    self.scheduled = (self.notifyBlock != nil);
}

@end
