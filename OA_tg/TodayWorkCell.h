//
//  TodayWorkCell.h
//  OA_TGNET
//
//  Created by yzq on 13-7-23.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TodayWorkCellHeight 210

@interface TodayWorkCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *tarTypeLabel;

@property (retain, nonatomic) IBOutlet UILabel *tarContentLabel;
@property (retain, nonatomic) IBOutlet UILabel *tarMayCostTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *tarCostTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *tarAffectUserLabel;
@property (retain, nonatomic) IBOutlet UILabel *tarCorperLabel;
@property (retain, nonatomic) IBOutlet UILabel *tarProgressLabel;
@property (retain, nonatomic) IBOutlet UITextView *tarFinishStateTextView;

@end

//logID = 6846;             //数据id
//tarAffectUser = "";       //影响人，（被协助的那个）
//tarContent = 53123123;    //计划的内容
//tarCorper = "";           //协助人
//tarCostTime = 0;          //实际用时
//tarFinishState = "";      //完成情况
//tarID = 127389;           //计划的id (相当于标题)
//tarMayCostTime = 5;       //可能花费的时间
//tarProgress = 0;          //进度
//tarType = 4;              //类型，可能是常规任务，临时任务，这些