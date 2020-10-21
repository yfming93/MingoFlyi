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
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode {
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  @brief  urlEncode
 *
 *  @param encoding encoding模式
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                (__bridge CFStringRef)self,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

/**
 *  32位md5加密算法
 *  @param str 传入要加密的字符串
 *  @return NSString
 */
- (NSString *)md5_32bit{
    const char *cStr = self.UTF8String;
    unsigned char result[16];
    if (cStr == NULL) return self;
    
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
        if (subString.length) {
            const char *cString = [subString UTF8String];
            if (cString != NULL) {
                if (strlen(cString) == 3) {
                    return YES;
                }
            }
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


//过滤表情
- (NSString *)fm_filterEmoji {
    NSUInteger len = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *utf8 = [self UTF8String];
    char *newUTF8 = malloc( sizeof(char) * len );
    int j = 0;
    
    //0xF0(4) 0xE2(3) 0xE3(3) 0xC2(2) 0x30---0x39(4)
    for ( int i = 0; i < len; i++ ) {
        unsigned int c = utf8;
        BOOL isControlChar = NO;
        if ( c == 4294967280 ||
            c == 4294967089 ||
            c == 4294967090 ||
            c == 4294967091 ||
            c == 4294967092 ||
            c == 4294967093 ||
            c == 4294967094 ||
            c == 4294967095 ||
            c == 4294967096 ||
            c == 4294967097 ||
            c == 4294967088 ) {
            i = i + 3;
            isControlChar = YES;
        }
        if ( c == 4294967266 || c == 4294967267 ) {
            i = i + 2;
            isControlChar = YES;
        }
        if ( c == 4294967234 ) {
            i = i + 1;
            isControlChar = YES;
        }
        if ( !isControlChar ) {
            newUTF8[j] = utf8;
            j++;
        }
    }
    newUTF8[j] = '\0';
    NSString *encrypted = [NSString stringWithCString:(const char*)newUTF8
                                             encoding:NSUTF8StringEncoding];
    free( newUTF8 );
    return encrypted;
}

//是否含有表情
- (BOOL)fm_stringContainsEmoji{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    
    return returnValue;
}

@end
