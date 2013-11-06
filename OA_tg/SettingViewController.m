//
//  SettingViewController.m
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "SettingViewController.h"
#import "NavigationBarWithBg.h"
#import "AppDelegate.h"

@interface SettingViewController (){
    UIView *alphaBgView;
    AppDelegate *appDelegate;
//    UILocalNotification *notification;          //oa提醒
//    UILocalNotification *orderNotification;     //报餐提醒
}

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    
    //导航栏
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:@"设置" LeftBtnTitle:nil RightBtnTitle:nil];
    [self.view addSubview:navBar];
    [navBar release];
    
    [self setupTableView];
    //Log(@"oa按钮：%d ; order按钮：%d",oaRemindSwitch.retainCount,orderSwitch.retainCount);
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //查询是否有为处理的提醒
    if (appDelegate.currentUser.oaNotification) {
        [oaRemindSwitch setOn:YES];
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSString *dataString=[dateFormat stringFromDate:appDelegate.currentUser.oaNotification.fireDate];
        [dateFormat release];
        if (dataString) {
            oaRemindDateLabel.text=dataString;
        }
        
        if ([[appDelegate.currentUser.oaNotification.userInfo objectForKey:key_voice] isEqualToString:@"1"]) {
            [voiceSwitch setOn:YES];
        }
        if ([[appDelegate.currentUser.oaNotification.userInfo objectForKey:key_shake] isEqualToString:@"1"]) {
            [shakeSwitch setOn:YES];
        }
    }
//    else{
//        UILocalNotification *oaNotification=[[UILocalNotification alloc] init];
//        [oaNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//        [oaNotification setAlertBody:@"到写OA的时间了！"];
//        [appDelegate.currentUser setOaNotification:oaNotification];
//        [oaNotification release];
//    }
    
    if (appDelegate.currentUser.orderNotification) {
        [orderSwitch setOn:YES];
        if ([[appDelegate.currentUser.orderNotification.userInfo objectForKey:key_voice] isEqualToString:@"1"]) {
            [voiceSwitch setOn:YES];
        }
        if ([[appDelegate.currentUser.orderNotification.userInfo objectForKey:key_shake] isEqualToString:@"1"]) {
            [shakeSwitch setOn:YES];
        }
    }
//    else{
//        UILocalNotification *orderNotification=[[UILocalNotification alloc] init];
//        [orderNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//        [orderNotification setAlertBody:@"到写报餐的时间了！"];
//        [appDelegate.currentUser setOaNotification:orderNotification];
//        [orderNotification release];
//    }
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Set];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Set];
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.setttingTableView = nil;
    [oaRemindSwitch release];
    [orderSwitch release];
    
    [datePicker release];
    [alphaBgView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void) setupTableView{
    self.setttingTableView=[[[UITableView alloc] initWithFrame:CGRectMake(0, navBarHeight, ScreenBoundsSize.width, ScreenBoundsSize.height-navBarHeight-48) style:UITableViewStyleGrouped] autorelease];
    _setttingTableView.delegate=self;
    _setttingTableView.dataSource=self;
    [_setttingTableView setBackgroundView:nil];  //_第一个页面也设置下
    [_setttingTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_setttingTableView];
    [_setttingTableView release];
//  时间选择器
    alphaBgView=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [alphaBgView setBackgroundColor:[UIColor blackColor]];
    [alphaBgView setAlpha:.0];
    
    datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 236)];
    [datePicker setDatePickerMode:UIDatePickerModeTime];

    [datePicker addTarget:self action:@selector(remindDateChanged) forControlEvents:UIControlEventValueChanged];
    [[[UIApplication sharedApplication] keyWindow] addSubview:datePicker];
    [datePicker release];

}
- (void)logoutBtnPress:(UIButton *)sender {
    //1. 从用户组中删除   2.删除当前用户
    [appDelegate popFromUsersBox];
    [appDelegate removeUserInUserDefault];
    [self.navigationController popViewControllerAnimated:YES];
    [[BaiduMobStat defaultStat] logEvent:kStat_eLoyout eventLabel:[NSString stringWithFormat:@"%@ 注销登陆",appDelegate.currentUser.userName]];
}

