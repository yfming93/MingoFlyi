//
//  FMHud.m
//  MingoFlyi
//
//  Created by mingo on 2020/10/22.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMHud.h"
#import <QuartzCore/QuartzCore.h>

#define HUD_FADE_IN_DURATION    (0.5)
#define HUD_FADE_OUT_DURATION   (0.5)
#define HUD_ALPHA_VALUE         (0.75)
#define HUD_CORNER_RADIUS       (18.0)
#define HUD_HORIZONTAL_MARGIN   (30)
#define HUD_HEIGHT              (90)
#define HUD_DISPLAY_DURATION    (3.0)

@interface FMHud (){}
@property (strong) NSTimer *timerToFadeOut;
@property (assign) BOOL fadingOut;
@property (strong)  NSWindow *window;
@property (strong)  NSTextField *isName;
@property (strong)  NSView *panelView;
@property (nonatomic, copy)  NSString *msg;
@end

@implementation FMHud

+ (FMHud *)shareInstance {
    static FMHud *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

+ (void)fm_fadeInHud:(NSString *)msg {
    [FMHud.shareInstance fm_fadeInHud:msg];
}

+ (void)fm_fadeOutHud {
    [FMHud.shareInstance fm_fadeOutHud];
}

- (void)fm_fadeInHud:(NSString *)msg {
    if (!msg.length) return;
    self.msg = msg;
    if (self.timerToFadeOut) {
        [self.timerToFadeOut invalidate];
        self.timerToFadeOut = nil;
    }
    self.fadingOut = NO;
    [self.window orderFrontRegardless];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:HUD_FADE_IN_DURATION] forKey:kCATransactionAnimationDuration];
    [CATransaction setValue:^{ [self fm_didFadeIn]; } forKey:kCATransactionCompletionBlock];
    [[self.panelView layer] setOpacity:1.0];
    [CATransaction commit];
    
    [self setUpHUD];

}

- (void) fm_didFadeIn {
    self.timerToFadeOut = [NSTimer scheduledTimerWithTimeInterval:HUD_DISPLAY_DURATION target:self selector:@selector(fm_fadeOutHud) userInfo:nil repeats:NO];
}

- (void)fm_fadeOutHud {
    self.fadingOut = YES;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:HUD_FADE_OUT_DURATION] forKey:kCATransactionAnimationDuration];
    [CATransaction setValue:^{ [self fm_didFadeOut]; } forKey:kCATransactionCompletionBlock];
    [[self.panelView layer] setOpacity:0.0];
    [CATransaction commit];
}

- (void)fm_didFadeOut {
    if (self.fadingOut) {
        NSLog(@"Did fade out!");
        [self.window orderOut:nil];
    }
    self.fadingOut = NO;
}



- (void)setUpHUD {
    self.isName.stringValue = self.msg.length ? self.msg : @"" ;
    [self.isName sizeToFit];
    CGRect labelFrame = [self.isName frame];
    CGRect windowFrame = [self.window frame];
//    NSLog(@"label:(%f, %f) (%f x %f) ", labelFrame.origin.x, labelFrame.origin.y, labelFrame.size.width, labelFrame.size.height);
//    NSLog(@"window:(%f, %f) (%f x %f) ", windowFrame.origin.x, windowFrame.origin.y, windowFrame.size.width, windowFrame.size.height);
    
    windowFrame.size.width = labelFrame.size.width + HUD_HORIZONTAL_MARGIN * 2;
    windowFrame.size.height = HUD_HEIGHT;
    
    // 如下是获取整个屏幕的 中心
//    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] visibleFrame];
//    windowFrame.origin.x = (screenRect.size.width - windowFrame.size.width) / 2;
//    windowFrame.origin.y = (screenRect.size.height - windowFrame.size.height) / 2;
    
    //  获取APP展示窗口的中心
    NSRect screenRect = NSApplication.sharedApplication.keyWindow.frame;
    windowFrame.origin.x = (screenRect.size.width - windowFrame.size.width) / 2 + screenRect.origin.x;
    windowFrame.origin.y = (screenRect.size.height - windowFrame.size.height) / 2 + screenRect.origin.y;
    
    [self.window setFrame:windowFrame display:YES];
    
    NSRect viewFrame = windowFrame;
    viewFrame.origin.x = 0;
    viewFrame.origin.y = 0;
    [self.panelView setFrame:viewFrame];
    
    labelFrame.origin.x = HUD_HORIZONTAL_MARGIN;
    labelFrame.origin.y = (windowFrame.size.height - labelFrame.size.height) / 2;
    [self.isName setFrame:labelFrame];
}


-(void) initUIComponents {
    
    self.isName = NSTextField.alloc.init;
    [self.isName setTextColor:NSColor.whiteColor];
    self.isName.font = [NSFont boldSystemFontOfSize:22];
    self.isName.alignment = NSTextAlignmentCenter;
    self.isName.backgroundColor = [NSColor clearColor];
    self.isName.bordered = NO;  //必须设置为无边才能透明背景
    self.isName.editable = NO; //必须设置为禁用才能透明背景
    
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(0.05, 0.05, 0.05, HUD_ALPHA_VALUE)]; //RGB plus Alpha Channel
    [viewLayer setCornerRadius:HUD_CORNER_RADIUS];
    self.panelView = NSView.alloc.init;
    [self.panelView addSubview:self.isName];
    [self.panelView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.panelView setLayer:viewLayer];
    [[self.panelView layer] setOpacity:0.0];
    
    self.window = [NSWindow.alloc init];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setLevel:kCGUtilityWindowLevelKey + 1000]; //Make the window be the top most one while displayed. (The 1000 is a magic number.)
    [self.window setStyleMask:NSWindowStyleMaskBorderless]; //No title bar;
    
    
    self.window.contentView = self.panelView;
    [self setUpHUD];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUIComponents];

    }
    return self;
}


@end
