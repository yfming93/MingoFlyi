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
@property (strong) IBOutlet NSTextView *outputTextViewCiba;

@property (strong) IBOutlet NSButton *btnHumpSmall;
@property (strong) IBOutlet NSButton *btnUnderLineSmall;
@property (strong) IBOutlet NSButton *btnUnderLineBig;
@property (strong) IBOutlet NSButton *btnHumpBig;
@property (strong) IBOutlet NSButton *btnFilter;
@property (strong) IBOutlet NSTextField *tfFilter;
@property (strong) IBOutlet NSButton *clearButton;

@property (strong) IBOutlet NSButton *btnAutoCopyBaidu;
@property (strong) IBOutlet NSButton *btnAutoCopyYoudao;
@property (strong) IBOutlet NSButton *btnAutoCopyCiba;

@property (strong) IBOutlet NSButton *btnCopyBaidu;
@property (strong) IBOutlet NSButton *btnCopyYoudao;
@property (strong) IBOutlet NSButton *btnCopyCiba;

@property (strong) IBOutlet NSButton *btnWebGoogle;
@property (strong) IBOutlet NSTextField *tfPrefix; //前缀
@property (strong) IBOutlet NSButton *btnPrefix; //加前缀

@property (strong) IBOutlet WKWebView *webGoogle;
@property (weak) IBOutlet NSLayoutConstraint *webGoogle_w;

@property (strong) IBOutlet NSButton *btnWebSougou;
@property (strong) IBOutlet WKWebView *webSougou;
@property (weak) IBOutlet NSLayoutConstraint *webSougou_w;

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
    [_arrAutoCopys addObject:_btnAutoCopyCiba];

    _arrManuelCopys = NSMutableArray.array;
    [_arrManuelCopys addObject:_btnCopyBaidu];
    [_arrManuelCopys addObject:_btnCopyYoudao];
    [_arrManuelCopys addObject:_btnCopyCiba];

    
    _inputTextView.delegate = self;
    [_inputTextView setRichText:NO];
    [_inputTextView setFont:[NSFont systemFontOfSize:14]];
    [_inputTextView setTextColor:[NSColor blackColor]];
    
    _outputTextViewBaidu.editable = NO;
    _outputTextViewBaidu.delegate = self;
    _outputTextViewYoudao.editable = NO;
    _outputTextViewYoudao.delegate = self;
    _outputTextViewCiba.editable = NO;
    _outputTextViewCiba.delegate = self;
    
    _tfFilter.delegate = self;
    _pasteboard = [NSPasteboard generalPasteboard];
    
    [self fm_initSetting];
    
}

- (void)viewDidLayout {
    [self fm_webView];
    kUser.windowWidth = self.view.frame.size.width;

}


- (void)viewDidAppear {
    [super viewDidAppear];
}

-(void)fm_webGoogle {
    if (!kUser.isWebShowGoogle) return;
    _webGoogle.allowsBackForwardNavigationGestures = YES;
     _webGoogle.navigationDelegate = self;
     _webGoogle.UIDelegate = self;
    NSString *tem = self.inputTextView.string;
    BOOL isChinese = tem.isContainChinese;
    NSString *text = [self fm_formatForChinese:tem];
    text = [text lowercaseStringWithLocale:NSLocale.currentLocale];
//    text =
    //将待翻译的文字机型urf-8转码
    NSString *qEncoding = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"https://translate.google.cn/#auto/%@/%@",isChinese ? @"en":@"zh-CN",qEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webGoogle loadRequest:request];
}

-(void)fm_webSougou {
    if (!kUser.isWebShowSougou) return;
    _webSougou.allowsBackForwardNavigationGestures = YES;
     _webSougou.navigationDelegate = self;
     _webSougou.UIDelegate = self;
    NSString *tem = self.inputTextView.string;
    BOOL isChinese = tem.isContainChinese;
    NSString *text = [self fm_formatForChinese:tem];
    text = [text lowercaseStringWithLocale:NSLocale.currentLocale];
    //将待翻译的文字机型urf-8转码
    NSString *qEncoding = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"https://fanyi.sogou.com/?transfrom=auto&transto=%@&model=general&keyword=%@",isChinese ? @"en":@"zh",qEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webSougou loadRequest:request];
}


- (void)fm_webView {
    [self fm_webGoogle];
    [self fm_webSougou];
}

