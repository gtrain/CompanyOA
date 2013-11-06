//
//  SettingViewController.h
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "UIAlertView+Blocks.h"

typedef enum{
    TAGOA,
    TAGORDER,
    TAGVOICE,
    TAGSHAKE,
} SwitchTag;

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UISwitch *oaRemindSwitch;   //oa提醒的switch
    UILabel *oaRemindDateLabel; //提醒时间显示
    
    UISwitch *voiceSwitch;      //声音提醒
    UISwitch *shakeSwitch;      //震动提醒
    
    UISwitch *orderSwitch;      //报餐提醒
    UIButton *LogOutBtn;        //退出登陆按钮
    
    UIDatePicker *datePicker;   //时间
}
@property (nonatomic,strong) UITableView *setttingTableView;

@end
