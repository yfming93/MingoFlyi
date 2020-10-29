
    //
//  FMSetting.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/14.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMSetting.h"
#import <objc/runtime.h>
#define kSettingPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@".flyi_setting"]

@implementation FMWebModel

//mo.urlHost = mo.urlHostInput.fm_fotmatUrlHost.firstObject;
//mo.chineseTag = mo.urlHostInput.fm_fotmatUrlHost.lastObject;

-(NSString *)urlHost {
    _urlHost = self.urlHostInput.fm_fotmatUrlHost.firstObject;
    return _urlHost;
}

-(NSString *)chineseTag {
    _chineseTag = self.urlHostInput.fm_fotmatUrlHost.lastObject;
    return _chineseTag;
}

//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i=0; i<count; i++) {
        Ivar iva = ivar[i];
        const char *name = ivar_getName(iva);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

//解档
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar iva = ivar[i];
            const char *name = ivar_getName(iva);
            NSString *strName = [NSString stringWithUTF8String:name];
            //进行解档取值
            id value = [aDecoder decodeObjectForKey:strName];
            if (!value) continue;
            //利用KVC对属性赋值
            [self setValue:value forKey:strName];
        }
        free(ivar);
    }
    return self;
}

@end


@implementation User
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFliter = YES;
        _isPrefix = NO;
        _filterText = @"";
        _prefixText = @"";
        _indexAutoCopy = 1;
    }
    return self;
}

- (NSMutableArray<FMWebModel *> *)webModels {
    if (!_webModels.count) {
        _webModels = NSMutableArray.array;
        FMWebModel *mo = FMWebModel.new;
        mo.name = @"Google";
        mo.urlHostInput = @"https://translate.google.cn/#auto/zh-CN/%@";
        mo.imaIcon = [NSImage imageNamed:@"ic_google"];
        mo.isUsed = YES;
        mo.isShow = NO;

        FMWebModel *mo2 = FMWebModel.new;
        mo2.name = @"Sougou";
        mo2.urlHostInput = @"https://fanyi.sogou.com/?transfrom=auto&transto=zh&model=general&keyword=%@";
        mo2.imaIcon = [NSImage imageNamed:@"ic_sougou"];
        mo2.isUsed = YES;
        mo2.isShow = NO;
        
        [_webModels addObject:mo];
        [_webModels addObject:mo2];
    }
    return _webModels;
}

//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i=0; i<count; i++) {
        Ivar iva = ivar[i];
        const char *name = ivar_getName(iva);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

//解档
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar iva = ivar[i];
            const char *name = ivar_getName(iva);
            NSString *strName = [NSString stringWithUTF8String:name];
            //进行解档取值
            id value = [aDecoder decodeObjectForKey:strName];
            if (!value) continue;
            //利用KVC对属性赋值
            [self setValue:value forKey:strName];
        }
        free(ivar);
    }
    return self;
}


-(void)deleteFileWithFileName:(NSString *)fileName filePath:(NSString *)filePath {
    //创建文件管理对象
    NSFileManager* fileManager=[NSFileManager defaultManager];
    //获取文件目录
    if (!filePath) {
        //如果文件目录设置有空,默认删除Cache目录下的文件
        filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    }
    //拼接文件名
    NSString *uniquePath=[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    //文件是否存在
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    //进行逻辑判断
    if (!blHave) {
        NSLog(@"文件不存在");
        return ;
    }else {
        //文件是否被删除
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        //进行逻辑判断
        if (blDele) {
            NSLog(@"删除成功");
        }else {
            
            NSLog(@"删除失败");
        }
    }
}


@end

@implementation FMSetting

+ (FMSetting *)shareInstance {
    static FMSetting *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)fm_save {
    User *ob = kUser;
    NSString *path = kSettingPath;
    BOOL isSave = [NSKeyedArchiver archiveRootObject:ob  toFile:path];
    if (isSave) {
        NSLog(@"isSave OK");
    }
}


+ (User *)fm_get{
    User *setting =  [NSKeyedUnarchiver unarchiveObjectWithFile:kSettingPath];
    kUser = setting;
    return kUser;
}

-(User *)user {
    if (_user == nil) {
        _user = User.new;
    }
    return _user;
}


@end
