//
//  UIPasteboard+CSText.m
//  CSCategory
//
//  Created by mac on 2017/7/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIPasteboard+CSText.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSAttributedString+CSText.h"
#import "CSImage.h"

#import "CSKitMacro.h"

CSSYNTH_DUMMY_CLASS(UIPasteboard_CSText)

NSString *const CSPasteboardTypeAttributedString = @"com.ibireme.CSKit.NSAttributedString";
NSString *const CSUTTypeWEBP = @"com.google.webp";
#define kPasteboardkitYey @"com.apple.uikit.image"

@implementation UIPasteboard (CSText)

- (void)setPNGData:(NSData *)PNGData {
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}

- (NSData *)PNGData {
    return [self dataForPasteboardType:(id)kUTTypePNG];
}

- (void)setJPEGData:(NSData *)JPEGData {
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}

- (NSData *)JPEGData {
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setGIFData:(NSData *)GIFData {
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}

- (NSData *)GIFData {
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}

- (void)setWEBPData:(NSData *)WEBPData {
    [self setData:WEBPData forPasteboardType:CSUTTypeWEBP];
}

- (NSData *)WEBPData {
    return [self dataForPasteboardType:CSUTTypeWEBP];
}

- (void)setImageData:(NSData *)imageData {
    [self setData:imageData forPasteboardType:(id)kUTTypeImage];
}

- (NSData *)imageData {
    return [self dataForPasteboardType:(id)kUTTypeImage];
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    self.string = [attributedString plainTextForRange:NSMakeRange(0, attributedString.length)];
    NSData *data = [attributedString archiveToData];
    if (data) {
        NSDictionary *item = @{CSPasteboardTypeAttributedString : data};
        [self addItems:@[item]];
    }
    [attributedString enumerateAttribute:CSTextAttachmentAttributeName_text inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(CSTextAttachment *attachment, NSRange range, BOOL *stop) {
        UIImage *img = attachment.content;
        if ([img isKindOfClass:[UIImage class]]) {
            NSDictionary *item = @{kPasteboardkitYey : img};
            [self addItems:@[item]];
            
            
            if ([img isKindOfClass:[CSImage class]] && ((CSImage *)img).animatedImageData) {
                if (((CSImage *)img).animatedImageType == CSImageTypeGIF) {
                    NSDictionary *item = @{(id)kUTTypeGIF : ((CSImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((CSImage *)img).animatedImageType == CSImageTypePNG) {
                    NSDictionary *item = @{(id)kUTTypePNG : ((CSImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((CSImage *)img).animatedImageType == CSImageTypeWebP) {
                    NSDictionary *item = @{(id)CSUTTypeWEBP : ((CSImage *)img).animatedImageData};
                    [self addItems:@[item]];
                }
            }
            
            
            // save image
            UIImage *simpleImage = nil;
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                simpleImage = attachment.content;
            } else if ([attachment.content isKindOfClass:[UIImageView class]]) {
                simpleImage = ((UIImageView *)attachment.content).image;
            }
            if (simpleImage) {
                NSDictionary *item = @{kPasteboardkitYey : simpleImage};
                [self addItems:@[item]];
            }
            
            // save animated image
            if ([attachment.content isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = attachment.content;
                CSImage *image = (id)imageView.image;
                if ([image isKindOfClass:[CSImage class]]) {
                    NSData *data = image.animatedImageData;
                    CSImageType type = image.animatedImageType;
                    if (data) {
                        switch (type) {
                            case CSImageTypeGIF: {
                                NSDictionary *item = @{(id)kUTTypeGIF : data};
                                [self addItems:@[item]];
                            } break;
                            case CSImageTypePNG: { // APNG
                                NSDictionary *item = @{(id)kUTTypePNG : data};
                                [self addItems:@[item]];
                            } break;
                            case CSImageTypeWebP: {
                                NSDictionary *item = @{(id)CSUTTypeWEBP : data};
                                [self addItems:@[item]];
                            } break;
                            default: break;
                        }
                    }
                }
            }
            
        }
    }];
}

- (NSAttributedString *)attributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[CSPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString unarchiveFromData:data];
        }
    }
    return nil;
}


@end
