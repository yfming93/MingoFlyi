//
//  FMHomeViewController.m
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/7.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import "FMHomeViewController.h"
#import "FMServiceManager.h"
#import "YLGoogleTranslate.h"
#import <WebKit/WebKit.h>

#define kWebWidth 320

@interface FMHomeViewController () <NSTextViewDelegate,NSTextFieldDelegate,WKNavigationDelegate,WKUIDelegate>

@property (strong) IBOutlet NSScrollView *inputContentScrollView;
@property (strong) IBOutlet NSTextView *inputTextView;
@property (strong) IBOutlet NSScrollView *outputContentScrollView;
@property (strong) IBOutlet NSTextView *outputTextViewBaidu;
@property (strong) IBOutlet NSTextView *outputTextViewYoudao;
@property (strong) IBOutlet NSTextView *outputTextViewGoogle;

@property (strong) IBOutlet NSButton *btnHumpSmall;
@property (strong) IBOutlet NSButton *btnUnderLineSmall;
@property (strong) IBOutlet NSButton *btnUnderLineBig;
@property (strong) IBOutlet NSButton *btnHumpBig;
@property (strong) IBOutlet NSButton *btnFilter;
@property (strong) IBOutlet NSTextField *tfFilter;
@property (strong) IBOutlet NSButton *clearButton;

@property (strong) IBOutlet NSButton *btnAutoCopyBaidu;
@property (strong) IBOutlet NSButton *btnAutoCopyYoudao;
@property (strong) IBOutlet NSButton *btnAutoCopyGoogle;

@property (strong) IBOutlet NSButton *btnCopyBaidu;
@property (strong) IBOutlet NSButton *btnCopyYoudao;
@property (strong) IBOutlet NSButton *btnCopyGoogle;

@property (strong) IBOutlet NSButton *btnMore;
@property (strong) IBOutlet NSTextField *tfPrefix; //前缀
@property (strong) IBOutlet NSButton *btnPrefix; //加前缀
@property (strong) IBOutlet WKWebView *webView;
@property (weak) IBOutlet NSLayoutConstraint *webGoogle_w;


@end

@implementation FMHomeViewController
{
    FMServiceManager *_serviceManager;
    NSPasteboard *_pasteboard;
    NSButton *_btnSelectedFanyi;
    NSButton *_btnAutoCopy;
    NSMutableArray *_arrBtns;
    NSMutableArray *_arrAutoCopys;
    NSMutableArray *_arrManuelCopys;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _serviceManager = FMServiceManager.shareInstance;
    
    _arrBtns = NSMutableArray.array;
    [_arrBtns addObject:_btnHumpSmall];
    [_arrBtns addObject:_btnHumpBig];
    [_arrBtns addObject:_btnUnderLineSmall];
    [_arrBtns addObject:_btnUnderLineBig];
    _btnSelectedFanyi = _btnHumpSmall;
    
    _arrAutoCopys = NSMutableArray.array;
    [_arrAutoCopys addObject:_btnAutoCopyBaidu];
    [_arrAutoCopys addObject:_btnAutoCopyYoudao];
    [_arrAutoCopys addObject:_btnAutoCopyGoogle];

    _arrManuelCopys = NSMutableArray.array;
    [_arrManuelCopys addObject:_btnCopyBaidu];
    [_arrManuelCopys addObject:_btnCopyYoudao];
    [_arrManuelCopys addObject:_btnCopyGoogle];

    
    _inputTextView.delegate = self;
    [_inputTextView setRichText:NO];
    [_inputTextView setFont:[NSFont systemFontOfSize:14]];
    [_inputTextView setTextColor:[NSColor blackColor]];
    
    _outputTextViewBaidu.editable = NO;
    _outputTextViewBaidu.delegate = self;
    _outputTextViewYoudao.editable = NO;
    _outputTextViewYoudao.delegate = self;
    _outputTextViewGoogle.editable = NO;
    _outputTextViewGoogle.delegate = self;
    
    _tfFilter.delegate = self;
    _pasteboard = [NSPasteboard generalPasteboard];
    
    [_clearButton setTarget:self];
    [_clearButton setAction:@selector(clearContent:)];
    
    [_btnPrefix setTarget:self];
    [_btnPrefix setAction:@selector(prefixAction:)];
    
    [_btnFilter setTarget:self];
    [_btnFilter setAction:@selector(filterAction:)];
    
    
    [_btnMore setTarget:self];
    [_btnMore setAction:@selector(moreAction:)];
    
    [self fm_initSetting];
    
}

- (void)viewDidLayout {
    [self fm_webView];
    kUser.windowWidth = self.view.frame.size.width;

}


- (void)viewDidAppear {
    [super viewDidAppear];
}

