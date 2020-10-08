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
    /// 有道
    FanyiType_Youdao = 0,
    /// 新品
    FanyiType_Baidu = 1,
};

@interface FMServiceManager : NSObject

+ (FMServiceManager *)sharedFMServiceManager;

- (void)fm_requestWithString:(NSString *)text type:(FanyiType)type
                completedBlock:(CompletedBlock)completedBlock ;
@end
