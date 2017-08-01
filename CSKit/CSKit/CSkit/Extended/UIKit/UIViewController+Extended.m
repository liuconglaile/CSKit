//
//  UIViewController+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIViewController+Extended.h"
#import <objc/runtime.h>
#import <StoreKit/StoreKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

static const void *CSBackButtonHandlerKey = &CSBackButtonHandlerKey;
static const void *UIViewControllerDictionaryBlockKey = &UIViewControllerDictionaryBlockKey;
NSString* const affiliateTokenKey = @"at";
NSString* const campaignTokenKey = @"ct";
NSString* const iTunesAppleString = @"itunes.apple.com";
static void * const kHandlerAssociatedStorageKey = (void*)&kHandlerAssociatedStorageKey;
static void * const kImagePickerAssociatedStorageKey = (void*)&kImagePickerAssociatedStorageKey;
static void * const kMailAssociatedStorageKey = (void*)&kMailAssociatedStorageKey;
static void * const kMessageAssociatedStorageKey = (void*)&kMessageAssociatedStorageKey;


@interface UIViewController ()<SKStoreProductViewControllerDelegate>

@end

@implementation UIViewController (Extended)

///MARK: =========================================
///MARK: 返回按钮相关
///MARK: =========================================
- (void)backButtonTouched:(CSBackButtonHandler)backButtonHandler{
    objc_setAssociatedObject(self, CSBackButtonHandlerKey, backButtonHandler, OBJC_ASSOCIATION_COPY);
}
- (CSBackButtonHandler)backButtonTouched
{
    return objc_getAssociatedObject(self, CSBackButtonHandlerKey);
}
///MARK: =========================================
///MARK: 返回按钮相关
///MARK: =========================================









///MARK: =========================================
///MARK: 跳转相关
///MARK: =========================================
__attribute__((constructor))
void CSBlockSegue(void) {
    Class currentClass = [UIViewController class];
    
    SEL originalSel = @selector(prepareForSegue:sender:);
    SEL swizzledSel = @selector(cs_prepareForSegue:sender:);
    
    Method originalMethod = class_getInstanceMethod(currentClass, originalSel);
    IMP swizzledImplementation = class_getMethodImplementation(currentClass, swizzledSel);
    
    method_setImplementation(originalMethod, swizzledImplementation);
}


- (void)cs_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue.identifier == nil) {
        return;
    }
    
    if (!self.jmg_dictionaryBlock || !self.jmg_dictionaryBlock[segue.identifier]) {
        NSLog(@"Segue identifier '%@' doesn't exist", segue.identifier);
        return;
    }
    
    UIViewControllerSegueBlock segueBlock = self.jmg_dictionaryBlock[segue.identifier];
    segueBlock(sender, segue.destinationViewController, segue);
}

- (NSMutableDictionary *)jmg_dictionaryBlock {
    return objc_getAssociatedObject(self, UIViewControllerDictionaryBlockKey);
}

- (NSMutableDictionary *)jmg_createDictionaryBlock {
    if (!self.jmg_dictionaryBlock) {
        objc_setAssociatedObject(self, UIViewControllerDictionaryBlockKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN);
    }
    
    return self.jmg_dictionaryBlock;
}

#pragma mark - Public interface
- (void)configureSegue:(NSString *)identifier withBlock:(UIViewControllerSegueBlock)block {
    if (!identifier) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Segue identifier can not be nil" userInfo:nil];
    }
    
    if (!block) {
        return ;
    }
    
    NSMutableDictionary *dBlocks = self.jmg_dictionaryBlock ?: [self jmg_createDictionaryBlock];
    [dBlocks setObject:block forKey:identifier];
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender withBlock:(UIViewControllerSegueBlock)block {
    if (!identifier) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Segue identifier can not be nil" userInfo:nil];
    }
    
    if (!block) {
        return ;
    }
    
    [self configureSegue:identifier withBlock:block];
    [self performSegueWithIdentifier:identifier sender:sender];
}
///MARK: =========================================
///MARK: 跳转相关
///MARK: =========================================








///MARK: =========================================
///MARK: StoreKit相关
///MARK: =========================================

