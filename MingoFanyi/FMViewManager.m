//
//  FMViewManager.m
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/8.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import "FMViewManager.h"
#import "FMServiceManager.h"
#import "NSString+FYIHumpString.h"

@interface FMViewManager () <NSTextViewDelegate>

@property (nonatomic, strong) NSTextView *inputTextView;
@property (nonatomic, strong) NSTextView *outputTextView;;

@end

@implementation FMViewManager
{
    NSScrollView *_inputScrollView;
    NSScrollView *_outputScrollView;
    FMServiceManager *_serviceManager;
    NSPasteboard *_pasteboard;
    NSButton *_btnCopy;
    NSButton *_btnSelected;
    NSButton *_btnUnderLineSmall;
    NSButton *_btnUnderLineBig;
    NSButton *_btnHumpSmall;
    NSButton *_btnHumpBig;
    NSMutableArray *_arrBtns;
}

- (instancetype)initViewManagerWithInputScrollView:(NSScrollView *)inputScrollView
                                     inputTextView:(NSTextView *)inputTextView
                                  outputScrollView:(NSScrollView *)outputScrollView
                                       outTextView:(NSTextView *)outputTextView
                       btnHumpSmall:(NSButton *)btnHumpSmall
                              btnCopy:(NSButton *)copyModeButton
                              btnUnderLineSmall:(NSButton *)btnUnderLineSmall
                                btnUnderLineBig:(NSButton *)btnUnderLineBig
                                     btnHumpBig:(NSButton *)btnHumpBig
                                       clearButton:(NSButton *)clearButton {
    if (self = [super init]) {
        _inputScrollView = inputScrollView;
        _outputScrollView = outputScrollView;
        self.inputTextView = inputTextView;
        self.outputTextView = outputTextView;
        _btnCopy = copyModeButton;
        _btnHumpSmall = btnHumpSmall;
        _btnHumpBig = btnHumpBig;
        _btnUnderLineSmall = btnUnderLineSmall;
        _btnUnderLineBig = btnUnderLineBig;
        
        _arrBtns = NSMutableArray.array;
        [_arrBtns addObject:_btnHumpSmall];
        [_arrBtns addObject:_btnHumpBig];
        [_arrBtns addObject:_btnUnderLineSmall];
        [_arrBtns addObject:_btnUnderLineBig];
        _btnSelected = _btnHumpSmall;
        

        _inputTextView.delegate = self;
        _outputTextView.delegate = self;

        _outputTextView.editable = NO;
        [_inputTextView setRichText:NO];
        [_inputTextView setFont:[NSFont systemFontOfSize:14]];
        [_inputTextView setTextColor:[NSColor blackColor]];
        
        _pasteboard = [NSPasteboard generalPasteboard];
        
        [clearButton setTarget:self];
        [clearButton setAction:@selector(clearContent:)];
        
        for (NSButton *btn in _arrBtns) {
            [btn setTarget:self];
            [btn setAction:@selector(selectAction:)];
        }
    }
    return self;
}



- (NSTextField *)addTextViewPlaceholderWithString:(NSString *)placeholder textView:(NSTextView *)textView {
     NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(15, 0, 220, 40)];
    [textField setEnabled:NO];
    [textField setBordered:NO];
    textField.placeholderString = placeholder;
    [textView addSubview:textField];
    return textField;
}

- (void)removePlaceholder:(NSTextField *)textField {
    [textField removeFromSuperview];
    textField = nil;
}

- (void)textDidChange:(NSNotification *)notification {

    if (notification.object == _inputTextView) {
        _serviceManager = FMServiceManager.sharedFMServiceManager;
        [self fm_requetFanyi:_inputTextView.string];
    }
      
}


- (NSString *)fm_formatForChinese:(NSString *)text {
    
    NSString *tempString;
    
    if ([text containsString:@"_"]) {
        tempString = [NSString fm_underLineStringToCommonString:text];
    }else {
        tempString = [NSString fm_humpStringToCommonString:text];
    }
    
    return tempString;
    
}

- (void)fm_requetFanyi:(NSString *)str {
    NSString *text = str;
    if (text.length <= 0) {
        return;
    }

    NSString *tempString = [self fm_formatForChinese:str];
    
    __weak typeof(self) weakSelf = self;
    [_serviceManager requestDataWithTextString:tempString
                                          data:^(id response) {
                                              if (!response) {
                                                  return;
                                              }
                                              __strong typeof(self) strongSelf = weakSelf;
                                              if (strongSelf) {
                                                  
                                                  [strongSelf.outputTextView.textStorage beginEditing];
                                                  NSString *result;
                                                  if (_btnHumpSmall.state) {
                                                      result = [NSString commonStringToHumpString:response[0] isCapitalized:NO];
                                                      
                                                  }else if (_btnHumpBig.state) {
                                                      result = [NSString commonStringToHumpString:response[0] isCapitalized:YES];
                                                      
                                                  } else if (_btnUnderLineSmall.state) {
                                                      result = [NSString fm_commonStringToUnderLineString:response[0] isCapitalized:NO];
                                                      
                                                  }else if (_btnUnderLineBig.state) {
                                                      result = [NSString fm_commonStringToUnderLineString:response[0] isCapitalized:YES];
                                                  }else {
                                                      result = response[0];
                                                  }
                                                  NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",result]];
                                                  [strongSelf.outputTextView.textStorage setAttributedString:attrContent];
                                                  [strongSelf.outputTextView.textStorage setFont:[NSFont systemFontOfSize:14]];
                                                  [strongSelf.outputTextView.textStorage setForegroundColor:[NSColor redColor]];
                                                  [strongSelf.outputTextView.textStorage endEditing];
                                                  if (_btnCopy.state) {
                                                      [strongSelf writeDataToThePasteboardWithString:result];
                                                  }
                                              }
    }];
    
}

- (void)writeDataToThePasteboardWithString:(NSString *)data {
    [_pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [_pasteboard clearContents];
    [_pasteboard setString:data forType:NSStringPboardType];
}

- (void)clearContent:(NSButton *)sender {
    NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:@""];
    [_inputTextView.textStorage setAttributedString:attrContent];
    [_outputTextView.textStorage setAttributedString:attrContent];
}

- (void)selectAction:(NSButton *)sender {
    if (![sender isEqualTo:_btnSelected]) {
        _btnSelected.state = NO;
        sender.state = YES;
        _btnSelected = sender;
    } else {
//        sender.state = YES;
//        _btnSelected = sender;
    }
    [self fm_requetFanyi:_inputTextView.string];

    
}

@end