-(void)remindDateChanged{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *selectDateString=[dateFormat stringFromDate:datePicker.date];
    [dateFormat release];
    oaRemindDateLabel.text=selectDateString;
}
//点击退下日期选择
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *selectDateString=[dateFormat stringFromDate:datePicker.date];
    [dateFormat release];
    oaRemindDateLabel.text=selectDateString;
    
    [UIView animateWithDuration:.2 animations:^(void){
        [datePicker setFrame:CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 236)];
        alphaBgView.alpha = 0.0;
    }completion:^(BOOL finished){
        [alphaBgView removeFromSuperview];
    }];
    
    if (oaRemindSwitch.isOn) {  //每次更改时间的时候检查一下是否开启了提醒，是的话重设一下时间
        [self performSelector:@selector(switchValueChange:) withObject:oaRemindSwitch];
    }

}

-(void) switchValueChange:(UISwitch *)sender{
    //声音跟震动设置
    if (sender.tag==TAGOA) {       //oa提醒按钮
        [self notificationForOA];
    }
    else if(sender.tag==TAGORDER){     //订餐提醒按钮
        [self notificationForOrder];
    }
    else if(sender.tag==TAGSHAKE || sender.tag==TAGVOICE){
        if (oaRemindSwitch.isOn) {
            [self notificationForOA];
        }
        if (orderSwitch.isOn) {
            [self notificationForOrder];
        }
    }
}