- (void)presentStoreKitItemWithIdentifier:(NSInteger)itemIdentifier
{
    SKStoreProductViewController* storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;
    
    NSString* campaignToken = self.campaignToken ?: @"";
    
    NSDictionary* parameters = @{
                                 SKStoreProductParameterITunesItemIdentifier : @(itemIdentifier),
                                 affiliateTokenKey : affiliateTokenKey,
                                 campaignTokenKey : campaignToken,
                                 };
    
    if (self.loadingStoreKitItemBlock) {
        self.loadingStoreKitItemBlock();
    }
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError* error) {
        if (self.loadedStoreKitItemBlock) {
            self.loadedStoreKitItemBlock();
        }
        
        if (result && !error)
        {
            [self presentViewController:storeViewController animated:YES completion:nil];
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

+ (NSURL*)appURLForIdentifier:(NSInteger)identifier
{
    NSString* appURLString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%li", (long)identifier];
    return [NSURL URLWithString:appURLString];
}

+ (void)openAppReviewURLForIdentifier:(NSInteger)identifier
{
    NSString* reviewURLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%li", (long)identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURLString]];
}

+ (void)openAppURLForIdentifier:(NSInteger)identifier
{
    NSString* appURLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%li", (long)identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLString]];
}

+ (BOOL)containsITunesURLString:(NSString*)URLString
{
    return ([URLString rangeOfString:iTunesAppleString].location != NSNotFound);
}

+ (NSInteger)IDFromITunesURL:(NSString*)URLString
{
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"id\\d+" options:0 error:&error];
    NSTextCheckingResult* match = [regex firstMatchInString:URLString options:0 range:NSMakeRange(0, URLString.length)];
    
    NSString* idString = [URLString substringWithRange:match.range];
    if (idString.length > 0) {
        idString = [idString stringByReplacingOccurrencesOfString:@"id" withString:@""];
    }
    
    return [idString integerValue];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Associated objects

- (void)setCampaignToken:(NSString*)campaignToken
{
    objc_setAssociatedObject(self, @selector(setCampaignToken:), campaignToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)campaignToken
{
    return objc_getAssociatedObject(self, @selector(setCampaignToken:));
}

- (void)setLoadingStoreKitItemBlock:(void (^)(void))loadingStoreKitItemBlock
{
    objc_setAssociatedObject(self, @selector(setLoadingStoreKitItemBlock:), loadingStoreKitItemBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))loadingStoreKitItemBlock
{
    return objc_getAssociatedObject(self, @selector(setLoadingStoreKitItemBlock:));
}

- (void)setLoadedStoreKitItemBlock:(void (^)(void))loadedStoreKitItemBlock
{
    objc_setAssociatedObject(self, @selector(setLoadedStoreKitItemBlock:), loadedStoreKitItemBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))loadedStoreKitItemBlock
{
    return objc_getAssociatedObject(self, @selector(setLoadedStoreKitItemBlock:));
}

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
- (NSString*)recursiveDescription
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"\n"];
    [self addDescriptionToString:description indentLevel:0];
    return description;
}

- (void)addDescriptionToString:(NSMutableString*)string indentLevel:(NSInteger)indentLevel
{
    NSString *padding = [@"" stringByPaddingToLength:indentLevel withString:@" " startingAtIndex:0];
    [string appendString:padding];
    [string appendFormat:@"%@, %@",[self debugDescription],NSStringFromCGRect(self.view.frame)];
    
    for (UIViewController *childController in self.childViewControllers)
    {
        [string appendFormat:@"\n%@>",padding];
        [childController addDescriptionToString:string indentLevel:indentLevel + 1];
    }
}

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}



@dynamic handler;
@dynamic imagePickerVC;
@dynamic mailVC;
@dynamic messageVC;

- (void)setHandler:(MediaSelectionHandler)handler{
    objc_setAssociatedObject(self, kHandlerAssociatedStorageKey, handler, OBJC_ASSOCIATION_COPY);
}

- (MediaSelectionHandler)handler
{
    return objc_getAssociatedObject(self, kHandlerAssociatedStorageKey);
}

