//
//  UIViewController+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol CSBackButtonItemTitleProtocol <NSObject>

@optional
/** 自定义返回的字符串 */
- (NSString *)navigationItemBackBarButtonTitle; //文本的长度是有限的，否则将被设定为"Back"
@end



/**
 控制器类型

 - CSViewControllerImagePicker: 图片
 - CSViewControllerVideoPicker: 视频
 - CSViewControllerNone: 默认
 */
typedef NS_ENUM(NSUInteger, CSViewControllerType) {
    CSViewControllerTypeImagePicker,
    CSViewControllerTypeVideoPicker,
    CSViewControllerTypeNone
};



#define affiliateToken @"10laQX"
typedef void (^CSBackButtonHandler)(UIViewController *aController);
typedef void (^UIViewControllerSegueBlock) (id sender, id destinationVC, UIStoryboardSegue *segue);
typedef void (^MediaSelectionHandler)(NSURL *mediaURL, NSData *data, CSViewControllerType type, BOOL success);
typedef void (^AlertViewDismissHandler)(void);
typedef void (^AlertViewButtonClickedAtIndexHandler)(UIImagePickerControllerSourceType selectedOption);
typedef void (^AlertViewConfirmedButtonClickedHandler)(void);
typedef void (^AlertViewCurrentPasswordConfirmedHandler)(NSString *currentPassword);



@interface UIViewController (Extended)
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
MFMessageComposeViewControllerDelegate,
MFMailComposeViewControllerDelegate,
UIActionSheetDelegate,
CSBackButtonItemTitleProtocol>

///MARK: =========================================
///MARK: 返回按钮相关
///MARK: =========================================

/**
 返回按钮回调

 @param backButtonHandler 获取并替代系统返回按键的回调
 */
- (void)backButtonTouched:(CSBackButtonHandler)backButtonHandler;
///MARK: =========================================
///MARK: 返回按钮相关
///MARK: =========================================







///MARK: =========================================
///MARK: 跳转相关
///MARK: =========================================
- (void)configureSegue:(NSString *)identifier withBlock:(UIViewControllerSegueBlock)block;

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender withBlock:(UIViewControllerSegueBlock)block;
///MARK: =========================================
///MARK: 跳转相关
///MARK: =========================================




///MARK: =========================================
///MARK: StoreKit相关
///MARK: =========================================
@property NSString *campaignToken;
@property (nonatomic, copy) void (^loadingStoreKitItemBlock)(void);
@property (nonatomic, copy) void (^loadedStoreKitItemBlock)(void);

- (void)presentStoreKitItemWithIdentifier:(NSInteger)itemIdentifier;

+ (NSURL*)appURLForIdentifier:(NSInteger)identifier;

+ (void)openAppURLForIdentifier:(NSInteger)identifier;
+ (void)openAppReviewURLForIdentifier:(NSInteger)identifier;

+ (BOOL)containsITunesURLString:(NSString*)URLString;
+ (NSInteger)IDFromITunesURL:(NSString*)URLString;
///MARK: =========================================
///MARK: StoreKit相关
///MARK: =========================================






///MARK: =========================================
///MARK: 其他
///MARK: =========================================
/**
 视图层级
 
 @return 视图层级字符串
 */
- (NSString*)recursiveDescription;

// 判断当前控制器是否可见
- (BOOL)isVisible;




@property (nonatomic, strong) UIImagePickerController           *imagePickerVC;
@property (nonatomic, strong) MFMailComposeViewController       *mailVC;
@property (nonatomic, strong) MFMessageComposeViewController    *messageVC;

@property (nonatomic, strong) MediaSelectionHandler handler;


- (void)sendEmailTo:(NSArray *)to forSubject:(NSString *)subject body:(NSString *)body ccRecipients:(NSArray *)cc bccRecipients:(NSArray *)bcc;
- (void)sendMessageTo:(NSArray *)recipents body:(NSString *)body;

- (void)addChildViewControllerInContainer:(UIView *)containerView childViewController:(UIViewController *)controller;

- (void)addChildViewControllerInContainer:(UIView *)containerView childViewController:(UIViewController *)controller preserverViewController:(UIViewController *)dontDeleteVC;

- (void)removeAllChildViewControllers;

- (void)removeAllChildViewControllersExcept:(UIViewController *)vc;


#pragma mark - UIAlertController Methods

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewDismissHandler)dismissHandler;

- (void)showConfirmationAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewConfirmedButtonClickedHandler)dismissHandler;

- (void)showCurrentPasswordConfirmationAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewCurrentPasswordConfirmedHandler)dismissHandler;

- (void)showPINConfirmationAlertViewWithDismissCompletion:(AlertViewCurrentPasswordConfirmedHandler)dismissHandler;


- (void)showActionSheetForImageInputWithTitle:(NSString *)title sender:(UIView *)sender withCompletionHandler:(AlertViewButtonClickedAtIndexHandler)completionHandler;

- (void)showActionSheetWithPickerView:(UIPickerView *)pickerView titleMessage:(NSString *)title completionHandler:(AlertViewDismissHandler)completionHandler;

- (void)showImagePickerWithType:(UIImagePickerControllerSourceType)type sender:(UIView *)sender withCompletionBlock:(MediaSelectionHandler)block;
- (void)showVideoPickerWithType:(UIImagePickerControllerSourceType)type sender:(UIView *)sender withCompletionBlock:(MediaSelectionHandler)block;
- (void)pickMediaWithType:(CSViewControllerType)vcType sender:(UIView*)sender withCompletion:(MediaSelectionHandler)block;
- (void)showAlertLocationDisabled;


///MARK: =========================================
///MARK: 其他
///MARK: =========================================



@end
