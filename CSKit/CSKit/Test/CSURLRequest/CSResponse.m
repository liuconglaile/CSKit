//
//  CSResponse.m
//  CSKit
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSResponse.h"

@implementation NSObject(CSUTF8)

- (NSString *)dataUTF8{
    
    NSString *desc = [self description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

@end




@interface CSResponse()<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray * xmlDataArray;
@property (nonatomic, strong) id xmlResult;
@property (nonatomic, strong) NSString * xmlCharacter;


@end

@implementation CSResponse

- (NSString *)xmlCharacter{
    if (!_xmlCharacter) {
        _xmlCharacter = @"";
    }
    return _xmlCharacter;
}
- (NSMutableArray *)xmlDataArray{
    if (!_xmlDataArray) {
        _xmlDataArray = [NSMutableArray array];
    }
    return _xmlDataArray;
}
/**
 json返回数据处理
 
 @param response 返回数据
 @return 返处理后的JSON返回数据
 */
- (id)responseObjectJsonHandle:(NSData *)response{
    
    if (response == nil) {
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:response
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
    if (!jsonObject) {
        jsonObject = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    }
    return jsonObject;
}
- (id)responseObjectXMLHandle:(NSData *)response{
    
    if (response == nil) {
        return nil;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:response];
    parser.delegate = self;
    [parser setShouldResolveExternalEntities:YES];
    BOOL isSuccess = [parser parse];
    
    if (!isSuccess) {
        NSLog(@"\n【VDResponse】xml response parsing failure!");
        self.xmlResult = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    }
    
    return self.xmlResult;
}
- (id (^)(NSData *))responseHandle{
    
    return ^id(NSData *data){
        if (self.type == CSResponseTypeJSON) {
            
            return [self responseObjectJsonHandle:data];
            
        }else if(self.type == CSResponseTypeXML){
            
            return [self responseObjectXMLHandle:data];
        }
        return nil;
    };
}

#pragma mark XML Parser Delegate

- (NSString *)deleteSpace:(NSString *)str{
    if (!str) {
        return nil;
    }
    NSString *str1= [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [str2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"" forKey:elementName];
    [self.xmlDataArray addObject:dic];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    self.xmlCharacter = [self deleteSpace:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    NSMutableDictionary *dic = self.xmlDataArray.lastObject;
    
    if ([dic[elementName] isKindOfClass:[NSString class]]) {
        dic[elementName] = self.xmlCharacter;
    }
    
    if (self.xmlDataArray.count > 1) {
        
        NSMutableDictionary *supDic = self.xmlDataArray[self.xmlDataArray.count-2];
        id value = supDic[supDic.allKeys[0]];
        
        if ([value isKindOfClass:[NSString class]]) {
            
            supDic[supDic.allKeys[0]] = dic;
            
        }else if ([value isKindOfClass:[NSDictionary class]]){
            
            NSArray *allKeys = ((NSDictionary *)value).allKeys;
            
            __block BOOL isDic = YES;
            [allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:elementName]) {
                    isDic = NO;
                    *stop = YES;
                }
            }];
            
            if (isDic) {
                
                [(NSMutableDictionary *)value setObject:dic[elementName] forKey:elementName];
                
            }else{
                
                NSMutableArray *arr = [NSMutableArray array];
                for (NSString *key in allKeys) {
                    [arr addObject:@{key:((NSDictionary *)value)[key]}];
                }
                [arr addObject:dic];
                supDic[supDic.allKeys[0]] = arr;
            }
            
        }else{
            
            [(NSMutableArray *)value addObject:dic];
        }
        
        [self.xmlDataArray removeLastObject];
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    if (self.xmlDataArray.count>0) {
        
        self.xmlResult = self.xmlDataArray.firstObject;
    }
}

@end