-(void) notificationForOA{
    [[BaiduMobStat defaultStat] logEvent:kStat_eRemindUsage eventLabel:@"日志提醒"];
    NSString *needVoice=[NSString stringWithFormat:@"%d",voiceSwitch.isOn];
    NSString *shakeVoice=[NSString stringWithFormat:@"%d",shakeSwitch.isOn];
    if (!appDelegate.currentUser.oaNotification) {
        UILocalNotification *oaNotification=[[UILocalNotification alloc] init];
        [oaNotification setTimeZone:[NSTimeZone defaultTimeZone]];
        [oaNotification setAlertBody:@"到写OA的时间了！"];
        [appDelegate.currentUser setOaNotification:oaNotification];
        [oaNotification release];
        //[[UIApplication sharedApplication] cancelLocalNotification:notification];   //重置通知，（如果之前已经设置了一个预定时间，要清除一下）
    }
    [[UIApplication sharedApplication] cancelLocalNotification:appDelegate.currentUser.oaNotification];   //取消通知
    
    if (oaRemindSwitch.isOn) {
        //oa提醒
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *selectDateString=[dateFormat stringFromDate:[NSDate date]];
        selectDateString=[selectDateString stringByAppendingFormat:@" %@:00",oaRemindDateLabel.text];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *selectDate=[dateFormat dateFromString:selectDateString];
        [dateFormat release];
        
        NSTimeInterval timerInterval=[selectDate timeIntervalSinceDate:[NSDate date]];
        //Log(@"时间间隔:%f",timerInterval);
        
        [appDelegate.currentUser.oaNotification setFireDate:selectDate];                              //设置OA的提醒时间
        [appDelegate.currentUser.oaNotification setSoundName:UILocalNotificationDefaultSoundName];    //声音提示
        NSDictionary *userInfoDic=[NSDictionary dictionaryWithObjectsAndKeys:needVoice,key_voice,shakeVoice,key_shake,@"OA提醒",key_titile,@"写日志的时间到了",key_message, nil];
        [appDelegate.currentUser.oaNotification setUserInfo:userInfoDic];
        
        //[appDelegate.currentUser setOaNotification:notification];         //设置了就保存到用户去，超时的话，今天不作处理
        [appDelegate saveToUserDefaultAtOnce:YES];
        
        if (timerInterval>1) {  //如果没有过时，才发起通知
            [[UIApplication sharedApplication] scheduleLocalNotification:appDelegate.currentUser.oaNotification]; //发布定时通知
        }
    }else{
        [[UIApplication sharedApplication] cancelLocalNotification:appDelegate.currentUser.oaNotification];   //取消通知
        [appDelegate.currentUser setOaNotification:nil];
        [appDelegate saveToUserDefaultAtOnce:YES];
    }
}
-(void) notificationForOrder{
    [[BaiduMobStat defaultStat] logEvent:kStat_eRemindUsage eventLabel:@"报餐提醒"];
    NSString *needVoice=[NSString stringWithFormat:@"%d",voiceSwitch.isOn];
    NSString *shakeVoice=[NSString stringWithFormat:@"%d",shakeSwitch.isOn];

    if (!appDelegate.currentUser.orderNotification) {
        UILocalNotification *orderNotification=[[UILocalNotification alloc] init];
        [orderNotification setTimeZone:[NSTimeZone defaultTimeZone]];
        [orderNotification setAlertBody:@"到报餐的时间了！"];
        [appDelegate.currentUser setOrderNotification:orderNotification];
        [orderNotification release];
        //[[UIApplication sharedApplication] cancelLocalNotification:notification];   //重置通知，（如果之前已经设置了一个预定时间，要清除一下）
    }

    [[UIApplication sharedApplication] cancelLocalNotification:appDelegate.currentUser.orderNotification];   //取消通知
    
    
    if (orderSwitch.isOn) {
        //报餐提醒
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *selectDateString=[dateFormat stringFromDate:[NSDate date]];
        selectDateString=[selectDateString stringByAppendingString:@" 09:00:00"];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *selectDate=[dateFormat dateFromString:selectDateString];
        [dateFormat release];
        
        NSTimeInterval timerInterval=[selectDate timeIntervalSinceDate:[NSDate date]];

        [appDelegate.currentUser.orderNotification setFireDate:selectDate];                              //设置OA的提醒时间
        [appDelegate.currentUser.orderNotification setSoundName:UILocalNotificationDefaultSoundName];    //声音提示
        NSDictionary *userInfoDic=[NSDictionary dictionaryWithObjectsAndKeys:needVoice,key_voice,shakeVoice,key_shake,@"报餐提醒",key_titile,@"报餐的时间到了",key_message, nil];
        [appDelegate.currentUser.orderNotification setUserInfo:userInfoDic];
        
        //[appDelegate.currentUser setOrderNotification:appDelegate.currentUser.orderNotification];           //保存到用户去
        [appDelegate saveToUserDefaultAtOnce:YES];
        
        if (timerInterval>1) {  //如果过时了，不作处理
            [[UIApplication sharedApplication] scheduleLocalNotification:appDelegate.currentUser.orderNotification];
        }
        
    }else{
        [[UIApplication sharedApplication] cancelLocalNotification:appDelegate.currentUser.orderNotification];   //取消通知
        [appDelegate.currentUser setOrderNotification:nil];           //保存到用户去
        [appDelegate saveToUserDefaultAtOnce:YES];
    }
}

