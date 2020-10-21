//
//  YLGoogleTranslate.h
//  YoouliOS
//
//  Created by VictorZhang on 2020/4/23.
//  Copyright © 2020 victor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLGoogleTranslate : NSObject

- (void)translateWithText:(NSString *)text
       targetLanguageCode:(NSString *)languageCode
               completion:(void (^)(NSString * _Nullable originalText,
                                    NSString * _Nullable originalLanguageCode,
                                    NSString * _Nullable translatedText,
                                    NSString * _Nullable targetLanguageCode,
                                    NSString * _Nullable error))completionHandler;


///// 翻译请求
//- (void)fm_requet {
//    NSString *content = @"控制变量法怎么样啊";
//    NSString *targetLanguage = @"zh-CN";
//    YLGoogleTranslate *googleTrans = [[YLGoogleTranslate alloc] init];
//    [googleTrans translateWithText:content targetLanguageCode:targetLanguage completion:^(NSString * _Nullable originalText, NSString * _Nullable originalLanguageCode, NSString * _Nullable translatedText, NSString * _Nullable targetLanguageCode, NSString * _Nullable error) {
//        if ([error length] > 0) {
//            NSLog(@"调用Google翻译接口返回错误：%@ ", error);
//        } else {
//            NSLog(@"调用Google翻译接口返回成功！");
//        }
//    }];
//}

@end

NS_ASSUME_NONNULL_END
