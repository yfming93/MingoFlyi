//
//  NSString+FYIHumpString.m
//  MingoFanyi
//
//  Created by 张志峰 on 2017/4/10.
//  Copyright © 2017年 zhifenx. All rights reserved.
//

#import "NSString+FYIHumpString.h"

@implementation NSString (FYIHumpString)
//判断是否是全汉字字符串
+ (BOOL)isChinese:(NSString *)string {
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
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
    if ([self isChinese:string]) {
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
    if ([self isChinese:string]) {
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
    if ([self isChinese:string]) {
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
    if ([self isChinese:string]) {
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