#pragma mark --UITableViewDelegate,UITableViewDataSource--
//选择某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            //[self.view insertSubview:alphaBgView belowSubview:datePicker];
            [self.view addSubview:alphaBgView];
            [UIView animateWithDuration:.2 animations:^(void){
                [datePicker setFrame:CGRectMake(0, ScreenBoundsSize.height-216, ScreenBoundsSize.width, 236)];
                alphaBgView.alpha = 0.6;
            }completion:nil];
        }
    }else if(indexPath.section==3){
        if (indexPath.row==0) {
            AboutViewController *aboutVC=[[AboutViewController alloc] init];
            [self.navigationController pushViewController:aboutVC animated:YES];
            [aboutVC release];
        }else if(indexPath.row==1){
            
            //切换帐号 1. 存入用户数组  2.删除当前用户
            [appDelegate pushToUsersBox];
            [appDelegate removeUserInUserDefault];
            [self.navigationController popViewControllerAnimated:YES];
            
            [[BaiduMobStat defaultStat] logEvent:kStat_eToggle eventLabel:[NSString stringWithFormat:@"%@ 切换帐号",appDelegate.currentUser.userName]];
//            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"切换提示" message:@"切换帐号只保存用户名跟密码！"
//                                                     cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
//                
//            }]
//                                                     otherButtonItems:[RIButtonItem itemWithLabel:@"切换" action:^{
//                
//            }], nil];
//            [alertView show];
//            [alertView release];  
        }
    }

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==2 || section==6) {
        return 1;
    }else if(section==4 || section==5){
        return 0;
    }
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"oaRemindCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"oaRemindCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                oaRemindSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(212, 8, 0, 0)];
                [oaRemindSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                oaRemindSwitch.tag=TAGOA;
                [cell.contentView addSubview:oaRemindSwitch];
                [oaRemindSwitch release];
                cell.textLabel.text=@"OA提醒";
            }
            return cell;
        }else{
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"remindDateCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"remindDateCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                oaRemindDateLabel=[[UILabel alloc] initWithFrame:CGRectMake(200, 8, 72, 24)];
                [oaRemindDateLabel setTextAlignment:NSTextAlignmentRight];
                [oaRemindDateLabel setBackgroundColor:[UIColor clearColor]];
                [cell.contentView addSubview:oaRemindDateLabel];
                [oaRemindDateLabel release];
                cell.textLabel.text=@"提醒时间";
                oaRemindDateLabel.text=@"20:00";    //这里改动时间，因为每次都会重用，就是没有滚动也要注意
            }
            return cell;
        }
    }
    if (indexPath.section==1) {
        if (indexPath.row==0) {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"voiceCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"voiceCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                voiceSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(212, 8, 0, 0)];
                [voiceSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                voiceSwitch.tag=TAGVOICE;
                
                [cell.contentView addSubview:voiceSwitch];
                [voiceSwitch release];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.textLabel.text=@"声音提醒";
            }
            return cell;
        }else{
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"shakeCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"shakeCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                shakeSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(212, 8, 0, 0)];
                [shakeSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                shakeSwitch.tag=TAGSHAKE;
                
                [cell.contentView addSubview:shakeSwitch];
                [shakeSwitch release];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.textLabel.text=@"震动提醒";
            }
            return cell;
        }
    }
    if (indexPath.section==2) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"orderCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"orderCell"] autorelease];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
            orderSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(212, 8, 0, 0)];
            [orderSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:orderSwitch];
            [orderSwitch release];
            orderSwitch.tag=TAGORDER;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.textLabel.text=@"报餐提醒(时间：早上9点)";
        }
        return cell;
    }
    if (indexPath.section==3) {
        if (indexPath.row==0) {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"aboutCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"aboutCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                cell.textLabel.text=@"关于";
            }
            return cell;
        }else{
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"managerCell"];
            if (!cell) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"managerCell"] autorelease];
                [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                cell.textLabel.text=@"切换帐号";
            }
            return cell;
        }
    }
    if (indexPath.section==tableView.numberOfSections-1) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"logoutCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"logoutCell"] autorelease];
            CGRect btnFrame=cell.frame;
            btnFrame.size.width -= 18;
            LogOutBtn=[[UIButton alloc] initWithFrame:btnFrame];
            [LogOutBtn setTitle:@"注销登陆" forState:UIControlStateNormal];
            [LogOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [LogOutBtn addTarget:self action:@selector(logoutBtnPress:) forControlEvents:UIControlEventTouchUpInside];
            [cell setBackgroundColor:[UIColor colorWithRed:0 green:144/255.0 blue:191/255.0 alpha:1.0]];
            [cell.contentView addSubview:LogOutBtn];
        }
        
        return cell;
    }
    return [[[UITableViewCell alloc] init] autorelease];
}


@end
