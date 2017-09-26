//
//  UIApplication+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIApplication+Extended.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <stdatomic.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
//Import required frameworks
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <EventKit/EKEventStore.h>

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>
#import <CSkit/NSArray+Extended.h>
#import <CSkit/NSObject+Extended.h>
#import <CSkit/UIDevice+Extended.h>
#else
#import "CSMacrosHeader.h"
#import "NSArray+Extended.h"
#import "NSObject+Extended.h"
#import "UIDevice+Extended.h"
#endif



CSSYNTH_DUMMY_CLASS(UIApplication_Extended)

#define kNetworkIndicatorDelay (1/30.0)
@interface _CSUIApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation _CSUIApplicationNetworkIndicatorInfo
@end



typedef void (^CSLocationSuccessCallback)(void);
typedef void (^CSLocationFailureCallback)(void);

static char CSPermissionsLocationManagerPropertyKey;
static char CSPermissionsLocationBlockSuccessPropertyKey;
static char CSPermissionsLocationBlockFailurePropertyKey;


@interface UIApplication () <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *permissionsLocationManager;
@property (nonatomic, copy) CSLocationSuccessCallback locationSuccessCallbackProperty;
@property (nonatomic, copy) CSLocationFailureCallback locationFailureCallbackProperty;
@end


@implementation UIApplication (Extended)

static CGRect __keyboardFrame = (CGRect){ (CGPoint){ 0.0f, 0.0f }, (CGSize){ 0.0f, 0.0f } };
static volatile int32_t numberOfActiveNetworkConnectionsxxx;

+ (void)load
{
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         __keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
     }];
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         __keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
     }];
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         __keyboardFrame = CGRectZero;
     }];
}


///MARK: ==================================================================
///MARK: 应用相关
///MARK: ==================================================================

- (NSURL *)documentsURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)cachesURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)libraryURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)libraryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

- (BOOL)isPirated {
    if ([[UIDevice currentDevice] isSimulator]) return YES; // 模拟器不是来自AppStore
    
    if (getgid() <= 10) return YES; // 进程ID不应该是root
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }
    
    if (![self _cs_fileExistInMainBundle:@"_CodeSignature"]) {
        return YES;
    }
    
    if (![self _cs_fileExistInMainBundle:@"SC_Info"]) {
        return YES;
    }
    
    //如果有人真的想破解你的应用程序,这种方法是无用的
    //您可以更改此方法的名称,加密代码并进行更多检查...
    return NO;
}

- (BOOL)_cs_fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (BOOL)isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID; name[3] = getpid();
    
    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) {
        return ret != 0;
    }
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

- (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

- (float)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

CSSYNTH_DYNAMIC_PROPERTY_OBJECT(networkActivityInfo,
                                setNetworkActivityInfo,
                                RETAIN_NONATOMIC,
                                _CSUIApplicationNetworkIndicatorInfo *);

- (void)_delaySetActivity:(NSTimer *)timer {
    NSNumber *visiable = timer.userInfo;
    if (self.networkActivityIndicatorVisible != visiable.boolValue) {
        [self setNetworkActivityIndicatorVisible:visiable.boolValue];
    }
    [timer invalidate];
}

- (void)_changeNetworkActivityCount:(NSInteger)delta {
    @synchronized(self){
        dispatch_async_on_main_queue(^{
            _CSUIApplicationNetworkIndicatorInfo *info = [self networkActivityInfo];
            if (!info) {
                info = [_CSUIApplicationNetworkIndicatorInfo new];
                [self setNetworkActivityInfo:info];
            }
            NSInteger count = info.count;
            count += delta;
            info.count = count;
            [info.timer invalidate];
            info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}

- (NSString *)applicationSize {
    unsigned long long docSize   =  [self sizeOfFolder:[self documentsPath]];
    unsigned long long libSize   =  [self sizeOfFolder:[self libraryPath]];
    unsigned long long cacheSize =  [self sizeOfFolder:[self cachesPath]];
    
    unsigned long long total = docSize + libSize + cacheSize;
    
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}



- (unsigned long long)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}




- (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}

+ (BOOL)isAppExtension {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
    return isAppExtension;
}

+ (UIApplication *)sharedExtensionApplication {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return [self isAppExtension] ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}
///MARK: ==================================================================
///MARK: 应用相关
///MARK: ==================================================================









///MARK: ==================================================================
///MARK: 键盘处理
///MARK: ==================================================================
/** 获取键盘 Frame */
- (CGRect)keyboardFrame{
    return __keyboardFrame;
}
/** 消除键盘 */
- (void)dismissKeyboard{
    
    [[UIApplication sharedApplication] sendAction:@selector(dismiss) to:nil from:nil forEvent:nil];
    
}
- (void)dismiss{
    
}
///MARK: ==================================================================
///MARK: 键盘处理
///MARK: ==================================================================




///MARK: ==================================================================
///MARK: 网络活动
///MARK: ==================================================================
- (void)beganNetworkActivity
{
    self.networkActivityIndicatorVisible = OSAtomicAdd32(1, &numberOfActiveNetworkConnectionsxxx) > 0;
}

- (void)endedNetworkActivity
{
    self.networkActivityIndicatorVisible = OSAtomicAdd32(-1, &numberOfActiveNetworkConnectionsxxx) > 0;
}
///MARK: ==================================================================
///MARK: 网络活动
///MARK: ==================================================================






///MARK: ==================================================================
///MARK: 检查权限
///MARK: ==================================================================
-(CSPermissionAccess)hasAccessToBluetoothLE {
    switch ([[[CBCentralManager alloc] init] state]) {
        case CBCentralManagerStateUnsupported:
            return CSPermissionAccessUnsupported;
            break;
            
        case CBCentralManagerStateUnauthorized:
            return CSPermissionAccessDenied;
            break;
            
        default:
            return CSPermissionAccessGranted;
            break;
    }
}

-(CSPermissionAccess)hasAccessToCalendar {
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
        case EKAuthorizationStatusAuthorized:
            return CSPermissionAccessGranted;
            break;
            
        case EKAuthorizationStatusDenied:
            return CSPermissionAccessDenied;
            break;
            
        case EKAuthorizationStatusRestricted:
            return CSPermissionAccessRestricted;
            break;
            
        default:
            return CSPermissionAccessUnknown;
            break;
    }
}

-(CSPermissionAccess)hasAccessToContacts {
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            return CSPermissionAccessGranted;
            break;
            
        case kABAuthorizationStatusDenied:
            return CSPermissionAccessDenied;
            break;
            
        case kABAuthorizationStatusRestricted:
            return CSPermissionAccessRestricted;
            break;
            
        default:
            return CSPermissionAccessUnknown;
            break;
    }
}

-(CSPermissionAccess)hasAccessToLocation {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return CSPermissionAccessGranted;
            break;
            
        case kCLAuthorizationStatusDenied:
            return CSPermissionAccessDenied;
            break;
            
        case kCLAuthorizationStatusRestricted:
            return CSPermissionAccessRestricted;
            break;
            
        default:
            return CSPermissionAccessUnknown;
            break;
    }
    return CSPermissionAccessUnknown;
}

