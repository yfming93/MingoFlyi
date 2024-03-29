//
//  NSString+FMAdd.h
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/10.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FMAdd)
    /// 获取重复子字符串个数 利用替换先把重复元素替换掉,再根据length长度做判断
- (NSInteger )fm_getDuplicateSubStrCountInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr;

    /// 获取重复子字符串位置 利用切分先得数组,再根据索引计算
- (NSMutableArray *)fm_getDuplicateSubStrLocInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr ;

// 将各种翻译的结果 转换 为 分割 空格的字符串
- (NSString *)fm_formatForChinese:(NSString *)text;

/// 格式化录入的网页url
- (NSMutableArray *)fm_fotmatUrlHost;
//过滤表情
- (NSString *)fm_filterEmoji;

//是否含有表情
- (BOOL)fm_stringContainsEmoji;

/**
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode;

/**
 *  32位md5加密算法
 *  @param str 传入要加密的字符串
 *  @return NSString
 */
- (NSString *)md5_32bit;

//判断是否是全汉字字符串
- (BOOL)isChinese;

/**
 *  @brief  判断是否包含中文
 *  @return 是否包含中文
 */
- (BOOL)isContainChinese;

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