- (UIImagePickerController *)imagePickerVC{
    UIImagePickerController *imagePicker = objc_getAssociatedObject(self, kImagePickerAssociatedStorageKey);
    if (imagePicker == nil) {
        // do a lot of stuff
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        
        objc_setAssociatedObject(self, kImagePickerAssociatedStorageKey, imagePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return imagePicker;
}

- (MFMailComposeViewController *)mailVC{
    MFMailComposeViewController *mail = objc_getAssociatedObject(self, kMailAssociatedStorageKey);
    if (mail == nil) {
        // do a lot of stuff
        mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        objc_setAssociatedObject(self, kMailAssociatedStorageKey, mail, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return mail;
}

- (MFMessageComposeViewController *)messageVC{
    MFMessageComposeViewController *message = objc_getAssociatedObject(self, kMessageAssociatedStorageKey);
    if (message == nil) {
        // do a lot of stuff
        message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        objc_setAssociatedObject(self, kMessageAssociatedStorageKey, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return message;
}



- (void)addChildViewControllerInContainer:(UIView *)containerView childViewController:(UIViewController *)controller
{
    [self removeAllChildViewControllers];
    
    [self addChildViewController:controller];
    controller.view.frame = containerView.bounds;
    [containerView insertSubview:controller.view atIndex:0];
    [controller didMoveToParentViewController:self];
}

- (void)addChildViewControllerInContainer:(UIView *)containerView childViewController:(UIViewController *)controller preserverViewController:(UIViewController *)dontDeleteVC
{
    [self removeAllChildViewControllersExcept:dontDeleteVC];
    
    [self addChildViewController:controller];
    controller.view.frame = containerView.bounds;
    [containerView insertSubview:controller.view atIndex:0];
    [controller didMoveToParentViewController:self];
}


- (void)removeAllChildViewControllers
{
    for (UIViewController *childController in self.childViewControllers)
    {
        [childController willMoveToParentViewController:nil];
        
        [childController.view removeFromSuperview];
        
        [childController removeFromParentViewController];
    }
}


- (void)removeAllChildViewControllersExcept:(UIViewController *)vc
{
    for (UIViewController *childController in self.childViewControllers)
    {
        if (childController != vc)
        {
            [childController willMoveToParentViewController:nil];
            
            [childController.view removeFromSuperview];
            
            [childController removeFromParentViewController];
        }
    }
}




#pragma mark - UIAlertController Methods

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewDismissHandler)dismissHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        dismissHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)showConfirmationAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewConfirmedButtonClickedHandler)dismissHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dismissHandler();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil]];
    
    
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)showCurrentPasswordConfirmationAlertViewWithTitle:(NSString *)title message:(NSString *)message withDismissCompletion:(AlertViewCurrentPasswordConfirmedHandler)dismissHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        dismissHandler(@"");
    }]];
    
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Update Password" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *txtCurrentPassword = alert.textFields.lastObject;
        dismissHandler(txtCurrentPassword.text);
    }];
    
    
    [alert addAction:confirmAction];
    
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Current Password";
         textField.secureTextEntry = YES;
         
         [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
     }];
    
    
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)showPINConfirmationAlertViewWithDismissCompletion:(AlertViewCurrentPasswordConfirmedHandler)dismissHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SampleProject PIN" message:@"Please enter your App PIN" preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *txtCurrentPassword = alert.textFields.lastObject;
        dismissHandler(txtCurrentPassword.text);
    }];
    
    confirmAction.enabled = NO;
    [alert addAction:confirmAction];
    
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"App PIN";
         textField.secureTextEntry = YES;
         
         [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
     }];
    
    
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)showActionSheetForImageInputWithTitle:(NSString *)title sender:(UIView *)sender withCompletionHandler:(AlertViewButtonClickedAtIndexHandler)completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(UIImagePickerControllerSourceTypeCamera);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"照片库" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(UIImagePickerControllerSourceTypePhotoLibrary);
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    alertController.popoverPresentationController.sourceView = sender;
    alertController.popoverPresentationController.sourceRect = sender.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)showActionSheetWithPickerView:(UIPickerView *)pickerView titleMessage:(NSString *)title completionHandler:(AlertViewDismissHandler)completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    
    [alert.view addSubview:pickerView];
    
    
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    
    if (alertController)
    {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 2;
    }
}