- (void)fm_webView {
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    BOOL isChinese = self.inputTextView.string.isContainChinese;
    NSString *text = [self fm_formatForChinese:self.inputTextView.string];
	//将待翻译的文字机型urf-8转码
    NSString *qEncoding = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"https://translate.google.cn/#auto/%@/%@",isChinese ? @"en":@"zh-CN",qEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
}

- (void)scrollWheel:(NSEvent *)event {
        // pass web view scroll events to the next responder. comment
        // this line out if you just want to disable scrolling
        // altogether.
        //
    [[self nextResponder] scrollWheel:event];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
}

    // 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
    // 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
    // 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
        //showAlert()是js里面的方法,这样就可以实现调用js方法
    [self.webView evaluateJavaScript:@"showAlert('奏是一个弹框')" completionHandler:^(id item, NSError * _Nullable error) {
            // Block中处理是否通过了或者执行JS错误的代码
    }];
    if (webView.subviews){
//        NSScrollView* scrollView = [[self.webView subviews] objectAtIndex:0];
//        if ([scrollView hasVerticalScroller]) {
//            scrollView.verticalScroller.floatValue = 0;
//        }
//            // Scroll the contentView to top
//        [scrollView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)scrollView.documentView).frame.size.height - scrollView.contentSize.height)];
    }
    
}
    // 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}


-(void)fm_initSetting {
    User *user = FMSetting.fm_get;
    kUser = user;
    self.tfPrefix.stringValue = kUser.prefixText;
    self.tfFilter.stringValue = kUser.filterText;
    self.btnPrefix.state = kUser.isPrefix;
    self.btnFilter.state = kUser.isFliter;
    self.btnMore.state = kUser.isWebShow;
    self.webGoogle_w.constant = kUser.isWebShow ? kWebWidth : 0;
    self.view.frame = NSMakeRect(0, 0, kUser.windowWidth >0 ? kUser.windowWidth: 500 , 600);
    
    for (NSButton *btn in _arrBtns) {
        [btn setTarget:self];
        [btn setAction:@selector(selectAction:)];
        if (btn.tag == kUser.indexFanyi) {
            btn.state = YES;
            _btnSelectedFanyi = btn;
        }else{
            btn.state = NO;
        }
    }
    
    for (NSButton *btn in _arrManuelCopys) {
        [btn setTarget:self];
        [btn setAction:@selector(clickCopyAction:)];
        if (btn.tag == kUser.indexManuelCopy) {
            btn.state = YES;
        }else{
            btn.state = NO;
        }
    }
    
    for (NSButton *btn in _arrAutoCopys) {
        [btn setTarget:self];
        [btn setAction:@selector(autoCopyAction:)];
        
        if (btn.tag == kUser.indexAutoCopy) {
            btn.state = YES;
            _btnAutoCopy = btn;
        }else{
           btn.state = NO;
       }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
}

- (void)dealloc {
    NSLog(@"FMHomeViewController dealloc");
    [FMSetting fm_save];
}

//- (NSTextField *)addTextViewPlaceholderWithString:(NSString *)placeholder textView:(NSTextView *)textView {
//    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(15, 0, 220, 40)];
//    [textField setEnabled:NO];
//    [textField setBordered:NO];
//    textField.placeholderString = placeholder;
//    [textView addSubview:textField];
//    return textField;
//}

//- (void)removePlaceholder:(NSTextField *)textField {
//    [textField removeFromSuperview];
//    textField = nil;
//}

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == _inputTextView) {
        [self fm_requetFanyi:_inputTextView.string];
    }
    
}

- (void)textDidEndEditing:(NSNotification *)notification {
//    if (notification.object == _inputTextView) {
//        [self fm_requetFanyi:_inputTextView.string];
//    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    
    if (obj.object == _tfFilter) {
        [self fm_requetFanyi:_inputTextView.string];
        kUser.filterText = _tfFilter.stringValue;
    }else  if (obj.object == _tfPrefix) {
        [self fm_requetFanyi:_inputTextView.string];
        kUser.prefixText = _tfPrefix.stringValue;
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

///// 翻译请求
//- (void)fm_requet {
//    NSString *content = @"控制变量法怎么样啊";
//    NSString *targetLanguage = @"zh-CN";
//    YLGoogleTranslate *googleTrans = [[YLGoogleTranslate alloc] init];
//    [googleTrans translateWithText:content targetLanguageCode:targetLanguage completion:^(NSString * _Nullable originalText, NSString * _Nullable originalLanguageCode, NSString * _Nullable translatedText, NSString * _Nullable targetLanguageCode, NSString * _Nullable error) {
//        if ([error length] > 0) {
//            NSLog(@"调用Google翻译接口返回错误：%@ ", error);
//        } else {
//            NSLog(@"调用Google翻译接口返回成功！");
//        }
//    }];
//}

/// 翻译请求
- (void)fm_requetFanyi:(NSString *)str {
    NSString *text = str;
    if (text.length <= 0) {
        return;
    }
//    [self fm_requet];
    NSString *tempString = [self fm_formatForChinese:str];
    __weak typeof(self) weakSelf = self;
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Baidu completedBlock:^(id response) {
        NSLog(@"百度翻译结果-------------:%@",response);
        [weakSelf fm_resultFormat:response type:FanyiType_Baidu];
    }];
    
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Youdao completedBlock:^(id response) {
        [weakSelf fm_resultFormat:response type:FanyiType_Youdao];
        NSLog(@"有道翻译结果-------------:%@",response);
    }];
    
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Google completedBlock:^(id response) {
        [weakSelf fm_resultFormat:response type:FanyiType_Google];
        NSLog(@"谷歌翻译结果-------------:%@",response);
    }];
    [self fm_webView];
}

