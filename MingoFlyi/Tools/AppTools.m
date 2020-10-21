//
//  AppTools.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/21.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "AppTools.h"

@implementation AppTools
/// 结果过滤
+ (NSString *)fm_filter:(NSString *)str isFilter:(BOOL)isFilter tfFilter:(NSString *)tfFilter {
    if (!isFilter) return str;
    if (!tfFilter.length) return str;
    NSString * result = [str lowercaseStringWithLocale:NSLocale.currentLocale];
    NSString * smallfilter = [tfFilter lowercaseStringWithLocale:NSLocale.currentLocale];
    NSArray *outCharts = @[@"，",@";",@"；",@"。",@"、",@"/",@"|",@"\\"];
    for (NSString *str in outCharts) {
        if ([smallfilter containsString:str]) {
            smallfilter = [smallfilter stringByReplacingOccurrencesOfString:str withString:@","];
        }
    }
    NSMutableArray *arrTitels = [result componentsSeparatedByString:@" "].mutableCopy;
    NSMutableArray *arrFilter = [smallfilter componentsSeparatedByString:@","].mutableCopy;
    for (NSString *str in arrFilter) {
        NSString *tem = [NSString stringWithFormat:@"%@",str];
        if ([result containsString:tem] && (![tem isEqualToString:@" "]) && (![tem isEqualToString:@""])) {
            [arrTitels removeObject:tem];
        }
    }
    result = [arrTitels componentsJoinedByString:@" "];
    return result;
}
@end
