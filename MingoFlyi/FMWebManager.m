//
//  FMWebManager.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMWebManager.h"

@interface FMWebManager () <WKNavigationDelegate,WKUIDelegate>
@property (strong)  NSView *webBack;
@property (strong)  NSLayoutConstraint *webBack_w;

@property (strong)  NSView *webActionsBack;
@property (strong)  NSLayoutConstraint *webActionsBack_h;
@property (strong)  NSLayoutConstraint *webActionsBack_w;
@property (strong)  NSString *requestText;

@end

@implementation FMWebManager
+ (FMSetting *)shareInstance {
    static FMSetting *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arrWebActions = NSMutableArray.array;
        self.arrWebs = NSMutableArray.array;
        kWeakSelf
        [FMNotifyManager fm_addObserver:self identifier:kNotifyNameReloadSetting mainThread:YES actionBlock:^(id observer, id object) {
            NSLog(@"kNotifyNameReloadSetting--");
            [weakSelf fm_initWebs];
        }];
    }
    return self;
}

- (void)fm_layoutvWebback:(NSView *)webBack webBackWidth:(NSLayoutConstraint *)webBack_w webActionsBack:(NSView *)webActionsBack webActionsBackHight:(NSLayoutConstraint *)webActionsBack_h webActionsBackWidth:(NSLayoutConstraint *)webActionsBack_w requestText:(NSString *)requestText {
    self.webBack = webBack;
    self.webBack_w = webBack_w;
    self.webActionsBack = webActionsBack;
    self.webActionsBack_h = webActionsBack_h;
    self.webActionsBack_w = webActionsBack_w;
    self.requestText = requestText;
    [self fm_initWebs];
}

-(void)fm_initWebs {
    [self.arrWebs removeAllObjects];
    [self.arrWebActions removeAllObjects];
    [self.webBack removeAllSubviews];
    [self.webActionsBack removeAllSubviews];
    

    for (NSInteger i = 0; i < kUser.webModels.count; i++) {
        FMWebModel *mo = kUser.webModels[i];
        WKWebView *web = WKWebView.alloc.init;
        web.allowsBackForwardNavigationGestures = YES;
        web.navigationDelegate = self;
        web.UIDelegate = self;
        NSString *tem = self.requestText;
        BOOL isChinese = tem.isContainChinese;
        NSString *text = [tem fm_formatForChinese:tem];
        text = [text lowercaseStringWithLocale:NSLocale.currentLocale];
        //将待翻译的文字机型urf-8转码
        NSString *qEncoding = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *url = mo.urlHost;
//        NSLog(@"urlHost----:%@",mo.urlHost);
        NSLog(@"urlHost----:%@",mo.urlHostInput);
        if ([mo.urlHost fm_getDuplicateSubStrCountInCompleteStr:mo.urlHost withSubStr:@"%@"] == 1) {
            url = [NSString stringWithFormat:mo.urlHost,qEncoding];
        }else if ([mo.urlHost fm_getDuplicateSubStrCountInCompleteStr:mo.urlHost withSubStr:@"%@"] == 2) {
            url = [NSString stringWithFormat:mo.urlHost,isChinese ? @"en":mo.chineseTag,qEncoding];
        }
            
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [web loadRequest:request];
        
        if (mo.isShow) {
            [self.arrWebs addObject:web];
        }
        
        
        NSButton *btn = [NSButton buttonWithTitle:mo.name image: mo.imaIcon ?  mo.imaIcon : [NSImage imageNamed:@"ic_btn"] target:self action:@selector(fm_webActios:)];
        btn.state = kUser.webModels[i].isShow;
        btn.alternateTitle = [NSString stringWithFormat:@"%@\n%@",mo.name,@"Close"];
        
        btn.bezelStyle = NSBezelStyleRegularSquare;
        [btn setButtonType:NSButtonTypeSwitch];
        btn.bordered = YES;
        btn.imagePosition = NSImageAbove;
        btn.font = [NSFont systemFontOfSize:9];
        btn.tag = i;
        btn.imageHugsTitle = YES;
        if (mo.isUsed) {
            [self.arrWebActions addObject:btn];
        }
        
    }
    [self fm_webLayout];

    
}
- (void)fm_webActios:(NSButton *)sender {
    [kWindow makeFirstResponder:nil];
    kUser.webModels[sender.tag].isShow = !kUser.webModels[sender.tag].isShow;
    [self fm_initWebs];
}


- (void)fm_webLayout {
    NSWindow *webBackWindow = self.webBack.window;
    CGFloat w  = webBackWindow.frame.size.width;
    webBackWindow.restorable = NO;
    NSInteger webShowNum = self.arrWebs.count ,webUsedNum = self.arrWebActions.count;
//    for (NSInteger i = 0; i < kUser.webModels.count; i++) {
//        if (kUser.webModels[i].isShow && kUser.webModels[i].isUsed) {
//            webShowNum ++;
//        }
//        if (kUser.webModels[i].isUsed) {
//            webUsedNum++;
//        }else{
//        }
//    }
    CGFloat webX = 10 , btnX = 0;
    
    for (NSInteger i = 0; i < self.arrWebs.count; i++) {
        self.arrWebs[i].frame = CGRectMake(webX, 0, kWebWidth, self.webBack.height);
        [self.webBack addSubview:self.arrWebs[i]];
        webX = CGRectGetMaxX(self.arrWebs[i].frame) + 1;
    }
    
    for (NSInteger i = 0; i < self.arrWebActions.count; i++) {
        self.arrWebActions[i].frame = CGRectMake(btnX, 10, kWebActionsWH, kWebActionsWH);
        [self.webActionsBack addSubview:self.arrWebActions[i]];
        btnX = CGRectGetMaxX(self.arrWebActions[i].frame) + 1;
    }
    
    if (webUsedNum) {
        self.webActionsBack_h.constant = kWebActionsWH + 20;
    }else{
        self.webActionsBack_h.constant = 0;
    }
    [webBackWindow setContentSize:NSMakeSize(550 +  (kWebWidth + 1) * webShowNum, CGRectMinYEdge)];
    self.webBack_w.constant = 20 + (kWebWidth + 1) * webShowNum;
    self.webActionsBack_w.constant =  (kWebActionsWH) * webUsedNum;

    
//    NSLog(@"----self.webBack:%ld",self.webBack.subviews.count);
//    NSLog(@"----self.webActionsBack:%ld",self.webActionsBack.subviews.count);
//    NSLog(@"----self.arrWebs:%ld",self.arrWebs.count);
//    NSLog(@"----self.arrWebActions:%ld",self.arrWebActions.count);
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
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    
    
}

@end