/// 结果过滤
- (NSString *)fm_filter:(NSString *)str {
    if (!self.tfFilter.stringValue.length) return str;
    if (!self.btnFilter.state) return str;
    NSString * result = [str lowercaseStringWithLocale:NSLocale.currentLocale];
    NSString * smallfilter = [self.tfFilter.stringValue lowercaseStringWithLocale:NSLocale.currentLocale];
    NSArray *outCharts = @[@"，",@";",@"；",@"。",@"、",@"/",@"|",@"\\"];
    for (NSString *str in outCharts) {
        if ([smallfilter containsString:str]) {
            smallfilter = [smallfilter stringByReplacingOccurrencesOfString:str withString:@","];
        }
    }
    NSMutableArray *arrTitels = [result componentsSeparatedByString:@" "].mutableCopy;
    NSMutableArray *arrFilter = [smallfilter componentsSeparatedByString:@","].mutableCopy;
    for (NSString *str in arrFilter) {
        NSString *tem = [NSString stringWithFormat:@"%@",str];
        if ([result containsString:tem] && (![tem isEqualToString:@" "]) && (![tem isEqualToString:@""])) {
            [arrTitels removeObject:tem];
        }
    }
    result = [arrTitels componentsJoinedByString:@" "];
    return result;
}

- (NSString *)fm_addPrefix:(NSString *)result {
    NSString *res = result.mutableCopy;
    NSMutableArray *arrTitels = [res componentsSeparatedByString:@" "].mutableCopy;
    if (self.btnPrefix.state) {
        if (self.tfPrefix.stringValue.length) {
            [arrTitels insertObject:self.tfPrefix.stringValue atIndex:0];
        }
    }
    res = [arrTitels componentsJoinedByString:@" "];
    return res;
}

- (void)fm_resultFormat:(NSString *)resultStr type:(FanyiType)type {
    if (!resultStr.length) return;
    NSString *result = [self fm_filter:resultStr];
    result = [self fm_addPrefix:result];
    
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
        case FanyiType_Google:{
            [self.outputTextViewGoogle.textStorage setAttributedString:attrContent];
        }
            break;
    }
    [self.outputTextViewBaidu.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewBaidu.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextViewYoudao.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewYoudao.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextViewGoogle.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewGoogle.textStorage setForegroundColor:[NSColor redColor]];
    
    if (type == _btnAutoCopy.tag) {
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
    [_outputTextViewYoudao.textStorage setAttributedString:attrContent];
}

- (void)filterAction:(NSButton *)sender {
    [self fm_requetFanyi:_inputTextView.string];
    kUser.isFliter = sender.state;
}

- (void)prefixAction:(NSButton *)sender {
    [self fm_requetFanyi:_inputTextView.string];
    kUser.isPrefix = sender.state;
}

// 自动复制
- (void)autoCopyAction:(NSButton *)sender {
    [self.view.window makeFirstResponder:nil];
    if (sender.tag == _btnAutoCopy.tag) {
        kUser.indexAutoCopy = sender.state == NSControlStateValueOn ? sender.tag : 0;
    }else{
        _btnAutoCopy.state = NO;
         sender.state = YES;
         _btnAutoCopy = sender;
         kUser.indexAutoCopy = sender.tag;
 
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
    [FMSetting fm_save];

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
    [self.view.window makeFirstResponder:nil];
    
    if (![sender isEqualTo:_btnSelectedFanyi]) {
        _btnSelectedFanyi.state = NO;
        sender.state = YES;
        _btnSelectedFanyi = sender;
        kUser.indexFanyi = sender.tag;
    }else{
        kUser.indexFanyi = sender.state == NSControlStateValueOn ? sender.tag : 0;
    }
    [self fm_requetFanyi:_inputTextView.string];
}


- (void)moreAction:(NSButton *)sender {
    kUser.isWebShow = !kUser.isWebShow;
    [self.view.window makeFirstResponder:nil];
    
    if (self.webGoogle_w.constant > 0) {
        self.webGoogle_w.constant = 0;
    }else{
        self.webGoogle_w.constant = kWebWidth;
    }
    [self fm_webView];
}
    

    

@end
