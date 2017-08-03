//
//  CSBaseLayoutModel.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSBaseLayoutModel.h"
#import "NSAttributedString+CSText.h"

@implementation CSBaseLayoutModel

-(id )initWithModel:(id)model identifier:(NSString *)identifier{
    
    self  = [super init];
    
    if (self) {
        self.dataModel = model;
        self.reuseIdentifier = identifier;
        
        [self celllayout];
    }
    
    return self;
}

-(void)celllayout{
    ///TODO:这个是在子类实现的
    
}
- (CSTextLayout *)layout:(UIFont *)font color:(UIColor*)color width:(CGFloat )width string:(NSString *)string max:(BOOL)max{
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    text.font = font;
    text.lineSpacing = 5;
    text.color = color;
    
    
    
    
    NSArray *array = [self compareUrl:string];
    
    
    ///TODO:这里统一设置 URL 的点击事件
    for (NSString *urlstr in array) {
        
        [text setTextHighlightRange:[string rangeOfString:urlstr]
                              color:[UIColor blueColor]
                    backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220]
                          tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                              
                              
                              ///点击事件
                              UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:[string substringWithRange:range] delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                              [alertView show];
                              
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                  [alertView dismissWithClickedButtonIndex:0 animated:YES];
                              });
                              
                              
                          }];
        
    }
    
    
    CSTextContainer *container = [CSTextContainer new];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    if (max) {
        container.maximumNumberOfRows = 0;//最多行数
    }else{
        
        container.maximumNumberOfRows = 5;//最多行数
    }
    
    
    CSTextLayout *layout = [CSTextLayout layoutWithContainer:container text:text];
    
    return layout;
}

- (NSArray *)compareUrl:(NSString*)string{
    
    NSError *error;
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSMutableArray *array=[NSMutableArray array];
    
    
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [string substringWithRange:match.range];
        [array addObject:substringForMatch];
    }
    
    
    return array;
    
}

@end
