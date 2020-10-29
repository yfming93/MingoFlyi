//
//  FMTableCell.h
//  MingoFlyi
//
//  Created by iMac on 2020/10/29.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMTableCell : NSTableCellView
@property (strong,nonatomic) FMWebModel *model;

@end

NS_ASSUME_NONNULL_END
