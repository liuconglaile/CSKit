//
//  CSURLResponse.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSURLResponse : NSObject

@property (nonatomic, copy, getter=getData) NSData * responsedata;
@property (nonatomic, copy, getter=getError) NSError * error;
@property (nonatomic, copy, getter=getResponse) NSHTTPURLResponse * response;

- (instancetype)initWithData:(NSData *)rdata withResponse:(NSHTTPURLResponse *)rresponse withError:(NSError*)eerror;

@end
