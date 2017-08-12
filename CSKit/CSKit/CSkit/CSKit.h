//
//  CSKit.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __has_include(<CSkit/CSkit.h>)

///MARK: ===================================================
///MARK: Foundation
///MARK: ===================================================
#import <CSkit/NSArray+Extended.h>
#import <CSkit/NSBundle+Extended.h>
#import <CSkit/NSData+Extended.h>
#import <CSkit/NSDate+Extended.h>
#import <CSkit/NSDateFormatter+Utilities.h>
#import <CSkit/NSDictionary+Extended.h>
#import <CSkit/NSFileManager+Utilities.h>
#import <CSkit/NSHTTPCookieStorage+Utilities.h>
#import <CSkit/NSKeyedUnarchiver+Extended.h>
#import <CSkit/NSNotificationCenter+Extended.h>
#import <CSkit/NSNumber+Extended.h>
#import <CSkit/NSObject+ARCExtended.h>
#import <CSkit/NSObject+Extended.h>
#import <CSkit/NSObject+KVOExtended.h>
#import <CSkit/NSObject+Socket.h>
#import <CSkit/NSSet+Utilities.h>
#import <CSkit/NSString+Extended.h>
#import <CSkit/NSString+Identify.h>
#import <CSkit/NSThread+Extended.h>
#import <CSkit/NSURL+Utilities.h>
#import <CSkit/NSUserDefaults+Utilities.h>

///MARK: ===================================================
///MARK: UIKit
///MARK: ===================================================
#import <CSkit/UIApplication+Extended.h>
#import <CSkit/UIBarButtonItem+Extended.h>
#import <CSkit/UIBezierPath+Extended.h>
#import <CSkit/UIButton+Extended.h>
#import <CSkit/UIColor+Extended.h>
#import <CSkit/UIControl+Extended.h>
#import <CSkit/UIDevice+Extended.h>
#import <CSkit/UIFont+Extended.h>
#import <CSkit/UIGestureRecognizer+Extended.h>
#import <CSkit/UIImage+Blur.h>
#import <CSkit/UIImage+Extended.h>
#import <CSkit/UIImageView+Extended.h>
#import <CSkit/UILabel+Extended.h>
#import <CSkit/UINavigationBar+Extended.h>
#import <CSkit/UINavigationController+Extended.h>
#import <CSkit/UINavigationItem+Extended.h>
#import <CSkit/UIResponder+Extended.h>
#import <CSkit/UIScreen+Extended.h>
#import <CSkit/UIScrollView+Extended.h>
#import <CSkit/UISearchBar+Extended.h>
#import <CSkit/UITableView+Extended.h>
#import <CSkit/UITableViewCell+Extended.h>
#import <CSkit/UITextField+Extended.h>
#import <CSkit/UITextView+Extended.h>
#import <CSkit/UIView+Extended.h>
#import <CSkit/UIViewController+Extended.h>
#import <CSkit/UIWebView+Extended.h>
#import <CSkit/UIWindow+Extended.h>


///MARK: ===================================================
///MARK: Quartz
///MARK: ===================================================
#import <CSkit/CALayer+Extended.h>
#import <CSkit/NSObject+CGUtilities.h>



///MARK: ===================================================
///MARK: Macro
///MARK: ===================================================
#import <CSkit/CSKitMacro.h>


///MARK: ===================================================
///MARK: Utility
///MARK: ===================================================
#import <CSkit/CSAsyncLayer.h>
#import <CSkit/CSDispatchQueuePool.h>
#import <CSkit/CSFileHash.h>
#import <CSkit/CSGestureRecognizer.h>
#import <CSkit/CSKeychain.h>
#import <CSkit/CSReachability.h>
#import <CSkit/CSSentinel.h>
#import <CSkit/CSThreadSafeArray.h>
#import <CSkit/CSThreadSafeDictionary.h>
#import <CSkit/CSTimer.h>
#import <CSkit/CSTransaction_Utility.h>
#import <CSkit/CSWeakProxy.h>


///MARK: ===================================================
///MARK: Cache
///MARK: ===================================================
#import <CSkit/CSCache.h>
#import <CSkit/CSDiskCache.h>
#import <CSkit/CSMemoryCache.h>



///MARK: ===================================================
///MARK: Model
///MARK: ===================================================
#import <CSkit/NSObject+CSModel.h>
#import <CSkit/NSDictionary+ShowProperty.h>





///MARK: ===================================================
///MARK: Image
///MARK: ===================================================
#import <CSkit/CSImage.h>
#import <CSkit/CSFrameImage.h>
#import <CSkit/CSAnimatedImageView.h>
#import <CSkit/CSImageCache.h>
#import <CSkit/CSImageDecoder.h>
#import <CSkit/CSSpriteSheetImage.h>
#import <CSkit/CSWebImageManager.h>
#import <CSkit/CSWebImageOperation.h>
#import <CSkit/CALayer+CSWebImage.h>
#import <CSkit/MKAnnotationView+CSWebImage.h>
#import <CSkit/UIButton+CSWebImage.h>
#import <CSkit/UIImageView+CSWebImage.h>


///MARK: ===================================================
///MARK: CoreText
///MARK: ===================================================
#import <CSkit/CSLabel.h>
#import <CSkit/CSTextView.h>
#import <CSkit/CSTextAttribute.h>
#import <CSkit/CSTextArchiver.h>
#import <CSkit/CSTextParser.h>
#import <CSkit/CSTextUtilities.h>
#import <CSkit/CSTextRunDelegate.h>
#import <CSkit/CSTextRubyAnnotation.h>
#import <CSkit/NSAttributedString+CSText.h>
#import <CSkit/NSParagraphStyle+CSText.h>
#import <CSkit/UIPasteboard+CSText.h>
#import <CSkit/CSTextLayout.h>
#import <CSkit/CSTextLine.h>
#import <CSkit/CSTextInput.h>
#import <CSkit/CSTextDebugOption.h>
#import <CSkit/CSTextContainerView.h>
#import <CSkit/CSTextSelectionView.h>
#import <CSkit/CSTextMagnifier.h>
#import <CSkit/CSTextEffectWindow.h>
#import <CSkit/CSTextKeyboardManager.h>




///MARK: ===================================================
///MARK: CustomClass
///MARK: ===================================================

/** tableView 封装 */
#import <CSkit/UITableView+Protocol.h>
#import <CSkit/CSBaseCell.h>
#import <CSkit/CSBaseLayoutModel.h>
#import <CSkit/CSControl.h>


#else





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
#import "CSControl.h"

#endif


@interface CSKit : NSObject

@end







