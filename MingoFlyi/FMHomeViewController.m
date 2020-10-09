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
@property (strong) IBOutlet NSTextView *outputTextViewBaidu;
@property (strong) IBOutlet NSTextView *outputTextViewYoudao;

@property (strong) IBOutlet NSButton *btnHumpSmall;
@property (strong) IBOutlet NSButton *btnCopy;
@property (strong) IBOutlet NSButton *btnUnderLineSmall;
@property (strong) IBOutlet NSButton *btnUnderLineBig;
@property (strong) IBOutlet NSButton *btnHumpBig;
@property (strong) IBOutlet NSButton *btnFilter;
@property (strong) IBOutlet NSTextField *tfFilter;
@property (strong) IBOutlet NSButton *clearButton;

@property (strong) IBOutlet NSButton *btnAutoCopyBaidu;
@property (strong) IBOutlet NSButton *btnAutoCopyYoudao;
@property (strong) IBOutlet NSButton *btnCopyBaidu;
@property (strong) IBOutlet NSButton *btnCopyYoudao;



@end

@implementation FMHomeViewController
{
    FMServiceManager *_serviceManager;
    NSPasteboard *_pasteboard;
    NSButton *_btnSelected;
    NSButton *_btnAutoCopy;
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
    
    NSMutableArray *arrCopys = NSMutableArray.array;
    [arrCopys addObject:_btnAutoCopyBaidu];
    [arrCopys addObject:_btnAutoCopyYoudao];
    for (NSButton *btn in arrCopys) {
        [btn setTarget:self];
        [btn setAction:@selector(autoCopyAction:)];
    }
    
    NSMutableArray *arrCopysManuel = NSMutableArray.array;
    [arrCopysManuel addObject:_btnCopyBaidu];
    [arrCopysManuel addObject:_btnCopyYoudao];
    for (NSButton *btn in arrCopysManuel) {
        [btn setTarget:self];
        [btn setAction:@selector(clickCopyAction:)];
    }
    
    _inputTextView.delegate = self;
    [_inputTextView setRichText:NO];
    [_inputTextView setFont:[NSFont systemFontOfSize:14]];
    [_inputTextView setTextColor:[NSColor blackColor]];
    
    _outputTextViewBaidu.editable = NO;
    _outputTextViewBaidu.delegate = self;

    _outputTextViewYoudao.editable = NO;
    _outputTextViewYoudao.delegate = self;


  
    
    _pasteboard = [NSPasteboard generalPasteboard];
    
    [_clearButton setTarget:self];
    [_clearButton setAction:@selector(clearContent:)];
    
    _btnAutoCopy = _btnAutoCopyBaidu;
    [_btnAutoCopyBaidu setTarget:self];
    [_btnAutoCopyBaidu setAction:@selector(autoCopyAction:)];

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
        [weakSelf fm_resultFormat:response type:FanyiType_Baidu];
    }];
    
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Youdao completedBlock:^(id response) {
        if (!response) {
            return;
        }
        [weakSelf fm_resultFormat:response type:FanyiType_Youdao];
        NSLog(@"youdao:%@",response);
    }];
}

- (void)fm_resultFormat:(NSString *)resultStr type:(FanyiType)type {
//    [self.outputTextViewBaidu.textStorage beginEditing];
    
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
   
    [self writeDataToThePasteboardWithString:result type:type];

}


- (void)writeDataToThePasteboardWithString:(NSString *)result type:(FanyiType)type  {
    NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",result]];
    switch (type) {
        case FanyiType_Baidu:{
            [self.outputTextViewBaidu.textStorage setAttributedString:attrContent];

        }
            break;
        case FanyiType_Youdao:{
            [self.outputTextViewYoudao.textStorage setAttributedString:attrContent];
        }
            break;
    }
    [self.outputTextViewBaidu.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewBaidu.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextViewYoudao.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewYoudao.textStorage setForegroundColor:[NSColor redColor]];
    
    if (type == FanyiType_Baidu ? _btnAutoCopyBaidu.state : type == FanyiType_Youdao ? _btnAutoCopyYoudao.state : NO) {
        [self fm_copyToPasteboard:result];
    }
}

- (void)fm_copyToPasteboard:(NSString *)result {
    [_pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [_pasteboard clearContents];
    [_pasteboard setString:result forType:NSPasteboardTypeString];
}


- (void)clearContent:(NSButton *)sender {
    NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:@""];
    [_inputTextView.textStorage setAttributedString:attrContent];
    [_outputTextViewBaidu.textStorage setAttributedString:attrContent];
}

// 自动复制
- (void)autoCopyAction:(NSButton *)sender {
    if (![sender isEqualTo:_btnAutoCopy]) {
        _btnAutoCopy.state = NO;
        sender.state = YES;
        _btnAutoCopy = sender;
    }else{
        _btnAutoCopy.state = !_btnAutoCopy.state;
    }
    switch (sender.tag) {
        case FanyiType_Baidu:
            [self fm_copyToPasteboard:self.outputTextViewBaidu.string];
            break;
        case FanyiType_Youdao:
            [self fm_copyToPasteboard:self.outputTextViewYoudao.string];
            break;
        default:
            break;
    }
}

// 手动点击复制
- (void)clickCopyAction:(NSButton *)sender {
    switch (sender.tag) {
        case FanyiType_Baidu:
            [self fm_copyToPasteboard:self.outputTextViewBaidu.string];
            break;
        case FanyiType_Youdao:
            [self fm_copyToPasteboard:self.outputTextViewYoudao.string];
            break;
        default:
            break;
    }
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
