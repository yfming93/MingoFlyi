//
//  Tools.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/8.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject
//提示框四秒
+(void)fm_showHudText:(NSString *)msg;

/// 显示菊花 【显示期间不能交互】
+(void)fm_showHudLoadingIndicator;
/// 隐藏菊花
+(void)fm_hidenHudIndicator;

@end

NS_ASSUME_NONNULL_END
