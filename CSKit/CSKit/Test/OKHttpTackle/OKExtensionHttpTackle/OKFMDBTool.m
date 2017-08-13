//
//  CCFMDBTool.m
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright (c) 2015年 Chehu. All rights reserved.
//

#import "OKFMDBTool.h"
#import "FMDB.h"

/** 数据库名称 */
#define AppFMDBName                      @"HttpDemo.sqlite"

//=============版本的数据库表名===============
#define OKJsonData_Table                 @"OKJsonData_Table"                /** 保存应用所有接口返回的json数据表*/
#define OKAppGlobalInfoManager_Table     @"OKAppGlobalInfoManager_Table"    /** 保存应用常用数据(版本信息等)表*/
#define OKTempInfoModel_Table            @"OKTempInfoModel_Table"           /** 保存临时数据*/

@implementation OKFMDBTool

static FMDatabase *_db;

/**
 *  初始化数据库
 */
+ (void)initialize
{
    [self initFMDB];
}

/**
 *  初始化数据库
 */
+ (void)initFMDB
{
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:AppFMDBName];
    
    // 1.打开数据库
    _db = [FMDatabase databaseWithPath:file];
    if (![_db open]) return;
    
    // 2.创建json数据表
    [_db executeUpdate:@"create table if not exists OKJsonData_Table (id integer PRIMARY KEY,jsonkey text NOT NULL,jsonData blob  NOT NULL)"];
    
    // 3.创建常用数据表
    [_db executeUpdate:@"create table if not exists OKAppGlobalInfoManager_Table (id integer PRIMARY KEY, appGlobalInfo blob NOT NULL, userID text NOT NULL);"];
    
    // 4.创建临时数据表
    [_db executeUpdate:@"create table if not exists OKTempInfoModel_Table (id INT PRIMARY KEY ,tempInfo blob NOT NULL, userID text NOT NULL)"];
}

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
+ (BOOL)saveDataToDB:(id)data byObjectId:(NSString *)objectId toTable:(DBNameType)tableNameType
{
    if (tableNameType == JsonDataTableType) {
        
        [_db executeUpdate:@"DELETE FROM OKJsonData_Table WHERE jsonkey = ?",objectId];
        BOOL isOK = [_db executeUpdate:@"insert into OKJsonData_Table (jsonkey,jsonData) values (?,?)", objectId, data];
        NSLog(@"保存 JsonData_Table 到数据库是否成功: %d",isOK);
        return isOK;
        
        
    } else if (tableNameType == AppGlobalInfoTableType) {
        
        [_db executeUpdateWithFormat:@"DELETE FROM OKAppGlobalInfoManager_Table WHERE userID = %@;" ,objectId];
        
        NSData *globalManagerData = [NSKeyedArchiver archivedDataWithRootObject:data];
        BOOL isOK = [_db executeUpdateWithFormat:@"INSERT INTO OKAppGlobalInfoManager_Table (appGlobalInfo, userID) VALUES(%@, %@);", globalManagerData, objectId];
        NSLog(@"保存 AppGlobalInfoTable 到数据库是否成功: %d==%@",isOK,data);
        return isOK;
        
        
    } else if (tableNameType == TempInfoTableType) {
        
        [_db executeUpdateWithFormat:@"DELETE FROM OKTempInfoModel_Table WHERE userID = %@;" ,objectId];
        
        NSData *tempBrandTableData = [NSKeyedArchiver archivedDataWithRootObject:data];
        BOOL isOK = [_db executeUpdateWithFormat:@"INSERT INTO OKTempInfoModel_Table (tempInfo, userID) VALUES(%@, %@);", tempBrandTableData, objectId];
        NSLog(@"保存 TempBrandTable 到数据库是否成功: %d==%@",isOK,tempBrandTableData);
        return isOK;
    }
    return NO;
}

#pragma mark - 获取数据操作

/**
 *  根据objectId获取相应表名的缓存数据
 *
 *  @param objectId      表键名
 *  @param tableNameType 表名枚举
 *
 *  @return 获取的数据库数据
 */