-(CSPermissionAccess)hasAccessToPhotos {
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized:
            return CSPermissionAccessGranted;
            break;
            
        case ALAuthorizationStatusDenied:
            return CSPermissionAccessDenied;
            break;
            
        case ALAuthorizationStatusRestricted:
            return CSPermissionAccessRestricted;
            break;
            
        default:
            return CSPermissionAccessUnknown;
            break;
    }
}

-(CSPermissionAccess)hasAccessToReminders {
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusAuthorized:
            return CSPermissionAccessGranted;
            break;
            
        case EKAuthorizationStatusDenied:
            return CSPermissionAccessDenied;
            break;
            
        case EKAuthorizationStatusRestricted:
            return CSPermissionAccessRestricted;
            break;
            
        default:
            return CSPermissionAccessUnknown;
            break;
    }
    return CSPermissionAccessUnknown;
}


#pragma mark - Request permissions
-(void)requestAccessToCalendarWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}

-(void)requestAccessToContactsWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if(addressBook) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    accessGranted();
                } else {
                    accessDenied();
                }
            });
        });
    }
}

-(void)requestAccessToMicrophoneWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    AVAudioSession *session = [[AVAudioSession alloc] init];
    [session requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}

-(void)requestAccessToMotionWithSuccess:(void(^)(void))accessGranted {
    CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [motionManager startActivityUpdatesToQueue:motionQueue withHandler:^(CMMotionActivity *activity) {
        accessGranted();
        [motionManager stopActivityUpdates];
    }];
}

-(void)requestAccessToPhotosWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        accessGranted();
    } failureBlock:^(NSError *error) {
        accessDenied();
    }];
}

-(void)requestAccessToRemindersWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                accessGranted();
            } else {
                accessDenied();
            }
        });
    }];
}


#pragma mark - Needs investigating
/*
 -(void)requestAccessToBluetoothLEWithSuccess:(void(^)())accessGranted {
 //REQUIRES DELEGATE - NEEDS RETHINKING
 }
 */

-(void)requestAccessToLocationWithSuccess:(void(^)(void))accessGranted andFailure:(void(^)(void))accessDenied {
    self.permissionsLocationManager = [[CLLocationManager alloc] init];
    self.permissionsLocationManager.delegate = self;
    
    self.locationSuccessCallbackProperty = accessGranted;
    self.locationFailureCallbackProperty = accessDenied;
    [self.permissionsLocationManager startUpdatingLocation];
}


#pragma mark - Location manager injection
-(CLLocationManager *)permissionsLocationManager {
    return objc_getAssociatedObject(self, &CSPermissionsLocationManagerPropertyKey);
}

-(void)setPermissionsLocationManager:(CLLocationManager *)manager {
    objc_setAssociatedObject(self, &CSPermissionsLocationManagerPropertyKey, manager, OBJC_ASSOCIATION_RETAIN);
}

-(CSLocationSuccessCallback)locationSuccessCallbackProperty {
    return objc_getAssociatedObject(self, &CSPermissionsLocationBlockSuccessPropertyKey);
}

-(void)setLocationSuccessCallbackProperty:(CSLocationSuccessCallback)locationCallbackProperty {
    objc_setAssociatedObject(self, &CSPermissionsLocationBlockSuccessPropertyKey, locationCallbackProperty, OBJC_ASSOCIATION_COPY);
}

-(CSLocationFailureCallback)locationFailureCallbackProperty {
    return objc_getAssociatedObject(self, &CSPermissionsLocationBlockFailurePropertyKey);
}

-(void)setJk_locationFailureCallbackProperty:(CSLocationFailureCallback)locationFailureCallbackProperty {
    objc_setAssociatedObject(self, &CSPermissionsLocationBlockFailurePropertyKey, locationFailureCallbackProperty, OBJC_ASSOCIATION_COPY);
}


#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationSuccessCallbackProperty();
    } else if (status != kCLAuthorizationStatusNotDetermined) {
        self.locationFailureCallbackProperty();
    }
}

///MARK: ==================================================================
///MARK: 检查权限
///MARK: ==================================================================


@end
