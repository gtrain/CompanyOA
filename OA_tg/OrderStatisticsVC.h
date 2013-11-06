//
//  OrderStatisticsVC.h
//  OA_TGNET
//
//  Created by yzq on 13-7-18.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Toast+UIView.h"

@interface OrderStatus : NSObject
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *Lunch;
@property (nonatomic,strong) NSString *Supper;
@property (nonatomic,strong) NSString *OrderTime;

+(OrderStatus *) orderStatusWithDictionary:(NSDictionary *)dataDictionary;

@end

@interface OrderStatisticsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    BOOL _isShowingActivity;
}
@property (nonatomic,strong) UIButton *departMentBtn;           //部门选择按钮
@property (nonatomic,strong) UILabel *lunchStaLabel;
@property (nonatomic,strong) UILabel *supperStaLabel;

@property (nonatomic,strong) UITableView *orderResultTableView;
@property (nonatomic,strong) NSArray *orderResultArray;

@end