//
//  FMNotifyManager.m
//  FMNotifyManager
//
//

#import "FMNotifyManager.h"

@interface FMNotifyManager ()

@property (nonatomic, strong) NSMapTable *observerMapTable;
@property (nonatomic, strong) NSMapTable *blockDictionaryMapTable;
@property (nonatomic, strong) NSMapTable *mainThreadDictionaryMapTable;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation FMNotifyManager

static FMNotifyManager *_manager = nil;

+ (id)allocWithZone:(struct _NSZone __unused*)zone {
    return [self sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
- (id)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        self.observerMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.blockDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.mainThreadDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(self.semaphore);
    });
    return _manager;
}
- (id)copyWithZone:(NSZone __unused*)zone {
    return _manager;
}
- (id)mutableCopyWithZone:(NSZone __unused*)zone {
    return _manager;
}
+ (void)fm_addObserver:(id)observer type:(FMNotifyType)type mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, id object))actionBlock {
    dispatch_semaphore_wait([FMNotifyManager sharedInstance].semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [[self keyWithActionType:type] stringByAppendingString:@"-1"]];
    NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-1"];
    NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-1"];

    NSMutableDictionary *blockDictionary = [[FMNotifyManager sharedInstance].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:actionBlockKey];

    NSMutableDictionary *mainThreadDictionary = [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable objectForKey:observer];
    if (!mainThreadDictionary) {
        mainThreadDictionary = [NSMutableDictionary dictionary];
    }
    [mainThreadDictionary setObject:[NSNumber numberWithBool:mainThread] forKey:actionMainThreadKey];

    [[FMNotifyManager sharedInstance].observerMapTable setObject:observer forKey:key];
    [[FMNotifyManager sharedInstance].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    dispatch_semaphore_signal([FMNotifyManager sharedInstance].semaphore);
}

+ (void)fm_postType:(FMNotifyType)type object:(id)object {
    dispatch_semaphore_wait([FMNotifyManager sharedInstance].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[FMNotifyManager sharedInstance].observerMapTable keyEnumerator] allObjects];
    NSString *identifier = [[self keyWithActionType:type] stringByAppendingString:@"-1"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",identifier];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-1"];
        NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-1"];
        id observer = [[FMNotifyManager sharedInstance].observerMapTable objectForKey:key];
        NSMutableDictionary *blockDictionary = [[FMNotifyManager sharedInstance].blockDictionaryMapTable objectForKey:observer];
        NSMutableDictionary *mainThreadDictionary = [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable objectForKey:observer];
        void(^block)(id observer, id object) = [blockDictionary objectForKey:actionBlockKey];
        BOOL mainThread = [[mainThreadDictionary objectForKey:actionMainThreadKey] boolValue];
        if (block) {
            if (mainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(observer, object);
                });
            }else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(observer, object);
                });
            }
        }
    }
    dispatch_semaphore_signal([FMNotifyManager sharedInstance].semaphore);
}

+ (NSString *)keyWithActionType:(FMNotifyType)actionType {
    NSString *key;
    switch (actionType) {
        case FMNotifyReloadData:
            key = @"FMNotifyReloadData";
            break;
        case FMNotifyLogin:
            key = @"FMNotifyLogin";
            break;
        case FMNotifyLogout:
            key = @"FMNotifyLogout";
            break;
    }
    return key;
}

+ (void)fm_addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, id object))actionBlock {
    dispatch_semaphore_wait([FMNotifyManager sharedInstance].semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [identifier stringByAppendingString:@"-0"]];
    NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-0"];
    NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-0"];
    NSMutableDictionary *blockDictionary = [[FMNotifyManager sharedInstance].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:actionBlockKey];

    NSMutableDictionary *mainThreadDictionary = [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable objectForKey:observer];
    if (!mainThreadDictionary) {
        mainThreadDictionary = [NSMutableDictionary dictionary];
    }
    [mainThreadDictionary setObject:[NSNumber numberWithBool:mainThread] forKey:actionMainThreadKey];

    [[FMNotifyManager sharedInstance].observerMapTable setObject:observer forKey:key];
    [[FMNotifyManager sharedInstance].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    
    dispatch_semaphore_signal([FMNotifyManager sharedInstance].semaphore);
}

+ (void)fm_postIdentifier:(NSString *)identifier object:(id)object {
    dispatch_semaphore_wait([FMNotifyManager sharedInstance].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[FMNotifyManager sharedInstance].observerMapTable keyEnumerator] allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",[identifier stringByAppendingString:@"-0"]];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-0"];
        NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-0"];
        id observer = [[FMNotifyManager sharedInstance].observerMapTable objectForKey:key];
        NSMutableDictionary *blockDictionary = [[FMNotifyManager sharedInstance].blockDictionaryMapTable objectForKey:observer];
        NSMutableDictionary *mainThreadDictionary = [[FMNotifyManager sharedInstance].mainThreadDictionaryMapTable objectForKey:observer];
        void(^block)(id observer, id object) = [blockDictionary objectForKey:actionBlockKey];
        BOOL mainThread = [[mainThreadDictionary objectForKey:actionMainThreadKey] boolValue];
        if (block) {
            if (mainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(observer, object);
                });
            }else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(observer, object);
                });
            }
        }
    }
    dispatch_semaphore_signal([FMNotifyManager sharedInstance].semaphore);
}

@end
