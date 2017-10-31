//
//  CSURLResponse.m
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSURLResponse.h"

@implementation CSURLResponse

- (instancetype)initWithData:(NSData *)rdata withResponse:(NSHTTPURLResponse *)rresponse withError:(NSError*)eerror{
    
    self = [super init];
    if (self){
        self.responsedata = rdata;
        self.response = rresponse;
        self.error = eerror;
    }
    return self;
}

@end
