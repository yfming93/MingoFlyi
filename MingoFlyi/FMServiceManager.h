//
//  FMServiceManager.h
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/8.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMServiceManager : NSObject

+ (FMServiceManager *)sharedFMServiceManager;

- (void)requestDataWithTextString:(NSString *)text
                             data:(void (^)(id response))data;
@end
