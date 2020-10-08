//
//  NSString+FMAdd.m
//  MingoFlyi
//
//  Created by 袁凤鸣 on 2020/8/10.
//  Copyright © 2020年 袁凤鸣. All rights reserved.
//

#import "NSString+FMAdd.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (FMAdd)

/**
 *  32位md5加密算法
 *  @param str 传入要加密的字符串
 *  @return NSString
 */
- (NSString *)md5_32bit{
    const char *cStr = self.UTF8String;
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//判断是否是全汉字字符串
- (BOOL)isChinese {
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

/**
 *  @brief  判断是否包含中文
 *  @return 是否包含中文
 */
- (BOOL)isContainChinese {
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

////移除前缀
//+ (NSString *)removeThePrefix:(NSString *)string {
//    NSInteger index;
//    for (index = 0; index < string.length; index ++) {
//        char word = [string characterAtIndex:index];
//        while (islower(word)) {
//            if (index >= 2) {
//                string = [string stringByReplacingCharactersInRange:NSMakeRange(0, index - 1) withString:@""];
//            }
//            return string;
//        }
//    }
//    return string;
//}

//驼峰格式转普通格式
+ (NSString *)fm_humpStringToCommonString:(NSString *)string {
    if (string.isChinese) {
        return string;
    }
    
    NSString *newString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSMutableArray *newStringArray = [[NSMutableArray alloc] init];
    //遇到大写字母将前一个单词添加到数组中
    NSUInteger oldIndex = 0;
    for (NSUInteger index = 0; index < newString.length; index ++) {
        char word = [newString characterAtIndex:index];
        if (isupper(word)) {
            NSUInteger i = index - oldIndex;
            NSString *word = [newString substringWithRange:NSMakeRange(oldIndex, i)];
            [newStringArray addObject:word];
            oldIndex = index;
        }
    }
    //将最后一个单词添加到数组中
    NSUInteger i = newString.length - oldIndex;
    [newStringArray addObject:[newString substringWithRange:NSMakeRange(oldIndex, i)]];
    //将字符数组转换成字符串，每个单词间添加空格
    newString = [newStringArray componentsJoinedByString:@" "];
    return newString;
}

//普通格式转驼峰格式
+ (NSString *)commonStringToHumpString:(NSString *)string  isCapitalized:(BOOL)isCapitalized {
    if (string.isChinese) {
        return string;
    }
    //字符串中每个单词首字母大写
    NSString *tempString = [string capitalizedString];
    //分隔成数组
    NSArray *words = [tempString componentsSeparatedByString:@" "];
    //去掉空格
    tempString = [words componentsJoinedByString:@""];
    //转成驼峰格式
    NSMutableString *humpString = [[NSMutableString alloc] initWithString:tempString];
    if (!isCapitalized) {
        //首字母小写
        NSString *change = [NSString stringWithFormat:@"%c",[tempString characterAtIndex:0] + 32];
        [humpString replaceCharactersInRange:NSMakeRange(0, 1) withString:change];
    }
    return humpString;
}

//下划线格式 转 普通格式
+ (NSString *)fm_underLineStringToCommonString:(NSString *)string {
    if (string.isChinese) {
        return string;
    }
    NSString *tempString = string;
    //分隔成数组
    NSArray *words = [tempString componentsSeparatedByString:@"_"];
    //去掉空格
    tempString = [words componentsJoinedByString:@" "];
    
    return tempString;
}


//普通格式 转 下划线格式
+ (NSString *)fm_commonStringToUnderLineString:(NSString *)string isCapitalized:(BOOL)isCapitalized {
    if (string.isChinese) {
        return string;
    }
    NSString *tempString = [string lowercaseStringWithLocale:NSLocale.currentLocale];
    if (isCapitalized) {
        tempString = [tempString uppercaseStringWithLocale:NSLocale.currentLocale];
    }
    //分隔成数组
    NSArray *words = [tempString componentsSeparatedByString:@" "];
    //去掉空格
    tempString = [words componentsJoinedByString:@"_"];
    
    return tempString;
}



@end
