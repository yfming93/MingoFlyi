//
//  FMWebManager.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN




@interface FMWebManager : NSObject

+ (FMWebManager *)shareInstance;
@property (nonatomic, strong) NSMutableArray <WKWebView *>*arrWebs;
@property (nonatomic, strong) NSMutableArray <NSButton *>*arrWebActions;
- (void)fm_layoutvWebback:(NSView *)webBack  webBackWidth:(NSLayoutConstraint *)webBack_w webActionsBack:(NSView *)webActionsBack  webActionsBackHight:(NSLayoutConstraint *)webActionsBack_h requestText:(NSString *)requestText;
@end

NS_ASSUME_NONNULL_END
