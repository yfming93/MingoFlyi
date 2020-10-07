//
//  NSString+FYIHumpString.h
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/10.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FYIHumpString)



//判断是否是全汉字字符串
+ (BOOL)isChinese:(NSString *)string;

/**
 驼峰字符串转普通字符串（若全是中文字符，不转换）

 @param string 目标字符串
 @return 驼峰字符串/普通字符串
 */
+ (NSString *)fm_humpStringToCommonString:(NSString *)string;

/**
 普通字符串转换成驼峰字符串转（若全是中文字符，不转换）
 
 @param string 普通字符串
 @param isCapitalized 第一句话首字母大写
 @return 驼峰字符串
 */
+ (NSString *)commonStringToHumpString:(NSString *)string  isCapitalized:(BOOL)isCapitalized;

/// 普通格式转下划线格式
/// @param string 普通字符串
/// @param isCapitalized 字母大写
+ (NSString *)fm_commonStringToUnderLineString:(NSString *)string isCapitalized:(BOOL)isCapitalized ;

//下划线格式 转 普通格式
+ (NSString *)fm_underLineStringToCommonString:(NSString *)string;
@end
