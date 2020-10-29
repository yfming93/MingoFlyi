//
//  FMTableCell.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/29.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
typedef  void(^RelaodBlock)();

@interface FMTableCell : NSTableCellView
@property (strong,nonatomic) FMWebModel *model;
@property (copy,nonatomic) RelaodBlock relaodBlock;

@end

NS_ASSUME_NONNULL_END
