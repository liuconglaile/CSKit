//
//  NSURLSession+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (Extended)

+ (NSURLSession *)sessionWithDelegate:(id<NSURLSessionDelegate>)delegate;

@end
