//
//  NSObject+Socket.h
//  CSCategory
//
//  Created by mac on 2017/5/27.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Socket)

+ (BOOL)sendSocketMsg:(NSString *)msg withIP:(NSString *)ip andPort:(NSInteger)port;
+ (NSString *)getSocketMsgFromIP:(NSString *)ip andPort:(NSInteger)port;

@end
