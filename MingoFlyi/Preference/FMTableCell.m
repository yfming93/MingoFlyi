//
//  FMTableCell.m
//  MingoFlyi
//
//  Created by iMac on 2020/10/29.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMTableCell.h"
#import <SDWebImage/SDWebImage.h>

@interface FMTableCell ()
@property (strong) IBOutlet NSTextField *tfWebUrl;
@property (strong) IBOutlet NSTextField *tfWebName;
@property (strong) IBOutlet NSImageView *imaIcon;
@property (strong) IBOutlet NSButton *btnEditor;
@property (strong) IBOutlet NSButton *btnStopUse;
@property (strong) IBOutlet NSButton *btnDelete;

@end
@implementation FMTableCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
       
    }
    return self;
}

-(void)setModel:(FMWebModel *)model {
    _model = model;
    self.tfWebUrl.stringValue = model.urlHostInput;
    self.tfWebName.stringValue = model.name;
    self.imaIcon.image = model.imaIcon;
    self.btnStopUse.state = model.isUsed;
    [self fm_btnStopUse];

}

- (IBAction)fm_changeImageIcon:(NSButton *)sender {
    if (self.btnEditor.state != NSControlStateValueOn) {
        [FMHud fm_fadeInHud:@"编辑模式开启后才能操作"];
        return;
    }
    NSOpenPanel *op = NSOpenPanel.openPanel;
    op.message = @"选择图标";
    op.prompt = @"选择该图";
    op.allowedFileTypes = @[@"png",@"jpg"];
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSLog(@"op:%@",op.URLs);
            NSURL *url = op.URLs.firstObject;
            NSData *dta = [NSData dataWithContentsOfURL:url];
            NSImage *temIma = [NSImage sd_imageWithData:dta];
            NSImage *temIma2 = [NSImage sd_decodedAndScaledDownImageWithImage:temIma limitBytes:1024*1024*1024];
            [temIma2 setSize:CGSizeMake(35, 35)];
            self.imaIcon.image = temIma2;
            kUser.webModels[_model.index].imaIcon = temIma2;
            [FMSetting fm_save];
            [FMNotifyManager fm_postIdentifier:kNotifyNameReloadSetting object:nil];
        }
    }];

}

- (IBAction)fm_btnEditorAction:(NSButton *)sender {
    if (sender.state == NSControlStateValueOn ) {
        self.tfWebName.enabled = YES;
        self.tfWebUrl.enabled = YES;
    }else{
        self.tfWebName.enabled = NO;
        self.tfWebUrl.enabled = NO;
        
    }
    [self fm_save];
    
}

- (void)fm_save{
    kUser.webModels[_model.index].imaIcon = self.imaIcon.image;
    kUser.webModels[_model.index].urlHostInput = self.tfWebUrl.stringValue;
    kUser.webModels[_model.index].name = self.tfWebName.stringValue;
    kUser.webModels[_model.index].isUsed = self.btnStopUse.state;
    [FMNotifyManager fm_postIdentifier:kNotifyNameReloadSetting object:nil];
}

- (void)fm_btnStopUse{
    self.btnDelete.superview.wantsLayer = YES; // make the cell layer-backed
    if (self.btnStopUse.state == NSControlStateValueOn ) {
        [FMHud fm_fadeInHud:[NSString stringWithFormat:@"已启用\n%@",_model.name]];
        self.btnDelete.superview.layer.backgroundColor = NSColor.systemGrayColor.CGColor;

    }else{
        self.btnDelete.superview.layer.backgroundColor = NSColor.gridColor.CGColor;
        [FMHud fm_fadeInHud:[NSString stringWithFormat:@"已禁用\n%@",_model.name]];
    }
}

- (IBAction)fm_btnStopUseAction:(NSButton *)sender {
    kWeakSelf
    [weakSelf fm_btnStopUse];
    kUser.webModels[_model.index].isUsed = !kUser.webModels[_model.index].isUsed;
    [weakSelf fm_save];
}

- (IBAction)fm_btnDeleteAction:(NSButton *)sender {
    [self fm_alertDelete];
}

-(void)fm_alertDelete {
    NSAlert *alert = [[NSAlert alloc]init];
    //可以设置产品的icon
    alert.icon = [NSImage imageNamed:@"ic_cat"];//your logo
    //添加两个按钮吧
    [alert addButtonWithTitle:@"删除"];
    [alert addButtonWithTitle:@"取消"];
    //正文
    alert.messageText = @"提示";
    //描述文字
    alert.informativeText = @"你真的要删除这个翻译网站吗？";
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn) {
            [kUser.webModels removeObject:self.model];
            if (self.relaodBlock) {
                self.relaodBlock();
                [FMNotifyManager fm_postIdentifier:kNotifyNameReloadSetting object:nil];

            }
        }
    }];
    
}


@end
