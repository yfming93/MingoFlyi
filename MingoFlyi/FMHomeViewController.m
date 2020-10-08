//
//  FMHomeViewController.m
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/7.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import "FMHomeViewController.h"
#import "FMServiceManager.h"
#import "NSString+FMAdd.h"
#import "Tools.h"

@interface FMHomeViewController () <NSTextViewDelegate>

@property (strong) IBOutlet NSScrollView *inputContentScrollView;
@property (strong) IBOutlet NSTextView *inputTextView;
@property (strong) IBOutlet NSScrollView *outputContentScrollView;
@property (strong) IBOutlet NSTextView *outputTextView;
@property (strong) IBOutlet NSButton *btnHumpSmall;
@property (strong) IBOutlet NSButton *btnCopy;
@property (strong) IBOutlet NSButton *btnUnderLineSmall;
@property (strong) IBOutlet NSButton *btnUnderLineBig;
@property (strong) IBOutlet NSButton *btnHumpBig;
@property (strong) IBOutlet NSButton *btnFilter;
@property (strong) IBOutlet NSTextField *tfFilter;
@property (strong) IBOutlet NSButton *clearButton;


@end

@implementation FMHomeViewController
{
    FMServiceManager *_serviceManager;
    NSPasteboard *_pasteboard;
    NSButton *_btnSelected;
    NSMutableArray *_arrBtns;
    NSMutableArray *_arrFilter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [_clearButton setTarget:self];
    [_clearButton setAction:@selector(clearContent:)];
    
    for (NSButton *btn in _arrBtns) {
        [btn setTarget:self];
        [btn setAction:@selector(selectAction:)];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
}

- (void)dealloc {
    NSLog(@"FMHomeViewController dealloc");
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

// 将各种翻译的结果 转换 为 分割 空格的字符串
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
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Baidu completedBlock:^(id response) {
        if (!response) {
            return;
        }
//        [weakSelf fm_resultFormat:response];
    }];
    
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Youdao completedBlock:^(id response) {
        if (!response) {
            return;
        }
        [weakSelf fm_resultFormat:response];
        NSLog(@"youdao:%@",response);
    }];
}

- (void)fm_resultFormat:(NSString *)resultStr {
    [self.outputTextView.textStorage beginEditing];
    
    NSString *result = resultStr;
    result = [result lowercaseStringWithLocale:NSLocale.currentLocale];

    _arrFilter = [self.tfFilter.stringValue componentsSeparatedByString:@","].mutableCopy;
    for (NSString *str in _arrFilter) {
        if ([result containsString:str]) {
            NSRange range = NSMakeRange([result rangeOfString:str].location,
                                           [result rangeOfString:str].length+ 1);
            result = [result stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    
    
    if (_btnHumpSmall.state) {
        result = [NSString commonStringToHumpString:result isCapitalized:NO];

    }else if (_btnHumpBig.state) {
        result = [NSString commonStringToHumpString:result isCapitalized:YES];

    } else if (_btnUnderLineSmall.state) {
        result = [NSString fm_commonStringToUnderLineString:result isCapitalized:NO];

    }else if (_btnUnderLineBig.state) {
        result = [NSString fm_commonStringToUnderLineString:result isCapitalized:YES];
    }
    NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",result]];
    [self.outputTextView.textStorage setAttributedString:attrContent];
    [self.outputTextView.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextView.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextView.textStorage endEditing];
    if (_btnCopy.state) {
        [self writeDataToThePasteboardWithString:result];
    }
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

// 选择翻译模式
- (void)selectAction:(NSButton *)sender {
    if (![sender isEqualTo:_btnSelected]) {
        _btnSelected.state = NO;
        sender.state = YES;
        _btnSelected = sender;
    }
    [self fm_requetFanyi:_inputTextView.string];
}

@end
