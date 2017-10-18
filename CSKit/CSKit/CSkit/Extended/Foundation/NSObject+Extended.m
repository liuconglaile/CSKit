//
//  NSObject+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+Extended.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <CommonCrypto/CommonCrypto.h>

/**
 在每个类别实现之前添加这个宏,所以我们不必使用  -all_load 或 -force_load 仅从静态库加载对象文件包含类别,没有类.
 更多信息: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 
 示例:
 CSSYNTH_DUMMY_CLASS(NSString_CSAdd)
 
 @param _name_ 类别名
 @return 添加的类别
 */
#ifndef CSSYNTH_DUMMY_CLASS
#define CSSYNTH_DUMMY_CLASS(_name_) \
@interface CSSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation CSSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif






/** 默认下载文件存储位置 */
#define DefaultKeyedArchiverPath @"%@/Library/Caches/DefaultKeyedArchiverPath"

CSSYNTH_DUMMY_CLASS(NSObject_Extended)





@implementation NSObject (Extended)



/**
 异步执行代码块
 
 @param block 代码块
 */
- (void)performAsynchronous:(void(^)(void))block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

/**
 GCD主线程执行代码块
 
 @param block 代码块
 @param shouldWait 是否同步请求
 */
- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)shouldWait {
    if (shouldWait) {
        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    else {
        // Asynchronous
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
/**
 延迟执行代码块
 
 @param seconds 延迟时间 秒
 @param block 代码块
 */
- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_current_queue(), block);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
    
}




/**
 用'NSKeyedArchiver'和'NSKeyedUnarchiver'返回实例的副本.如果发生错误,返回nil
 */
- (id)deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

/**
 使用archiver和unarchiver返回实例的副本.如果发生错误,返回nil.
 
 @param archiver   NSKeyedArchiver 类或继承类.
 @param unarchiver NSKeyedUnarchiver 类或继承类.
 */
- (id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver {
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}







/**
 归档
 
 @param obj 需要归档的对象
 @param key 归档时赋值的key
 @return 归档成功返回YES,否则NO
 */
+ (BOOL)keyedArchiver:(id)obj key:(NSString *)key
{
    //构建path
    BOOL creatSavePathSuccess = [self creatSavePath];
    if (creatSavePathSuccess)
    {
        return [self keyedArchiver:obj key:key path:[self getKeyedArchiverPath:key]];
    }
    else
    {
        return NO;
    }
}



/**
 归档(可指定路径)
 
 @param obj 需要归档的对象
 @param key 归档时赋值的key
 @param path 指定归档的路径
 @return 归档成功返回YES,否则NO
 */
+ (BOOL)keyedArchiver:(id)obj key:(NSString *)key path:(NSString *)path
{
    NSMutableData *tpData = [NSMutableData data];
    NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:tpData];
    [keyedArchiver encodeObject:obj forKey:key];
    [keyedArchiver finishEncoding];
    return [tpData writeToFile:path atomically:YES];
}


/**
 解档
 
 @param key 解档文件的key
 @return 解档对象,如出现错误则返回nil
 */
+ (id)keyedUnarchiver:(NSString *)key
{
    return [self keyedUnarchiver:key path:[self getKeyedArchiverPath:key]];
}


/**
 解档
 
 @param key 解档文件的key
 @param path 解档文件所在路径
 @return 解档对象,如出现错误则返回nil
 */
+ (id)keyedUnarchiver:(NSString *)key path:(NSString *)path
{
    NSMutableData *tpData = [NSMutableData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:tpData];
    return [keyedUnarchiver decodeObjectForKey:key];
}


+(NSString *)getKeyedArchiverPath:(NSString *)keyString
{
    
    ///加密一下路径
    NSString* md5String = [self md5StringWithData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *path = [NSString stringWithFormat:[NSString stringWithFormat:@"%@/%@",DefaultKeyedArchiverPath,md5String],NSHomeDirectory()];
    
    return path;NSError *error = nil;
    
    id value = [NSJSONSerialization JSONObjectWithData:[path dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error) {
        NSLog(@"jsonValueDecoded error:%@", error);
    }
    return value;
}
///NSData 转 MD5字符串
- (NSString *)md5StringWithData:(NSData*)aData {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(aData.bytes, (CC_LONG)aData.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



/**
 创建文件夹路径
 
 @return YES表示创建成功,NO表示创建失败
 */
+(BOOL)creatSavePath
{
    BOOL success = NO;
    NSString *pathString = [NSString stringWithFormat:DefaultKeyedArchiverPath, NSHomeDirectory()];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL dataSavePathExist = [fileManager fileExistsAtPath:pathString];
    if (dataSavePathExist == NO)
    {
        //路径不存在，则创建
        BOOL creatResult = [fileManager createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
        if (creatResult == YES)
        {
            NSLog(@"创建文件下载路径成功");
            success = YES;
        }
        else
        {
            NSLog(@"创建文件下载路径失败");
            success = NO;
        }
    }
    else
    {
        NSLog(@"文件下载路径已创建");
        success = YES;
    }
    return success;
}





- (BOOL)isArray{
    return [self isKindOfClass:[NSArray class]];
}
- (BOOL)isDictionary{
    return [self isKindOfClass:[NSDictionary class]];
}
- (BOOL)isString{
    return [self isKindOfClass:[NSString class]];
}
- (BOOL)isNumber{
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)isNull{
    return [self isKindOfClass:[NSNull class]];
}

- (BOOL)isImage{
    return [self isKindOfClass:[UIImage class]];
}

- (BOOL)isData{
    return [self isKindOfClass:[NSData class]];
}


- (BOOL)booleanValueForKey:(NSString *)key default:(BOOL)defaultValue{
    id value = [self valueForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return defaultValue;
}

- (BOOL)booleanValueForKey:(NSString *) key{
    return [self booleanValueForKey:key default:NO];
}


- (NSDictionary *)dictionaryRepresentation{
    
    if ([self isDictionary]) {
        return (NSDictionary *)self;
    }
    
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        id value = nil;
        @try {
            value = [self valueForKey:propertyName];
        }
        @catch (NSException *exception) {
            value = [NSNull null];
        }
        
        if (!value) {
            value = [NSNull null];
        }else{
            value = [self getValueInternal:value];
        }
        [dict setValue:value forKey:propertyName];
    }
    free(properties);
    return dict;
}

- (id)getValueInternal:(id)object{
    
    if ([object isString] || [object isNumber] || [object isNull]) {
        return object;
    }else if([object isImage]){//图片类型
        return [NSNull null];
    }else if([object isData]){//二进制数据类型
        return [NSNull null];
    }else if([object isArray]){
        NSArray *arrayObjects = (NSArray *)object;
        NSMutableArray *handledObjects = [NSMutableArray arrayWithCapacity:[arrayObjects count]];
        for(int i=0;i<[arrayObjects count];i++){
            [handledObjects setObject:[self getValueInternal:arrayObjects[i]] atIndexedSubscript:i];
        }
        return handledObjects;
    }else if([object isDictionary]){
        NSDictionary *dict = (NSDictionary *)object;
        NSMutableDictionary *handledDict = [NSMutableDictionary dictionary];
        for (NSString *key in dict.allKeys) {
            [handledDict setObject:[self getValueInternal:dict[key]] forKey:key];
        }
        return handledDict;
    }
    
    //对象类型
    return [object dictionaryRepresentation];
}






@end