- (void)showImagePickerWithType:(UIImagePickerControllerSourceType)type sender:(UIView *)sender withCompletionBlock:(MediaSelectionHandler)block{
    [self setHandler:block];
    
    self.imagePickerVC.mediaTypes = @[(NSString *)kUTTypeImage];
    switch (type) {
        case UIImagePickerControllerSourceTypeCamera:
        {
            if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"警告!"
                                                                  message:@"抱歉!此设备不支持您选择的选项"
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                
                [message show];
                return;
            }
        }
            break;
            
        default:
            break;
    }
    //    self.imagePickerVC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.imagePickerVC.sourceType = type;
    self.imagePickerVC.allowsEditing = YES;
    
    self.imagePickerVC.modalPresentationStyle = UIModalPresentationPopover;
    
    self.imagePickerVC.popoverPresentationController.sourceView = self.view;
    self.imagePickerVC.popoverPresentationController.sourceRect = sender.frame;
    
    [self presentViewController:self.imagePickerVC animated:YES completion:^{
    }];
}

- (void)showVideoPickerWithType:(UIImagePickerControllerSourceType)type sender:(UIView *)sender withCompletionBlock:(MediaSelectionHandler)block{
    [self setHandler:block];
    switch (type) {
        case UIImagePickerControllerSourceTypeCamera:
            if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"警告!"
                                                                  message:@"抱歉!此设备不支持您选择的选项"
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                
                [message show];
                return;
            }
            break;
            
        default:
            break;
    }
    
    self.imagePickerVC.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeVideo];
    self.imagePickerVC.sourceType = type;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        self.imagePickerVC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }
    
    self.imagePickerVC.modalPresentationStyle = UIModalPresentationPopover;
    
    self.imagePickerVC.popoverPresentationController.sourceView = self.view;
    self.imagePickerVC.popoverPresentationController.sourceRect = sender.frame;
    
    
    [self presentViewController:self.imagePickerVC animated:YES completion:^{}];
}

- (void)pickMediaWithType:(CSViewControllerType)CSViewControllerType sender:(UIView*)sender withCompletion:(MediaSelectionHandler)block{
    [self setHandler:block];
    
    switch (CSViewControllerType) {
        case CSViewControllerTypeImagePicker:
        {
            if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"8.0"]) {
                
                [self showActionSheetForImageInputWithTitle:@"选择您的照片媒体" sender:sender withCompletionHandler:^(UIImagePickerControllerSourceType selectedOption) {
                    
                    [self showImagePickerWithType:selectedOption sender:sender  withCompletionBlock:self.handler];
                }];
            }
            
            
        }
            break;
            
        case CSViewControllerTypeVideoPicker:
        {
            if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"8.0"]) {
                
                [self showActionSheetForImageInputWithTitle:@"选择您的视频媒体" sender:sender withCompletionHandler:^(UIImagePickerControllerSourceType selectedOption) {
                    
                    [self showVideoPickerWithType:selectedOption sender:sender withCompletionBlock:self.handler];
                }];
            }
        }break;
            
        default:
            break;
    }
}

- (void)sendEmailTo:(NSArray *)to forSubject:(NSString *)subject body:(NSString *)body ccRecipients:(NSArray *)cc bccRecipients:(NSArray *)bcc{
    [self.mailVC setSubject:subject];
    [self.mailVC setMessageBody:subject isHTML:NO];
    [self.mailVC setToRecipients:to];
    [self.mailVC setCcRecipients:cc];
    [self.mailVC setBccRecipients:bcc];
    
    [self presentViewController:self.mailVC animated:YES completion:NULL];
}

