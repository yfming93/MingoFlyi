//
//  NSTextView+FMPlaceHolder.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "NSTextView+FMPlaceHolder.h"
#import <objc/runtime.h>

//static NSTextField *placeHolderTextField;

@interface NSTextView ()

@property (nonatomic, strong) NSTextField *placeHolderTextField;
@end

@implementation NSTextView (FMPlaceHolder)
@dynamic placeHolder,holderColor,holderFont;

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self fm_initPlaceHolder];
}
+ (void)initialize
{
    if (self == [NSTextView class]) {
//    [self.placeHolderTextField.placeholderAttributedString drawAtPoint:NSMakePoint(0,0)];
        [NSTextView.new fm_initPlaceHolder];

    }
}



- (void)fm_initPlaceHolder {
    [self fm_removePlaceholder:self.placeHolderTextField];
    self.placeHolderTextField = [self fm_addTextViewPlaceholderWithString:self.placeHolder textView:self];
    [self addSubview:self.placeHolderTextField];
}

- (void)fm_placeHolder {
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.string.length){
            self.placeHolderTextField.hidden = YES;
            NSLog(@"placeHolderTextField:%@",self.placeHolderTextField.description);

        }else{
            self.placeHolderTextField.hidden = NO;

        }
    });
    
//    if ([[self string] isEqualToString:@""] && self != [[self window] firstResponder])
//        [self.placeHolderTextField.placeholderAttributedString drawAtPoint:NSMakePoint(0,0)];
}

- (void)controlTextDidChange:(NSNotification *)note {

}


//- (void)drawRect:(NSRect)rect {
//    [super drawRect:rect];
//    NSLog(@"placeHolder1:%@",self.placeHolder);
//    [self fm_placeHolder];
//
//}


- (void)viewWillDraw {
     NSLog(@"placeHolder:%@",self.placeHolder);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//        });
//    });

    [self fm_placeHolder];

}


- (BOOL)becomeFirstResponder {
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
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
