//
//  CSKit.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>



#import "CSKitMacro.h"


///MARK: ===================================================
///MARK: Foundation
///MARK: ===================================================
#import "NSArray+Extended.h"
#import "NSBundle+Extended.h"
#import "NSData+Extended.h"
#import "NSDate+Extended.h"
#import "NSDateFormatter+Utilities.h"
#import "NSDictionary+Extended.h"
#import "NSFileManager+Utilities.h"
#import "NSHTTPCookieStorage+Utilities.h"
#import "NSKeyedUnarchiver+Extended.h"
#import "NSNotificationCenter+Extended.h"
#import "NSNumber+Extended.h"
#import "NSObject+ARCExtended.h"
#import "NSObject+Extended.h"
#import "NSObject+KVOExtended.h"
#import "NSObject+Socket.h"
#import "NSSet+Utilities.h"
#import "NSString+Extended.h"
#import "NSString+Identify.h"
#import "NSThread+Extended.h"
#import "NSURL+Utilities.h"
#import "NSUserDefaults+Utilities.h"

///MARK: ===================================================
///MARK: UIKit
///MARK: ===================================================
#import "UIApplication+Extended.h"
#import "UIBarButtonItem+Extended.h"
#import "UIBezierPath+Extended.h"
#import "UIButton+Extended.h"
#import "UIColor+Extended.h"
#import "UIControl+Extended.h"
#import "UIDevice+Extended.h"
#import "UIFont+Extended.h"
#import "UIGestureRecognizer+Extended.h"
#import "UIImage+Blur.h"
#import "UIImage+Extended.h"
#import "UIImageView+Extended.h"
#import "UILabel+Extended.h"
#import "UINavigationBar+Extended.h"
#import "UINavigationController+Extended.h"
#import "UINavigationItem+Extended.h"
#import "UIResponder+Extended.h"
#import "UIScreen+Extended.h"
#import "UIScrollView+Extended.h"
#import "UISearchBar+Extended.h"
#import "UITableView+Extended.h"
#import "UITableViewCell+Extended.h"
#import "UITextField+Extended.h"
#import "UITextView+Extended.h"
#import "UIView+Extended.h"
#import "UIViewController+Extended.h"
#import "UIWebView+Extended.h"
#import "UIWindow+Extended.h"


///MARK: ===================================================
///MARK: Quartz
///MARK: ===================================================
#import "CALayer+Extended.h"
#import "NSObject+CGUtilities.h"



///MARK: ===================================================
///MARK: Macro
///MARK: ===================================================
#import "CSKitMacro.h"


///MARK: ===================================================
///MARK: Utility
///MARK: ===================================================
#import "CSAsyncLayer.h"
#import "CSDispatchQueuePool.h"
#import "CSFileHash.h"
#import "CSGestureRecognizer.h"
#import "CSKeychain.h"
#import "CSReachability.h"
#import "CSSentinel.h"
#import "CSThreadSafeArray.h"
#import "CSThreadSafeDictionary.h"
#import "CSTimer.h"
#import "CSTransaction_Utility.h"
#import "CSWeakProxy.h"


///MARK: ===================================================
///MARK: Cache
///MARK: ===================================================
#import "CSCache.h"
#import "CSDiskCache.h"
#import "CSMemoryCache.h"



///MARK: ===================================================
///MARK: Model
///MARK: ===================================================
#import "NSObject+CSModel.h"
#import "NSDictionary+ShowProperty.h"





///MARK: ===================================================
///MARK: Image
///MARK: ===================================================
#import "CSImage.h"
#import "CSFrameImage.h"
#import "CSAnimatedImageView.h"
#import "CSImageCache.h"
#import "CSImageDecoder.h"
#import "CSSpriteSheetImage.h"
#import "CSWebImageManager.h"
#import "CSWebImageOperation.h"
#import "CALayer+CSWebImage.h"
#import "MKAnnotationView+CSWebImage.h"
#import "UIButton+CSWebImage.h"
#import "UIImageView+CSWebImage.h"


///MARK: ===================================================
///MARK: CoreText
///MARK: ===================================================
#import "CSLabel.h"
#import "CSTextView.h"
#import "CSTextAttribute.h"
#import "CSTextArchiver.h"
#import "CSTextParser.h"
#import "CSTextUtilities.h"
#import "CSTextRunDelegate.h"
#import "CSTextRubyAnnotation.h"
#import "NSAttributedString+CSText.h"
#import "NSParagraphStyle+CSText.h"
#import "UIPasteboard+CSText.h"
#import "CSTextLayout.h"
#import "CSTextLine.h"
#import "CSTextInput.h"
#import "CSTextDebugOption.h"
#import "CSTextContainerView.h"
#import "CSTextSelectionView.h"
#import "CSTextMagnifier.h"
#import "CSTextEffectWindow.h"
#import "CSTextKeyboardManager.h"




///MARK: ===================================================
///MARK: CustomClass
///MARK: ===================================================

/** tableView 封装 */
#import "UITableView+Protocol.h"
#import "CSBaseCell.h"
#import "CSBaseLayoutModel.h"
#import "CSBaseClickView.h"
#import "CSPictureView.h"



@interface CSKit : NSObject

@end







