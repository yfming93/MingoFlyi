//
//  FMSetting.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/14.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUser FMSetting.shareInstance.user
//解档出来的模型 = [NSKeyedUnarchiver unarchiveObjectWithFile:你保存文件的路径];
// [NSKeyedArchiver archiveRootObject:你要保存的模型  toFile:保存文件的路径];

// 获取沙盒Document路径
//NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
////获取沙盒temp路径
//filePath = NSTemporaryDirectory();
////获取沙盒Cache路径
//filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

//文件路径
//NSString *uniquePath=[filePath stringByAppendingPathComponent:setting.set];

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject<NSCoding>

@property (nonatomic, assign) BOOL isFliter;
@property (nonatomic, strong) NSString *filterText;
@property (nonatomic, assign) BOOL isPrefix;
@property (nonatomic, assign) BOOL isWebShowGoogle; //打开了谷歌网页翻译
@property (nonatomic, assign) BOOL isWebShowSougou; //打开了搜狗网页翻译
@property (nonatomic, strong) NSString *prefixText;
@property (nonatomic, assign) NSInteger indexAutoCopy;
@property (nonatomic, assign) NSInteger indexManuelCopy;
@property (nonatomic, assign) NSInteger indexFanyi;
@property (nonatomic, assign) CGFloat windowWidth;

@end


@interface FMSetting : NSObject

@property (nonatomic, strong) User *user;
+ (FMSetting *)shareInstance;
+ (void)fm_save;
+ (User *)fm_get;
@end

NS_ASSUME_NONNULL_END