- (void)scrollWheel:(NSEvent *)event {
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
    self.btnWebGoogle.state = kUser.isWebShowGoogle;
    self.btnWebSougou.state = kUser.isWebShowSougou;
    self.webGoogle_w.constant = kUser.isWebShowGoogle ? kWebWidth : 0;
    self.webSougou_w.constant = kUser.isWebShowSougou ? kWebWidth : 0;
    self.view.frame = NSMakeRect(0, 20, kUser.windowWidth >0 ? kUser.windowWidth: 500 , 600);
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
    NSString *tempString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([text containsString:@"_"]) { /// 下划线拼接的英文
        tempString = [NSString fm_underLineStringToCommonString:text];
    }else if ([text componentsSeparatedByString:@" "].count > 1) { /// 空格符拼接的英文

    }else {
        tempString = [NSString fm_humpStringToCommonString:text]; // 驼峰拼接的英文
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
    
    [_serviceManager fm_requestWithString:tempString type:FanyiType_Ciba completedBlock:^(id response) {
        [weakSelf fm_resultFormat:response type:FanyiType_Ciba];
        NSLog(@"金山词霸翻译结果-------------:%@",response);
    }];
    
//    [_serviceManager fm_requestWithString:tempString type:FanyiType_Google completedBlock:^(id response) {
//        [weakSelf fm_resultFormat:response type:FanyiType_Google];
//        NSLog(@"谷歌翻译结果-------------:%@",response);
//    }];
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
        case FanyiType_Ciba:{
            [self.outputTextViewCiba.textStorage setAttributedString:attrContent];
        }
            break;
        case FanyiType_Google:{
            
        }
            break;
    }
    [self.outputTextViewBaidu.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewBaidu.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextViewYoudao.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewYoudao.textStorage setForegroundColor:[NSColor redColor]];
    [self.outputTextViewCiba.textStorage setFont:[NSFont systemFontOfSize:14]];
    [self.outputTextViewCiba.textStorage setForegroundColor:[NSColor redColor]];
    
    if (type == _btnAutoCopy.tag) { //自动复制
        [self fm_copyToPasteboard:result];
    }
}

- (void)fm_copyToPasteboard:(NSString *)result {
    [_pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:self];
    [_pasteboard clearContents];
    [_pasteboard setString:result forType:NSPasteboardTypeString];
}

- (IBAction)clearContent:(NSButton *)sender {
    NSMutableAttributedString * attrContent = [[NSMutableAttributedString alloc] initWithString:@""];
    [_inputTextView.textStorage setAttributedString:attrContent];
    [_outputTextViewBaidu.textStorage setAttributedString:attrContent];
    [_outputTextViewYoudao.textStorage setAttributedString:attrContent];
}


- (IBAction)filterAction:(NSButton *)sender {
    [self fm_requetFanyi:_inputTextView.string];
    kUser.isFliter = sender.state;
}

- (IBAction)prefixAction:(NSButton *)sender {
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
        case FanyiType_Ciba:
            [self fm_copyToPasteboard:self.outputTextViewCiba.string];
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
        case FanyiType_Ciba:
            [self fm_copyToPasteboard:self.outputTextViewCiba.string];
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


- (IBAction)btnWebShowActions:(NSButton *)sender {
    [self.view.window makeFirstResponder:nil];
    CGFloat w  = kUser.windowWidth;
    self.view.window.restorable = NO;

    if (sender.tag  == 1) {
        kUser.isWebShowSougou = !kUser.isWebShowSougou;
        if (self.webSougou_w.constant > 0) {
            self.webSougou_w.constant = 0;
            [self.view.window setContentSize:NSMakeSize(w - kWebWidth , CGRectMinYEdge)];
        }else{
            self.webSougou_w.constant = kWebWidth;
            [self.view.window setContentSize:NSMakeSize(w + kWebWidth , CGRectMinYEdge)];
        }

    }else if (sender.tag  == 2) {
        kUser.isWebShowGoogle = !kUser.isWebShowGoogle;
        if (self.webGoogle_w.constant > 0) {
            self.webGoogle_w.constant = 0;
            [self.view.window setContentSize:NSMakeSize(w - kWebWidth , CGRectMinYEdge)];

        }else{
            self.webGoogle_w.constant = kWebWidth;
            [self.view.window setContentSize:NSMakeSize(w + kWebWidth , CGRectMinYEdge)];
        }
    }else {
        
    }
    [self viewDidLayout];
   
   	[self fm_webView];
}


    

@end
