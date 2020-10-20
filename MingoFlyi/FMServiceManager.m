//
//  FMServiceManager.m
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/8.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import "FMServiceManager.h"
#import <AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#define kTimeOutInterval 60

//TODO:在http://fanyi.youdao.com/openapi?path=data-mode申请key和keyfrom
static NSString *keyfrom = @"JFFanYi";
static NSString *key = @"972519001";

static NSString *kBaiduTranslationAPPID = @"20201008000583095";
static NSString *kBaiduTranslationSalt = @"1435660288";
static NSString *kBaiduTranslationKey = @"FOKH4Xod7bekmS3cRtVw";



@interface FMServiceManager ()

@end

@implementation FMServiceManager

+ (FMServiceManager *)shareInstance {
    static FMServiceManager *serviceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceManager = [[self alloc] init];
    });
    return serviceManager;
}

+ (void)requestDataWihtMethodUrl:(NSString *)url
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError *err))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = kTimeOutInterval;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //设置相应内容类
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",
                                                         nil];
    [manager GET:url
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)fm_requestWithString:(NSString *)text type:(FanyiType)type
                completedBlock:(CompletedBlock)completedBlock {
    
    if (type == FanyiType_Youdao) {
        [self requestDataUseYoudao:text completedBlock:completedBlock];
    }else if (type == FanyiType_Baidu) {
        [self requestDataUseBaidu:text completedBlock:completedBlock];
    }else if (type == FanyiType_Google) {
        [self requestDataUseGoogle:text completedBlock:completedBlock];
    }else if (type == FanyiType_Ciba) {
        [self requestDataUseCiba:text completedBlock:completedBlock];
    }
   
}

/// 有道翻译
- (void)requestDataUseYoudao:(NSString *)text completedBlock:(CompletedBlock)completedBlock{
    __weak typeof(self) weakSelf = self;
    NSString *encoded = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=%@&key=%@&type=data&doctype=json&version=1.1&q=%@",keyfrom,key,encoded];
    [FMServiceManager requestDataWihtMethodUrl:url success:^(id response) {
        NSString *result = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"翻译：%@",result);
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers  error:&err];
        NSString *resStr = [[dic valueForKey:@"translation"] firstObject];
        resStr = [resStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        completedBlock(resStr);
        
    }failure:^(NSError *err) {
        NSLog(@"error :%@",err);
    }];
    
}

/// 百度翻译
- (void)requestDataUseBaidu:(NSString *)text completedBlock:(CompletedBlock)completedBlock{
    
    //百度API
       NSString *httpStr = @"https://fanyi-api.baidu.com/api/trans/vip/translate";
       //将APPID q salt key 拼接一起
       NSString *appendStr = [NSString stringWithFormat:@"%@%@%@%@",kBaiduTranslationAPPID,text,kBaiduTranslationSalt,kBaiduTranslationKey];
       //加密 生成签名
       NSString *md5Str = appendStr.md5_32bit;
       //将待翻译的文字机型urf-8转码
       NSString *qEncoding = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
       //使用get请求
    NSString *urlStr = [NSString stringWithFormat:@"%@?q=%@&from=%@&to=%@&appid=%@&salt=%@&sign=%@",httpStr,qEncoding,@"auto", text.isContainChinese ? @"en":@"zh",kBaiduTranslationAPPID,kBaiduTranslationSalt,md5Str];
    
    [FMServiceManager requestDataWihtMethodUrl:urlStr success:^(id response) {
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers  error:&err];
        NSString *resStr;
        resStr = [[dic objectForKey:@"trans_result"] firstObject][@"dst"];
        resStr = [resStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        completedBlock(resStr);
        
    }failure:^(NSError *err) {
        NSLog(@"error :%@",err);
    }];
       
}

/// 谷歌翻译
- (void)requestDataUseGoogle:(NSString *)text completedBlock:(CompletedBlock)completedBlock{
    
    //http://translate.google.cn/translate_a/single?client=at&sl=zh-CN&tl=en&dt=t&q=你还知道你在干啥吗
    //http://translate.google.cn/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=你还知道你在干啥吗
    //http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=zh_TW&q=calculate
    // https://translate.google.cn/#auto/en/控制变量法
    NSString *urlStr = [NSString stringWithFormat:@"http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=%@&q=%@",text.isContainChinese ? @"en":@"zh_CN",text];
    //将待翻译的文字机型urf-8转码
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //使用get请求
    [FMServiceManager requestDataWihtMethodUrl:urlStr success:^(id response) {
        NSError *err;
        NSDictionary *dat = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers  error:&err];
        NSString *resStr = @"";
        if (dat != nil) {
//            resStr = [[[dat firstObject] firstObject] firstObject];
            resStr = [[[dat objectForKey:@"sentences"] firstObject] objectForKey:@"trans"];
            resStr = [resStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        };
        completedBlock(resStr);
        
    }failure:^(NSError *err) {
        NSLog(@"error :%@",err);
    }];
}

/// 金山词霸翻译
- (void)requestDataUseCiba:(NSString *)text completedBlock:(CompletedBlock)completedBlock{
//    http://fy.iciba.com/ajax.php?a=fy&f=auto&t=auto&w=%E6%8E%A7%E5%88%B6%E5%8F%98%E9%87%8F
    
    NSString *urlStr = [NSString stringWithFormat:@"http://fy.iciba.com/ajax.php?a=fy&f=auto&t=%@&w=%@",text.isContainChinese ? @"en":@"zh",text];
    //将待翻译的文字机型urf-8转码
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //使用get请求
    [FMServiceManager requestDataWihtMethodUrl:urlStr success:^(id response) {
        NSError *err;
        NSDictionary *dat = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers  error:&err];
        NSString *resStr = @"";
        if (dat != nil) {
            resStr = [dat objectForKey:@"content"];
            if ((resStr != nil) || (![resStr isEqualToString:@""])) {
               resStr =  [dat objectForKey:@"out"];
            }
            resStr = [resStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        };
        
        if ([dat.allKeys containsObject:@"isSensitive"]) {
            resStr = @"FLYI_WARNING：由于金山词霸接口被平凡请求暂时被禁";
        }
        
        completedBlock(resStr);
        
    }failure:^(NSError *err) {
        NSLog(@"error :%@",err);
    }];
}


@end

