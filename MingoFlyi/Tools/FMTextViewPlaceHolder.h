//
//  FMTextViewPlaceHolder.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/30.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMTextViewPlaceHolder : NSTextView
/// 占位符文本
@property (nonatomic, strong) IBInspectable NSString *placeHolder;
/// 占位符颜色
@property (nonatomic, strong) IBInspectable NSColor *holderColor;
/// 占位符字体
@property (nonatomic, assign) IBInspectable NSInteger holderFont;
@end

NS_ASSUME_NONNULL_END
