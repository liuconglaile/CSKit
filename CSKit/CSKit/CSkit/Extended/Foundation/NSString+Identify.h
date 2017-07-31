//
//  NSString+Identify.h
//  CSCategory
//
//  Created by mac on 17/5/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Identify)

/**
 *  手机号码的有效性:分电信、联通、移动和小灵通
 */
- (BOOL)isMobileNumberClassification;
/**
 *  手机号有效性
 */
- (BOOL)isMobileNumber;

/**
 *  邮箱的有效性
 */
- (BOOL)isEmailAddress;

/**
 *  简单的身份证有效性
 *
 */
- (BOOL)simpleVerifyIdentityCardNum;

/**
 *  精确的身份证号码有效性检测
 *
 *  @param value 身份证号
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;

/**
 *  车牌号的有效性
 */
- (BOOL)isCarNumber;

/**
 *  银行卡的有效性
 */
- (BOOL)bankCardluhmCheck;

/**
 *  IP地址有效性
 */
- (BOOL)isIPAddress;

/**
 *  Mac地址有效性
 */
- (BOOL)isMacAddress;

/**
 *  网址有效性
 */
- (BOOL)isValidUrl;

/**
 *  纯汉字
 */
- (BOOL)isValidChinese;

/**
 *  邮政编码
 */
- (BOOL)isValidPostalcode;

/**
 *  工商税号
 */
- (BOOL)isValidTaxNo;

/**
 是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 
 @param minLenth 最小长度
 @param maxLenth 最长长度
 @param containChinese 是否包含中文
 @param firstCannotBeDigtal 首字母不能为数字
 @return 正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 
 @param minLenth 最小长度
 @param maxLenth 最长长度
 @param containChinese 是否包含中文
 @param containDigtal 是否包含数字
 @param containLetter 是否包含字母
 @param containOtherCharacter 其他字符
 @param firstCannotBeDigtal 首字母不能为数字
 @return 正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;


@end
