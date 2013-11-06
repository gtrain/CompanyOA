//
//  OrderViewController.h
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetWorkEngine.h"

#define KEY_LUNCH       @"Lunch"
#define KEY_SUPPER      @"Supper"

@interface OrderViewController : UIViewController{
    BOOL _isShowingActivity;
}

@property (retain, nonatomic) IBOutlet UILabel *lunchLabel;
@property (retain, nonatomic) IBOutlet UILabel *superLabel;

@property (retain, nonatomic) IBOutlet UIButton *orderBtn;

//选择
@property (retain, nonatomic) IBOutlet UIButton *lunchBtn;
@property (retain, nonatomic) IBOutlet UIButton *supperBtn;
- (IBAction)selectBtnPress:(UIButton *)sender;
//报餐
- (IBAction)orderBtnPress:(UIButton *)sender;
//统计
- (IBAction)orderStatistics:(UIButton *)sender;
@end
