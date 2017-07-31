//
//  NSKeyedUnarchiver+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSKeyedUnarchiver+Extended.h"
#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(NSKeyedUnarchiver_Extended)

@implementation NSKeyedUnarchiver (Extended)

+ (id)unarchiveObjectWithData:(NSData *)data exception:(__autoreleasing NSException **)exception {
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *e)
    {
        if (exception) *exception = e;
    }
    @finally
    {
    }
    return object;
}

+ (id)unarchiveObjectWithFile:(NSString *)path exception:(__autoreleasing NSException **)exception {
    id object = nil;
    
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *e)
    {
        if (exception) *exception = e;
    }
    @finally
    {
    }
    return object;
}

@end
