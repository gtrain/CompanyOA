//
//  AboutViewController.m
//  OA_TGNET
//
//  Created by YANGZQ on 13-8-13.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_About];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_About];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _versionLabel.text=[NSString stringWithFormat:@"自动化办公系统 | 版本: v%@",IosAppVersion];
}

//返回
- (IBAction)viewPopBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_versionLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setVersionLabel:nil];
    [super viewDidUnload];
}

@end