+ (id)getObjectById:(NSString *)objectId fromTable:(DBNameType)tableNameType
{
    FMResultSet *set = nil;
    if (tableNameType == JsonDataTableType) {
        set = [_db executeQuery:@"SELECT * FROM OKJsonData_Table WHERE jsonkey = ? ", objectId];
        
        //只有一行数据就用 if, 否则用 while
        if ([set next]) {
            NSData *jsonData = [set dataForColumn:@"jsonData"];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            return dic;
        }
        
    } else if (tableNameType == AppGlobalInfoTableType) {
        set = [_db executeQueryWithFormat:@"SELECT * FROM OKAppGlobalInfoManager_Table WHERE userID = %@;",objectId];
        
        //只有一行数据就用 if, 否则用 while
        if ([set next]) {
            NSObject *appGlobalManager = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"appGlobalInfo"]];
            return appGlobalManager;
        }
        
    } else if (tableNameType == TempInfoTableType) {
        set = [_db executeQueryWithFormat:@"SELECT * FROM OKTempInfoModel_Table WHERE userID = %@;",objectId];
        
        //只有一行数据就用 if, 否则用 while
        if ([set next]){
            NSObject *tempInfoModel = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"tempInfo"]];
            return tempInfoModel;
        }
    }
    return nil;
}


#pragma mark - 删除数据操作

/**
 *  根据objectId删除相应表名的单条缓存数据
 *
 *  @param objectId      表键名
 *  @param tableNameType 表名枚举
 *
 *  @return 是否删除成功
 */
+ (BOOL)removeDataByKey:(NSString *)objectId fromTable:(DBNameType)tableNameType
{
    if (tableNameType == JsonDataTableType) {
        BOOL isOK = [_db executeUpdate:@"DELETE FROM OKJsonData_Table WHERE jsonKey = ?",objectId];
        NSLog(@"删除jsonKey = %@  JsonDataTable 操作是否成功: %d",objectId,isOK);
        return isOK;
        
    } else if (tableNameType == AppGlobalInfoTableType) {
        BOOL isOK = [_db executeUpdateWithFormat:@"DELETE FROM OKAppGlobalInfoManager_Table WHERE userID = %@;" ,objectId];
        NSLog(@"删除userID = %@  AppGlobalInfoTableType 操作是否成功: %d",objectId,isOK);
        return isOK;
        
    } else if (tableNameType == TempInfoTableType) {
        BOOL isOK = [_db executeUpdateWithFormat:@"DELETE FROM OKTempInfoModel_Table WHERE userID = %@;" ,objectId];
        NSLog(@"删除userID = %@  TempInfoTableType 操作是否成功: %d",objectId,isOK);
        return isOK;
    }
    return NO;
}


#pragma mark - 删除所有数据数据操作

/**
 *  删除相应表名的所有缓存数据
 *
 *  @param tableNameType 表名枚举
 *
 *  @return 是否删除所有数据成功
 */
+ (BOOL)removeAllDataFromTable:(DBNameType)tableNameType
{
    if (tableNameType == JsonDataTableType) {
        BOOL isOK = [_db executeUpdate:@"DELETE FROM OKJsonData_Table"];
        NSLog(@"删除所有  JsonDataTable 操作是否成功: %d",isOK);
        return isOK;
        
    } else if (tableNameType == AppGlobalInfoTableType) {
        BOOL isOK = [_db executeUpdateWithFormat:@"DELETE FROM OKAppGlobalInfoManager_Table"];
        NSLog(@"删除所有  AppGlobalInfoTable 操作是否成功: %d",isOK);
        return isOK;
        
    } else if (tableNameType == TempInfoTableType) {
        BOOL isOK = [_db executeUpdateWithFormat:@"DELETE FROM OKTempInfoModel_Table"];
        NSLog(@"删除所有 TempBrandTable 操作是否成功: %d",isOK);
        return isOK;
    }
    return NO;
}

@end
