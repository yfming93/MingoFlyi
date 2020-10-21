//
//  AppTools.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppTools : NSObject
/// 结果过滤
+ (NSString *)fm_filter:(NSString *)str isFilter:(BOOL)isFilter tfFilter:(NSString *)tfFilter;
@end

NS_ASSUME_NONNULL_END
