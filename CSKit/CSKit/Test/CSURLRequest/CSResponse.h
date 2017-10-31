//
//  CSResponse.h
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(CSUTF8)

- (NSString *)dataUTF8;

@end



/*普通请求回调*/
typedef void (^CSResponseBlock)(id response, BOOL isSuccess, NSInteger errorCode);


/**
 响应格式枚举

 - CSResponseTypeJSON:  json 响应格式
 - CSResponseTypeXML:  xml
 */
typedef NS_ENUM(NSInteger, CSResponseType){
    CSResponseTypeJSON = 0,
    CSResponseTypeXML
};


/**
 响应处理
 */
@interface CSResponse : NSObject

@property (nonatomic, assign)CSResponseType type;

- (id (^)(NSData *data))responseHandle;

@end

