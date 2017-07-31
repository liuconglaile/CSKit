//
//  UISearchBar+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (Extended)

@property (copy, nonatomic) BOOL (^completionShouldBeginEditingBlock)(UISearchBar *searchbar);
@property (copy, nonatomic) void (^completionTextDidBeginEditingBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) BOOL (^completionShouldEndEditingBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionTextDidEndEditingBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionTextDidChangeBlock)(UISearchBar *searchBar, NSString *searchText);
@property (copy, nonatomic) BOOL (^completionShouldChangeTextInRangeBlock)(UISearchBar *searchBar, NSRange range, NSString *replacementText);
@property (copy, nonatomic) void (^completionSearchButtonClickedBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionBookmarkButtonClickedBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionCancelButtonClickedBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionResultsListButtonClickedBlock)(UISearchBar *searchBar);
@property (copy, nonatomic) void (^completionSelectedScopeButtonIndexDidChangeBlock)(UISearchBar *searchBar, NSInteger selectedScope);


// 即将开始编辑或回调
- (void)setCompletionShouldBeginEditingBlock:(BOOL (^)(UISearchBar *searchBar))searchBarShouldBeginEditingBlock;
// 即将完成编辑后回调
- (void)setCompletionTextDidBeginEditingBlock:(void (^)(UISearchBar *searchBar))searchBarTextDidBeginEditingBlock;
// 确实开始编辑后回调
- (void)setCompletionShouldEndEditingBlock:(BOOL (^)(UISearchBar *searchBar))searchBarShouldEndEditingBlock;
// 确实完成编辑后回调
- (void)setCompletionTextDidEndEditingBlock:(void (^)(UISearchBar *searchBar))searchBarTextDidEndEditingBlock;
// 确实开始索引改变后回调
- (void)setCompletionTextDidChangeBlock:(void (^)(UISearchBar *searchBar, NSString *text))searchBarTextDidChangeBlock;

- (void)setCompletionShouldChangeTextInRangeBlock:(BOOL (^)(UISearchBar *searchBar, NSRange range, NSString *text))searchBarShouldChangeTextInRangeBlock;
- (void)setCompletionSearchButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarSearchButtonClickedBlock;
- (void)setCompletionBookmarkButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarBookmarkButtonClickedBlock;
- (void)setCompletionCancelButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarCancelButtonClickedBlock;
- (void)setCompletionResultsListButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarResultsListButtonClickedBlock;
- (void)setCompletionSelectedScopeButtonIndexDidChangeBlock:(void (^)(UISearchBar *searchBar, NSInteger index))searchBarSelectedScopeButtonIndexDidChangeBlock;


@end



