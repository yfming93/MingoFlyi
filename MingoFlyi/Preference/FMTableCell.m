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
    self.backgroundStyle = NSBackgroundStyleRaised;
    _model = model;
    self.tfWebName.superview.window.backgroundColor = NSColor.redColor;
    self.tfWebUrl.stringValue = model.urlHostInput;
    self.tfWebName.stringValue = model.name;
    self.imaIcon.image = model.imaIcon;
}

- (IBAction)fm_changeImageIcon:(NSButton *)sender {
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
    
}



@end
