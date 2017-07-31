//
//  NSSet+Utilities.h
//  CSCategory
//
//  Created by mac on 17/5/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Utilities)

- (void)each:(void (^)(id))block;
- (void)eachWithIndex:(void (^)(id, int))block;
- (NSArray *)map:(id (^)(id object))block;
- (NSArray *)select:(BOOL (^)(id object))block;
- (NSArray *)reject:(BOOL (^)(id object))block;
- (NSArray *)sort;
- (id)reduce:(id(^)(id accumulator, id object))block;
- (id)reduce:(id)initial withBlock:(id(^)(id accumulator, id object))block;

@end
