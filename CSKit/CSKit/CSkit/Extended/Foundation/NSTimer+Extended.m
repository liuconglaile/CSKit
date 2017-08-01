//
//  NSTimer+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSTimer+Extended.h"
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(NSTimer_Extended)


@interface CSPltTimerTarget : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation CSPltTimerTarget

- (void)pltTimerTargetAction:(NSTimer *)timer
{
    if (self.target) {
        [self.target performSelector:self.selector withObject:timer afterDelay:0.0];
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end



@implementation NSTimer (Extended)

+ (void)_cs_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_cs_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(_cs_ExecBlock:) userInfo:[block copy] repeats:repeats];
}


+ (instancetype)pltScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo
{
    CSPltTimerTarget *timerTarget = [[CSPltTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti target:timerTarget selector:@selector(pltTimerTargetAction:) userInfo:userInfo repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    timerTarget.timer = timer;
    return timerTarget.timer;
}


@end


