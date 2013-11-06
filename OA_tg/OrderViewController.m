//
//  OrderViewController.m
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "OrderViewController.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"
#import "OrderStatisticsVC.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface OrderViewController ()

@end

@implementation OrderViewController

- (void)dealloc {
    [_lunchBtn release];
    [_supperBtn release];
    [_lunchLabel release];
    [_superLabel release];
    [_orderBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLunchBtn:nil];
    [self setSupperBtn:nil];
    [self setLunchLabel:nil];
    [self setSuperLabel:nil];
    [self setOrderBtn:nil];
    [super viewDidUnload];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERRESULT object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Order];
    [super viewDidDisappear:YES];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setUpOrderState];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Order];
    [super viewDidAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];

    [_orderBtn.layer setMasksToBounds:YES];
    [_orderBtn.layer setCornerRadius:6.0];//设置矩形四个圆角半径
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectBtnPress:(UIButton *)sender {
    sender.selected=!sender.selected;
}

- (IBAction)orderBtnPress:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrderResult:) name:NOTIFY_ORDERRESULT object:nil];

    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
    }
    
    NSString *nendlunch=_lunchBtn.selected ? @"True" : @"False";
    NSString *nendSuper=_supperBtn.selected ? @"True" : @"False";
    
    NSString *fullUrlString = [URL_BASE stringByAppendingString:URL_USER_POST_ORDER];
    NSURL *url=[NSURL URLWithString:fullUrlString];
    ASIFormDataRequest *requestItem = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    [requestItem setPostValue:nendlunch forKey:KEY_LUNCH];
    [requestItem setPostValue:nendSuper forKey:KEY_SUPPER];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES request:requestItem method:@"POST" tag:PostOrder];
}

//报餐统计
- (IBAction)orderStatistics:(UIButton *)sender {
    OrderStatisticsVC *statistics=[[OrderStatisticsVC alloc] init];
    [self.navigationController pushViewController:statistics animated:YES];
    
    [[BaiduMobStat defaultStat] logEvent:kStat_eStatList eventLabel:@"报餐统计"];
}

#pragma mark --my function --
//处理订餐结果
-(void) handleOrderResult:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERRESULT object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OrderResult];
    NSDictionary *orderResultDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        orderResultDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    //NSDictionary *orderResultDictionary=[[notify userInfo] objectForKey:KEY_MY_Dic_OrderResult];
    //Log(@"报餐结果：%@",[NSString stringWithFormat:@"%@",[orderResultDictionary objectForKey:KEY_MSG]]);
    [self.view makeToast:[NSString stringWithFormat:@"%@",[orderResultDictionary objectForKey:KEY_MSG]]];
    
    if ([[NSString stringWithFormat:@"%@",[orderResultDictionary objectForKey:KEY_STATE]] isEqualToString:@"0"]) {
        _lunchBtn.selected ?
                [_lunchLabel setText:@"午餐（工作餐）（已报）"]
                :[_lunchLabel setText:@"午餐（工作餐）（不报）"];
        _supperBtn.selected ?
        [_superLabel setText:@"晚餐（学习餐）（已报）"]
        :[_superLabel setText:@"晚餐（学习餐）（不报）"];
    }
    [[BaiduMobStat defaultStat] logEvent:kStat_eOrder eventLabel:@"报餐"];
}

-(void)setUpOrderState{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    UserObj *curUser=[appDelegate currentUser];

    if ([curUser.Lunch isEqualToString:@""]) {
        [_lunchLabel setText:@"午餐（工作餐）（未报）"];
        _lunchBtn.selected=NO;
    }else if([curUser.Lunch isEqualToString:@"True"]) {
        [_lunchLabel setText:@"午餐（工作餐）（已报）"];
        _lunchBtn.selected=YES;
    }else if([curUser.Lunch isEqualToString:@"False"]) {
        [_lunchLabel setText:@"午餐（工作餐）（不报）"];
        _lunchBtn.selected=NO;
    }
    
    if ([curUser.Supper isEqualToString:@""]) {
        [_superLabel setText:@"晚餐（学习餐）（未报）"];
        _supperBtn.selected=NO;
    }else if([curUser.Supper isEqualToString:@"True"]) {
        [_superLabel setText:@"晚餐（学习餐）（已报）"];
        _supperBtn.selected=YES;
    }else if([curUser.Supper isEqualToString:@"False"]) {
        [_superLabel setText:@"晚餐（学习餐）（不报）"];
        _supperBtn.selected=NO;
    }
    
}

@end

















