//
//  ViewController.m
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/7.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import "ViewController.h"
#import "FMViewManager.h"

@interface ViewController ()

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

@implementation ViewController
{
    FMViewManager *_viewManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewManager = [[FMViewManager alloc] initViewManagerWithInputScrollView:self.inputContentScrollView
                                                                inputTextView:self.inputTextView
                                                             outputScrollView:self.outputContentScrollView
                                                                  outTextView:self.outputTextView
                                                  btnHumpSmall:self.btnHumpSmall
                                                         btnCopy:self.btnCopy
                                                         btnUnderLineSmall:self.btnUnderLineSmall
                                                           btnUnderLineBig:self.btnUnderLineBig
                                                               btnHumpBig:self.btnHumpBig
                                                                  clearButton:self.clearButton];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)dealloc {
    NSLog(@"ViewController dealloc");
}
@end
