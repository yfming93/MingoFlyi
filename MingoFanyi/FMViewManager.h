//
//  FMViewManager.h
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/8.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface FMViewManager : NSObject

- (instancetype)initViewManagerWithInputScrollView:(NSScrollView *)inputScrollView
                                     inputTextView:(NSTextView *)inputTextView
                                  outputScrollView:(NSScrollView *)outputScrollView
                                       outTextView:(NSTextView *)outputTextView
                       btnHumpSmall:(NSButton *)btnHumpSmall
                              btnCopy:(NSButton *)copyModeButton
                              btnUnderLineSmall:(NSButton *)btnUnderLineSmall
                                btnUnderLineBig:(NSButton *)btnUnderLineBig
                                     btnHumpBig:(NSButton *)btnHumpBig
                                       clearButton:(NSButton *)clearButton;
@end
