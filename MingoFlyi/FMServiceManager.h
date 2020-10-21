//
//  FMServiceManager.h
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/8.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletedBlock)(id response);

typedef NS_ENUM(NSInteger, FanyiType) {

    /// 百度
    FanyiType_Baidu = 1,
    /// 有道
    FanyiType_Youdao = 2,
    /// 金山词霸
    FanyiType_Ciba = 3,
        /// 谷歌
    FanyiType_Google = 4,
};

@interface FMServiceManager : NSObject

+ (FMServiceManager *)shareInstance;

- (void)fm_requestWithString:(NSString *)text type:(FanyiType)type
                completedBlock:(CompletedBlock)completedBlock ;

@end
