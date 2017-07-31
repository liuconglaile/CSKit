//
//  CSTextArchiver.h
//  CSCategory
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


/**
 NSKeyedArchiver的子类实现NSKeyedArchiverDelegate协议
 
 归档器可以对包含的对象进行编码
 CGColor/CGImage/CTRunDelegateRef/.. (如 NSAttributedString).
 */
@interface CSTextArchiver : NSKeyedArchiver<NSKeyedArchiverDelegate>
@end



/**
 NSKeyedUnarchiver协议的一个子类NSKeyedUnarchiver.
 unarchiver可以解码由CSTextArchiver或NSKeyedArchiver编码的数据
 */
@interface CSTextUnarchiver : NSKeyedUnarchiver <NSKeyedUnarchiverDelegate>
@end

NS_ASSUME_NONNULL_END


