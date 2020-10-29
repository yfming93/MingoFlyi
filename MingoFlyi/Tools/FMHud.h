//
//  FMHud.h
//  MingoFlyi
//
//  Created by mingo on 2020/10/22.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kHud FMHud.shareInstance

@interface FMHud : NSObject
+ (FMHud *)shareInstance;

+ (void)fm_fadeInHud:(NSString *)msg;
+ (void)fm_fadeOutHud;

@end

NS_ASSUME_NONNULL_END
