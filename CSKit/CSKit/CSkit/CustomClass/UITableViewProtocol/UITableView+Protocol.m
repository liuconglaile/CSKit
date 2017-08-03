//
//  UITableView+Protocol.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UITableView+Protocol.h"
#import <objc/runtime.h>

static void * CSProtocolKey = @"CSProtocolKey";

@implementation UITableView (Protocol)

- (void)registerClass:(NSString *)className identifier:(NSString *)identifier{
    
    [self registerClass:NSClassFromString(className) forCellReuseIdentifier:identifier];
}
- (void)registerNib:(NSString *)NibName identifier:(NSString *)identifier{
    [self registerNib:[UINib nibWithNibName:NibName bundle:[NSBundle bundleForClass:NSClassFromString(NibName)]] forCellReuseIdentifier:identifier];
}

- (CSTableViewDelegate *)protocol{
    return objc_getAssociatedObject(self, CSProtocolKey);
}
- (void)setUpTableView{
    
    if (![self protocol]) {
        
        CSTableViewDelegate *delegate =[[CSTableViewDelegate alloc]initWithTableView:self];
        
        objc_setAssociatedObject(self, CSProtocolKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}

- (void)removeDelegate{
    if ([self protocol]) {
        
        //CSTableViewDelegate *delegate =[[CSTableViewDelegate alloc]initWithTableView:self];
        
        objc_setAssociatedObject(self, CSProtocolKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setData:(id)data{
    
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] setData:data];
}
- (id)getData{
    
    if (![self protocol])return nil;
    
    return [[self protocol] getData];
    
    
}
- (void)setNumberOfSections:(CSSecionNumBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    [[self protocol] setNumberOfSections:block];
    
    
}
- (void)setNumberOfRows:(CSRowNumForSecionBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    [[self protocol] setNumberOfRows:block];
}

- (void)setHeightForRow:(CSRowHeightBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] setHeightForRow:block];
}
- (void)setHeightForHeader:(CSHeaderFooterHeightBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] setHeightForFooter:block];
}
- (void)setViewForHeader:(CSHeaderFooterViewBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    [[self protocol] setViewForHeader:block];
    
}
- (void)setHeightForFooter:(CSHeaderFooterHeightBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] setHeightForFooter:block];
}
- (void)setViewForFooter:(CSHeaderFooterViewBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] setViewForFooter:block];
    
}
- (void)setWillDisplayCell:(CSWillDisplayCellBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    [[self protocol] setWillDisplayCell:block];
}
- (void)setCellForRow:(CSCellForRowBlock)block{
    if (![self protocol]) {
        [self setUpTableView];
    }
    [[self protocol] setCellForRow:block];
}
- (void)addSelectRowAction:(CSTableViewAction)action{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] addSelectRowAction:action];
    
}
- (void)addCellClickAction:(CSTableViewAction)action{
    if (![self protocol]) {
        [self setUpTableView];
    }
    
    [[self protocol] addCellClickAction:action];
    
}

@end



