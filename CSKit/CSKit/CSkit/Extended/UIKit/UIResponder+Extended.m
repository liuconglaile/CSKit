//
//  UIResponder+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIResponder+Extended.h"
static __weak id currentFirstResponder;

@implementation UIResponder (Extended)

/** 响应者链 */
- (NSString *)responderChainDescription
{
    NSMutableArray *responderChainStrings = [NSMutableArray array];
    [responderChainStrings addObject:[self class]];
    UIResponder *nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder])) {
        [responderChainStrings addObject:[nextResponder class]];
    }
    __block NSString *returnString = @"Responder Chain:\n";
    __block int tabCount = 0;
    [responderChainStrings enumerateObjectsWithOptions:NSEnumerationReverse
                                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                if (tabCount) {
                                                    returnString = [returnString stringByAppendingString:@"|"];
                                                    for (int i = 0; i < tabCount; i++) {
                                                        returnString = [returnString stringByAppendingString:@"----"];
                                                    }
                                                    returnString = [returnString stringByAppendingString:@" "];
                                                }
                                                else {
                                                    returnString = [returnString stringByAppendingString:@"| "];
                                                }
                                                returnString = [returnString stringByAppendingFormat:@"%@ (%@)\n", obj, @(idx)];
                                                tabCount++;
                                            }];
    return returnString;
}

/** 当前第一响应者 */
+ (id)currentFirstResponder {
    currentFirstResponder = nil;
    
    [[UIApplication sharedApplication] sendAction:@selector(findCurrentFirstResponder:) to:nil from:nil forEvent:nil];
    
    return currentFirstResponder;
}

- (void)findCurrentFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
