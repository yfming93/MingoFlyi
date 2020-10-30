//
//  NSTextView+FMPlaceHolder.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "NSTextView+FMPlaceHolder.h"
#import <objc/runtime.h>

@interface NSTextView ()<NSTextDelegate,NSTextInput,NSTextViewDelegate>
@property (nonatomic, strong) NSTextField *placeHolderTextField;
@end

@implementation NSTextView (FMPlaceHolder)

@dynamic placeHolder,holderColor,holderFont;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
//    [self fm_initPlaceHolder];
    self.placeHolderTextField = [self fm_addTextViewPlaceholderWithString:self.placeHolder textView:self];

}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        [self fm_initPlaceHolder];
        self.delegate = self;

    }
    return self;
}



- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}


- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if (!self.string.length){
        self.placeHolderTextField = [self fm_addTextViewPlaceholderWithString:self.placeHolder textView:self];
    }
  
}

- (void)textDidChange:(NSNotification *)notification
{
    NSLog(@"text typed-self.string：%@",self.string);
    if (!self.string.length){
        [self fm_placeHolder];
    }
}

- (void)fm_initPlaceHolder {
    if (self.placeHolderTextField == nil) {
        [self fm_removePlaceholder:self.placeHolderTextField];
        self.placeHolderTextField = [self fm_addTextViewPlaceholderWithString:self.placeHolder textView:self];
        [self addSubview:self.placeHolderTextField];
    }
}

- (void)fm_placeHolder {
    if (!self.string.length){
//        self.placeHolderTextField = [self fm_addTextViewPlaceholderWithString:self.placeHolder textView:self];
        NSAttributedString *st = self.fm_attributedString;
//        [st drawAtPoint:NSMakePoint(5,2)];
        NSLog(@"text drawAtPoint：%@",st);

    }
}

- (void)viewWillDraw {
//     NSLog(@"placeHolder:%@",self.placeHolder);
//    [self fm_placeHolder];

}

- (void)setHolderColor:(NSColor *)holderColor
{
    objc_setAssociatedObject(self, @selector(holderColor), holderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSColor *)holderColor {
    return objc_getAssociatedObject(self, @selector(holderColor));
}

- (void)setHolderFont:(NSInteger)holderFont
{
    objc_setAssociatedObject(self, @selector(holderFont), @(holderFont), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)holderFont {
    return [objc_getAssociatedObject(self, @selector(holderFont)) integerValue];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    objc_setAssociatedObject(self, @selector(placeHolder), placeHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)placeHolder {
    return objc_getAssociatedObject(self, @selector(placeHolder));
}

- (void)setPlaceHolderTextField:(NSTextField *)placeHolderTextField {
    objc_setAssociatedObject(self, @selector(placeHolderTextField), placeHolderTextField, OBJC_ASSOCIATION_RETAIN);
}

- (NSTextField *)placeHolderTextField {
    return objc_getAssociatedObject(self, @selector(placeHolderTextField));
}

#pragma - mark 私有方法
- (NSAttributedString *)fm_attributedString {
    NSColor *txtColor = self.holderColor ? self.holderColor : NSColor.grayColor;
    NSInteger txtFontSize = self.holderFont ? self.holderFont : 14;
    NSFont *txtFont = [NSFont systemFontOfSize:txtFontSize];
    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName,txtFont,NSFontAttributeName, nil];
    NSAttributedString *pla = [[NSAttributedString alloc] initWithString:self.placeHolder attributes:txtDict];
    return pla;
}

- (NSTextField *)fm_addTextViewPlaceholderWithString:(NSString *)placeholder textView:(NSTextView *)textView {
    if (!placeholder.length) return nil;
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(5, 0, self.frame.size.width, 40)];
    [textField setEnabled:NO];
    [textField setBordered:NO];
    textField.backgroundColor = NSColor.clearColor;
    NSColor *txtColor = self.holderColor ? self.holderColor : NSColor.grayColor;
    NSInteger txtFontSize = self.holderFont ? self.holderFont : 14;
    NSFont *txtFont = [NSFont systemFontOfSize:txtFontSize];
    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName,txtFont,NSFontAttributeName, nil];
    NSAttributedString *pla = [[NSAttributedString alloc] initWithString:self.placeHolder attributes:txtDict];
    textField.placeholderAttributedString = pla;
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView addSubview:textField];
    });
    return textField;
}

- (void)fm_removePlaceholder:(NSTextField *)textField {
    textField.hidden = YES;
    [textField removeFromSuperview];
    textField = nil;
}

@end
