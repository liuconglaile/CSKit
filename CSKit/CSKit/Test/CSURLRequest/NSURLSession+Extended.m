//
//  NSURLSession+Extended.m
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "NSURLSession+Extended.h"

@implementation NSURLSession (Extended)

+ (NSURLSession *)sessionWithDelegate:(id<NSURLSessionDelegate>)delegate{
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    
    NSURLSessionConfiguration* defaultSession = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultSession
                                                          delegate:delegate
                                                     delegateQueue:operationQueue];
    
    return session;
}

@end
