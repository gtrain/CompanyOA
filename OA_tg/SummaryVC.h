//
//  WriteSummaryVC.h
//  testAlertMenu
//
//  Created by yzq on 13-7-17.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+HXAddtions.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "LogDataOjb.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIFormDataRequest.h"

@interface SummaryVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITableView *summaryTable;

//_mark 对数组的处理: 如果 !nil 则插入，reload ; 如果 nil 则创建一个

@property(nonatomic,strong) NSMutableArray *todayWorkArray; //今日工作
@property(nonatomic,strong) NSMutableArray *tomorrowTargetsArray;  //明天计划
@property (nonatomic,strong) NSString *feelingString;  //日感想
@property (nonatomic) BOOL useDraft;

@end
