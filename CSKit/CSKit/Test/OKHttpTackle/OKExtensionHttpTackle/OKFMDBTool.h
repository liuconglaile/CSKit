//
//  CCFMDBTool.h
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright (c) 2015年 Chehu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JsonDataTableType,      //每个请求的网络数据的数据库表
    AppGlobalInfoTableType, //全局单例对象数据库表
    TempInfoTableType,      //临时缓存数据库表
} DBNameType; //数据库表类型


@interface OKFMDBTool : NSObject

/**
 *  初始化数据库
 */
+ (void)initFMDB;


#pragma mark - 保存数据操作

/**
 *  根据objectId保存相应表名的缓存数据
 *
 *  @param data          要保存的数据, 支持对象类型
 *  @param objectId      表键名
 *  @param tableNameType 表名枚举
 *
 *  @return 是否保存成
 */
+ (BOOL)saveDataToDB:(id)data byObjectId:(NSString *)objectId toTable:(DBNameType)tableNameType;


#pragma mark - 获取数据操作

/**
 *  根据objectId获取相应表名的缓存数据
 *
 *  @param objectId      表键名
 *  @param tableNameType 表名枚举
 *
 *  @return 获取的数据库数据
 */
+ (id)getObjectById:(NSString *)objectId fromTable:(DBNameType)tableNameType;


#pragma mark - 删除某条数据操作
/**
 *  根据objectId删除相应表名的单条缓存数据
 *
 *  @param objectId      表键名
 *  @param tableNameType 表名枚举
 *
 *  @return 是否删除成功
 */
+ (BOOL)removeDataByKey:(NSString *)objectId fromTable:(DBNameType)tableNameType;


#pragma mark - 删除所有数据数据操作
/**
 *  删除相应表名的所有缓存数据
 *
 *  @param tableNameType 表名枚举
 *
 *  @return 是否删除所有数据成功
 */
+ (BOOL)removeAllDataFromTable:(DBNameType)tableNameType;


@end
