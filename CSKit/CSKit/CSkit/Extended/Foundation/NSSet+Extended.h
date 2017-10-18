//
//  NSSet+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Extended)

- (void)each:(void (^)(id))block;
- (void)eachWithIndex:(void (^)(id, int))block;
- (NSArray *)map:(id (^)(id object))block;
- (NSArray *)select:(BOOL (^)(id object))block;
- (NSArray *)reject:(BOOL (^)(id object))block;
- (NSArray *)sort;
- (id)reduce:(id(^)(id accumulator, id object))block;
- (id)reduce:(id)initial withBlock:(id(^)(id accumulator, id object))block;

@end
