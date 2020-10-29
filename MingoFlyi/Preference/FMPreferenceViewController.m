//
//  FMPreferenceViewController.m
//  MingoFlyi
//
//  Created by mingo on 2020/10/28.
//  Copyright © 2020 袁凤鸣. All rights reserved.
//

#import "FMPreferenceViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "FMTableCell.h"

@interface FMPreferenceViewController (){
}
@property (strong) IBOutlet NSTextField *tfWebUrl;
@property (strong) IBOutlet NSTextField *tfWebName;
@property (strong) IBOutlet NSImageView *imaIcon;
@property (strong) NSImage *imaIconSelected;
@property (strong) NSMutableArray *dataArray;
@property (strong) IBOutlet NSTableView *tableView;

@end

@implementation FMPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fm_viewDidLoad];
}

- (void)fm_viewDidLoad {
    _dataArray = [NSMutableArray array];
//    NSTableColumn * column = [[NSTableColumn alloc]initWithIdentifier:@"test"];
//    [_tableView addTableColumn:column];
    [_tableView reloadData];
}

-(void)awakeFromNib{
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"FMTableCell" bundle:nil] forIdentifier:@"customCell"];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return kUser.webModels.count;
}

#pragma mark table delegate
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    /*
     if(!_nib){
     _nib = [[NSNib alloc] initWithNibNamed:@"CustomCellView" bundle:nil];
     [tableView registerNib:_nib forIdentifier:@"customCell"];
     }*/
    kWeakSelf
    FMTableCell *cellView = [tableView makeViewWithIdentifier:@"customCell" owner:self];
    kUser.webModels[row].index = row;
    cellView.model = kUser.webModels[row];
    cellView.relaodBlock = ^{
        [weakSelf.tableView reloadData];
    };
//    cellView.title.stringValue = @"aaa";
//    cellView.subTitle.stringValue = @"bbb";
    return cellView;
}


//-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    return _dataArray[row];
//}


- (IBAction)fm_selectIcon:(NSButton *)sender {
    NSOpenPanel *op = NSOpenPanel.openPanel;
    op.message = @"选择图标";
    op.prompt = @"选择该图";
    op.allowedFileTypes = @[@"png",@"jpg"];
    
    [op beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSLog(@"op:%@",op.URLs);
            NSURL *url = op.URLs.firstObject;
            NSData *dta = [NSData dataWithContentsOfURL:url];
            NSImage *temIma = [NSImage sd_imageWithData:dta];
            NSImage *temIma2 = [NSImage sd_decodedAndScaledDownImageWithImage:temIma limitBytes:1024*1024*1024];
            [temIma2 setSize:CGSizeMake(35, 35)];
            self.imaIconSelected = temIma2;
            self.imaIcon.image = self.imaIconSelected;
        }
    }];
}

- (IBAction)fm_addSureAction:(NSButton *)sender {
    if (!self.tfWebUrl.stringValue.length) {
        [FMHud fm_fadeInHud:@"请填写翻译网站地址"];
        return;
    }
    
    if (!self.tfWebName.stringValue.length) {
        [FMHud fm_fadeInHud:@"请填写翻译网站名称"];
        return;
    }
    if (!self.imaIconSelected) {
        [FMHud fm_fadeInHud:@"请选择翻译网站图标"];
        return;

    }
    FMWebModel *mo = FMWebModel.new;
    mo.name = self.tfWebName.stringValue;
    mo.urlHostInput = self.tfWebUrl.stringValue;
    mo.urlHost = mo.urlHostInput.fm_fotmatUrlHost.firstObject;
    mo.chineseTag = mo.urlHostInput.fm_fotmatUrlHost.lastObject;
    mo.imaIcon = self.imaIconSelected;
    mo.isUsed = YES;
    mo.isShow = NO;
    [kUser.webModels addObject:mo];
    [FMNotifyManager fm_postIdentifier:kNotifyNameReloadSetting object:nil];
    [self.view.window close];

}

@end
