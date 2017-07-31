//
//  NSDictionary+ShowProperty.m
//  CSCategory
//
//  Created by mac on 2017/6/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSDictionary+ShowProperty.h"

@implementation NSDictionary (ShowProperty)


- (void)showPropertyWithPrefix:(NSString *)aPrefix AndBaseName:(NSString*)aBaseName isMapper:(BOOL)aMapper{
    
    NSMutableString *codes = [NSMutableString string];
    ///前缀
    NSString* tempPrefix = (aPrefix == nil)? @"CS" : aPrefix;
    ///根类名
    NSString* tempBaseName = (aBaseName == nil)? @"RootModel" : aBaseName;
    ///类名
    NSString* className = [NSString stringWithFormat:@"%@%@",tempPrefix,tempBaseName];
    ///.h
    NSString* interface = [NSString stringWithFormat:@"@interface %@ : NSObject\n\n",className];
    
    ///拼接.h
    [codes appendFormat:@"\n%@\n",interface];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        
        NSString *code = @"";
        
        if ([value isKindOfClass:[NSString class]]) {
            // NSString
            code = [NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;",[self modifyTheString:key]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            // NSArray 特殊处理
            //code = [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;",[self modifyTheString:key]];
            code = [self specialTreatmentArr:(NSArray*)value AndKey:key AndPrefix:aPrefix];
            
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // NSDictionary 特殊处理
            //code = [NSString stringWithFormat:@"@property (nonatomic, strong) NSDictionary *%@;",[self modifyTheString:key]];
            code = [self specialTreatmentDic:(NSDictionary*)value AndKey:key AndPrefix:aPrefix];
            
        } else if ([value isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
            
            code = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;",[self modifyTheString:key]];
            
        } else if ([value isKindOfClass:[NSNumber class]]) {
            
            code = [NSString stringWithFormat:@"@property (nonatomic, assign) NSInteger %@;",[self modifyTheString:key]];
        }
        
        [codes appendFormat:@"\n%@\n",code];
        
    }];
    
    ///拼接 @end
    [codes appendFormat:@"\n@end\n"];
    
    ///拼接.m
    NSString* implementation = [NSString stringWithFormat:@"@implementation %@",className];
    [codes appendFormat:@"\n%@\n",implementation];
    
    
    ///这里处理映射的编写(默认是 CSModel 的映射)
    if (aMapper) {
        
        
        ///键映射
        NSMutableDictionary* tempDict = @{}.mutableCopy;
        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            if ([self containsString:key]) {
                [tempDict setValue:[self modifyTheString:key] forKey:key];
            }
        }];
        ///如果有
        if ([tempDict allKeys].count > 0) {
            [codes appendFormat:@"\n + (NSDictionary *)modelCustomPropertyMapper {\n"];
            [codes appendFormat:@"\nreturn %@\n",tempDict];
            [codes appendFormat:@"\n}\n"];
        }
        
        
        
        
        ///类映射
        NSMutableDictionary* classDict = @{}.mutableCopy;
        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            
            if ([value isKindOfClass:[NSDictionary class]]) {
                [classDict setValue:[NSString stringWithFormat:@"[%@%@ class]",aPrefix,[[self modifyTheString:key] capitalizedString]] forKey:key];
            }
        }];
        ///如果有
        if ([classDict allKeys].count > 0) {
            [codes appendFormat:@"\n + (NSDictionary *)modelContainerPropertyGenericClass {\n"];
            [codes appendFormat:@"\nreturn %@\n",classDict];
            [codes appendFormat:@"\n}\n"];
        }
    }
    
    ///拼接 @end
    [codes appendFormat:@"\n@end\n"];
    
    NSLog(@"打印:\n%@",codes);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dict = (NSDictionary*)value;
            [dict showPropertyWithPrefix:aPrefix AndBaseName:[[self modifyTheString:key] capitalizedString] isMapper:YES];
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray* dicts = (NSArray*)value;
            BOOL isDic = NO;
            for (id object in dicts) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    isDic = YES;
                    break;
                }
            }
            if (isDic) {
                [dicts.firstObject showPropertyWithPrefix:aPrefix AndBaseName:[[self modifyTheString:key] capitalizedString] isMapper:YES];
            }
        }
    }];
    
    
    
}


///处理数组值的key
- (NSString*)specialTreatmentArr:(NSArray*)aArr AndKey:(NSString*)aKey AndPrefix:(NSString *)aPrefix{
    
    BOOL isDic = NO;
    BOOL isStr = NO;
    BOOL isNum = NO;
    for (id object in aArr) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            isDic = YES;
            break;
        }
        
        if ([object isKindOfClass:[NSString class]]) {
            isStr = YES;
            break;
        }
        
        if ([object isKindOfClass:[NSNumber class]]) {
            isNum = YES;
            break;
        }
    }
    
    
    if (isDic) {
        return [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray<%@%@*> *%@;",aPrefix,[[self modifyTheString:aKey] capitalizedString],[self modifyTheString:aKey]];
    }
    
    if (isStr) {
        return [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray<NSString*> *%@;",[self modifyTheString:aKey]];
    }
    
    if (isNum) {
        return [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;",[self modifyTheString:aKey]];
    }
    
    return [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;",[self modifyTheString:aKey]];
}

///处理字典值的key
- (NSString*)specialTreatmentDic:(NSDictionary*)aDic AndKey:(NSString*)aKey AndPrefix:(NSString *)aPrefix{
    return [NSString stringWithFormat:@"@property (nonatomic, strong) %@%@ *%@;",aPrefix,[[self modifyTheString:aKey] capitalizedString],[self modifyTheString:aKey]];
}


/// 检查是否带 _ 的 key
- (NSString*)modifyTheString:(NSString*)aString{
    return ([self containsString:aString])? [self componentsSeparatedByString:aString] : aString;
}

- (BOOL)containsString:(NSString*)aString{
    //字条串是否包含有某字符串
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_10
    return ([aString containsString:@"_"]) ? YES : NO;
#else
    return ([aString rangeOfString:@"_"].location != NSNotFound) ? YES : NO;
#endif
}

/// 分割并重新拼接 key
- (NSString*)componentsSeparatedByString:(NSString*)aString{
    
    NSMutableString *tempStr = [NSMutableString string];
    
    
    NSArray *tempArr = [aString componentsSeparatedByString:@"_"];
    //NSLog(@"%@",[tempArr description]);
    
    for (NSInteger idex = 0; idex < tempArr.count; idex++) {
        
        NSString* object = tempArr[idex];
        if (![object isEqualToString:@"_"]) {
            ///不是 _ 则拼接 并且非后面的字符串首字母大写
            [tempStr appendString:(idex == 0)? object : [object capitalizedString]];
        }
    }
    
    return tempStr.mutableCopy;
}



@end
