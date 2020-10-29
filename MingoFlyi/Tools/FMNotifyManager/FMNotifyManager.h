//
//  FMNotifyManager.h
//  FMNotifyManager
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FMNotifyType) {
    FMNotifyReloadData,/// 刷新数据通知
    FMNotifyLogin,/// 登录
    FMNotifyLogout,/// 退出登录

};


@interface FMNotifyManager : NSObject

///所有响应block生命周期和观察者对象生命周期一样，一个对象多次添加同一类型或者同一标识符的观察者，只会添加最后一次，响应的block回掉会随着观察者对象销毁自动销毁，建议使用枚举管理所有标识符


/**
 根据类型添加观察者
 
 @param observer 观察者
 @param type 监听类型
 @param actionBlock 监听响应
 */
+ (void)fm_addObserver:(id)observer type:(FMNotifyType)type mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, id object))actionBlock;

/**
 根据类型调用
 
 @param type 响应类型
 @param object 数据
 */
+ (void)fm_postType:(FMNotifyType)type object:(id)object;

//------------------------------------字符串作为唯一标识符，内部已经处理，不会和上面枚举方式冲突-------------------------------------


/**
 根据标识符添加观察者

 @param observer 观察者
 @param identifier 标识
 @param mainThread 是否在主线程回掉
 @param actionBlock 监听响应
 */
+ (void)fm_addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, id object))actionBlock;

/**
 根据标识符调用

 @param identifier 标识符
 @param object 数据
 */
+ (void)fm_postIdentifier:(NSString *)identifier object:(id)object;





@end
