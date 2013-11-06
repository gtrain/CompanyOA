//
//  TodaySworkViewController.h
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TargetsDataObj.h"
#import "UIAlertView+Blocks.h"
#import "PBFlatRoundedImageView.h"
#import "RRSGlowLabel.h"
#import "LogDataOjb.h"
#import "UserObj.h"
#import "AppDelegate.h"

@interface TodaySworkViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

//@property (nonatomic,strong) NSMutableArray *todayTargetsArray;
@property (nonatomic,strong) LogDataOjb *myLogObj;              //存放今日OA对象
//@property (nonatomic,strong) NSMutableArray *todayTargetsArray;        //今日任务数组
@property (retain, nonatomic) IBOutlet UITableView *targetsTable;
@property (retain, nonatomic) IBOutlet UIView *tableCoverView;

- (IBAction)writeSummary:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIImageView *refreshImgView;
- (IBAction)refreshMyOA:(UIButton *)sender;


@property (retain, nonatomic) IBOutlet PBFlatRoundedImageView *userAvatarImgView;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *feelingLabel;

@property (retain,nonatomic) AppDelegate *appDelegate;

@end