- (void)sendMessageTo:(NSArray *)recipents body:(NSString *)body{
    
    [self.messageVC setRecipients:recipents];
    [self.messageVC setBody:body];
    
    // Present message view controller on screen
    [self presentViewController:self.messageVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerViewControllerDelegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //NSLog(@"type=%@",type);
        NSURL *mediaURL = nil;
        NSData *imageData = nil;
        if ([type isEqualToString:(NSString *)kUTTypeVideo] ||
            [type isEqualToString:(NSString *)kUTTypeMovie])
        {// movie != video
            mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
            imageData = [NSData dataWithContentsOfURL:mediaURL];
            
            self.handler(mediaURL, imageData, CSViewControllerTypeVideoPicker, YES);
        }
        else{
            UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
            
            if (!selectedImage) {
                selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
            }
            UIImage *compressedImage = selectedImage;//[UIImage compressImage:selectedImage compressRatio:0.9f];
            imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
            mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
            self.handler(mediaURL , imageData, CSViewControllerTypeImagePicker, YES);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        self.handler(nil, nil, CSViewControllerTypeNone, NO);
    }];
}

#pragma mark - MFMailViewControllerDelegate -

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSString *string = @"";
    switch (result) {
        case MFMailComposeResultSent:
            string = @"电子邮件发送成功y.";
            break;
        case MFMailComposeResultSaved:
            string = @"电子邮件成功保存.";
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            string = @"邮件失败: 尝试撰写此电子邮件时发生错误.";
            break;
        default:
            string = @"尝试撰写此电子邮件时发生错误.";
            break;
    }
    
    if (string.length > 0) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法发送短信!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MFMessageViewControllerDelegate -

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *string = @"";
    switch (result) {
        case MessageComposeResultCancelled:
            
            break;
            
        case MessageComposeResultFailed:
        {
            string = @"无法发送短信!";
            break;
        }
            
        case MessageComposeResultSent:
            string = @"消息已成功发送";
            break;
            
        default:
            break;
    }
    
    if (string.length > 0) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate -

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

//    //    else if (actionSheet.tag == 2) {
//    //        if (buttonIndex != actionSheet.cancelButtonIndex) {
//    //            NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
//    //
//    //            if ([title isEqualToString:@"Take Live Video"]) {
//    //                [self showVideoPickerWithType:UIImagePickerControllerSourceTypeCamera withCompletionBlock:self.handler];
//    //            }
//    //            else if ([title isEqualToString:@"Pick Video From Library"]) {
//    //                [self showVideoPickerWithType:UIImagePickerControllerSourceTypePhotoLibrary withCompletionBlock:self.handler];
//    //                ;
//    //            }
//    //        }
//    //    }
//}

- (void)showAlertLocationDisabled
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString( @"位置服务已禁用", @"" ) message:NSLocalizedString( @"要重新启用，请转到设置，并为此应用程序打开位置服务.", @"" ) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"" ) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"" ) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    UIApplicationOpenSettingsURLString]];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




///MARK: =========================================
///MARK: 其他
///MARK: =========================================





@end




@implementation UINavigationController (NavigationItemBackBtnTile)

//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
//
//    UIViewController * viewController = self.viewControllers.count > 1 ? \
//    [self.viewControllers objectAtIndex:self.viewControllers.count - 2] : nil;
//
//    if (!viewController) {
//        return YES;
//    }
//
//    NSString *backButtonTitle = nil;
//    if ([viewController respondsToSelector:@selector(navigationItemBackBarButtonTitle)]) {
//        backButtonTitle = [viewController navigationItemBackBarButtonTitle];
//    }
//
//    if (!backButtonTitle) {
//        backButtonTitle = viewController.title;
//    }
//
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle
//                                                                       style:UIBarButtonItemStylePlain
//                                                                      target:nil action:nil];
//    viewController.navigationItem.backBarButtonItem = backButtonItem;
//
//    return YES;
//}

//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
//
//    if([self.viewControllers count] < [navigationBar.items count]) {
//        return YES;
//    }
//
//   	UIViewController* vc = [self topViewController];
//    CSBackButtonHandler handler = [vc backButtonTouched];
//    if (handler) {
//        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
//
//        for(UIView *subview in [navigationBar subviews]) {
//            if(subview.alpha < 1.) {
//                [UIView animateWithDuration:.25 animations:^{
//                    subview.alpha = 1.;
//                }];
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            handler(self);
//        });
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self popViewControllerAnimated:YES];
//        });
//    }
//
//    return NO;
//}



@end


