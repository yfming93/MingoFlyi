//
//  FMTextViewPlaceHolder.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/30.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMTextViewPlaceHolder.h"

@interface FMTextViewPlaceHolder ()
/// 占位符文本
@property (nonatomic, strong) NSAttributedString *placeHolderString;
@end

@implementation FMTextViewPlaceHolder

//+ (void)initialize
//{
//    static BOOL initialized = NO;
//    if (!initialized) {
//
//    }
//}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self fm_init];
}

- (void)layoutSubtreeIfNeeded {
//    [self fm_init];

}

-(void)fm_init {
    NSColor *txtColor = self.holderColor ? self.holderColor : NSColor.grayColor;
    NSInteger txtFontSize = self.holderFont ? self.holderFont : 14;
    NSFont *txtFont = [NSFont systemFontOfSize:txtFontSize];
    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName,txtFont,NSFontAttributeName, nil];
    NSAttributedString *pla = [[NSAttributedString alloc] initWithString:self.placeHolder.length ? self.placeHolder : @"" attributes:txtDict];
    _placeHolderString = pla;
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if (!self.string.length){
        [self.placeHolderString drawAtPoint:NSMakePoint(5,2)];

    }
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}

@end
