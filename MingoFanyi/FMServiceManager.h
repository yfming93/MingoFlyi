//
//  FMServiceManager.h
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/8.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMServiceManager : NSObject

+ (FMServiceManager *)sharedFMServiceManager;

- (void)requestDataWithTextString:(NSString *)text
                             data:(void (^)(id response))data;
@end
