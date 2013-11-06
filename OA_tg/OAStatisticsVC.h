//
//  OAStatisticsVC.h
//  OA_TGNET
//
//  Created by yzq on 13-7-22.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Toast+UIView.h"

@interface OAStatus : NSObject
#define KEY_UserCount   @"UserCount"
#define KEY_WriteCount  @"WriteCount"
#define KEY_LogDetails  @"LogDetails"

#define KEY_LogPubDate  @"logPubDate"
#define KEY_LogState    @"logState"
#define KEY_UserName    @"userName"

@property (nonatomic,strong) NSString *logPubDate;
@property (nonatomic,strong) NSString *logState;
@property (nonatomic,strong) NSString *userName;
+(OAStatus *) OAStatusWithDictionary:(NSDictionary *)dataDictionary;

@end


@interface OAStatisticsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    BOOL _isShowingActivity;
}

@property (nonatomic,strong) UIButton *departMentBtn;   //部门选择按钮
@property (nonatomic,strong) UILabel *OASurveyLabel;    //OA统计概况

@property (nonatomic,strong) UITableView *OAStatisticsTableView;
@property (nonatomic,strong) NSArray *OAStatisticsArray;

@property (nonatomic,strong) NSString *dateString;

@end
