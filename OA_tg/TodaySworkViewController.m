//
//  TodaySworkViewController.m
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "TodaySworkViewController.h"
#import "NetWorkEngine.h"
#import "SummaryVC.h"
#import "Global.h"

//表情的大小，跟文本框的宽度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH         188
//表情截取符
#define BEGIN_FLAG  @"["
#define END_FLAG    @"]"

@interface TodaySworkViewController (){
    UIView *alertBg;
    UIView *alertView;  //报餐提示弹窗

    UIButton *lunchBtn;
    UIButton *superBtn; //报餐按钮
    
    CABasicAnimation *animation;
    
    BOOL _isShowingActivity;
}
@end

@implementation TodaySworkViewController


-(void) dealloc{
//    self.todayTargetsArray=nil;
    self.myLogObj=nil;
    [self setTargetsTable:nil];
    [_userAvatarImgView release];
    [_userNameLabel release];
    [_feelingLabel release];
    [_userAvatarImgView release];
    [_userNameLabel release];
    [_userNameLabel release];
    [_refreshImgView release];
    [animation release];
    [super dealloc];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TARGETSRESULT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERSTATUS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERRESULT_ALERT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MYOADETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MyAvatar object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [_refreshImgView.layer removeAnimationForKey:@"animation"];
        _isShowingActivity =NO;
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Main];
    [super viewDidDisappear:YES];
}
-(void) viewDidAppear:(BOOL)animated{
    NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:2];
    [_targetsTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Main];
    [super viewDidAppear:YES];
}

- (void)viewDidLoad
{
    [self.view setUserInteractionEnabled:NO];
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        [_refreshImgView.layer addAnimation:animation forKey:@"animation"];
        _isShowingActivity =YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryWhenLogined) name:NOTIFY_FinishRefreshCookie object:nil];
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    self.appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    animation =[[CABasicAnimation alloc] init];
    [animation setKeyPath:@"transform"];
    animation.delegate = self;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI , 0, 0, 1.0)];
    animation.duration = 1.3;
    animation.cumulative = YES;
    animation.repeatCount = INT_MAX;
    
    //  本用户报餐情况的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrederStatus:) name:NOTIFY_ORDERSTATUS object:nil];

//    //判断是否超过下午5点了（17）
//    NSDate *date=[NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HHmmss"];
//    NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
//    [dateFormatter release];
//    if (170000-dateValue>0) {
//        //    获取今日任务
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTargetsResult:) name:NOTIFY_TARGETSRESULT object:nil];
//        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:nil apiString:URL_USER_GET_TARGETS Method:@"GET" Tag:GetTargets];
//    }else{
        //    获取我的OA
//    }
    
    //用户名的阴影设置
    [self.userAvatarImgView setImage:[UIImage imageNamed:@"login_avatar_default"]];
    self.userNameLabel.text=_appDelegate.currentUser.userName;
    self.userNameLabel.glowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.userNameLabel.glowOffset = CGSizeMake(1.5, 1.5);
    self.userNameLabel.glowAmount = 2.0;

    [self setUpTable];
}

-(void) queryWhenLogined{
//    NSLog(@"queryWhenLogined");
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_FinishRefreshCookie object:nil];
    
    //请求头像
    NSString *faceString=[NSString stringWithFormat:@"%@",_appDelegate.currentUser.userFace];
    if (![faceString isEqualToString:@""] && _appDelegate.currentUser.userFace) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAvatar:) name:NOTIFY_MyAvatar object:nil];
        [[NetWorkEngine shareNetWorkEngine] addRequestWithUrlString:faceString Method:@"GET" Tag:GetMyAvatar Index:nil];
    }
    [self refreshMyOA:nil];
    
    //查询报餐情况
    NSString *queryOrderUrl=[NSString stringWithFormat:@"%@&UserName=%@",URL_USER_GET_ORDERLIST,_appDelegate.currentUser.userName];
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //NSString *pageSource = [[NSString alloc] initWithData:pageData encoding:gbkEncoding];
    queryOrderUrl=[queryOrderUrl stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:nil apiString:queryOrderUrl Method:@"GET" Tag:GetUserOrderStatues];

    //查询是否有为处理的提醒
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSInteger nowDateNum=[[dateFormat stringFromDate:[NSDate date]] integerValue];
    if (_appDelegate.currentUser.oaNotification) {
        NSString *remindDateString=[dateFormat stringFromDate:_appDelegate.currentUser.oaNotification.fireDate];
        NSInteger oaDataNum=[remindDateString integerValue];
        if (oaDataNum-nowDateNum>0) {
            [dateFormat setDateFormat:@"yyyyMMdd"];
            NSString *todayDateString=[dateFormat stringFromDate:[NSDate date]];
            todayDateString =[todayDateString stringByAppendingString:remindDateString];
            [dateFormat setDateFormat:@"yyyyMMddHHmm"];
            NSDate *turnTotoday=[dateFormat dateFromString:todayDateString];
            [_appDelegate.currentUser.oaNotification setFireDate:turnTotoday];
            //保持时间不变，日期改成今天的。
            
            [[UIApplication sharedApplication] scheduleLocalNotification:_appDelegate.currentUser.oaNotification];
        }
    }
    
    if (_appDelegate.currentUser.orderNotification) {
        [dateFormat setDateFormat:@"HHmm"];
        NSString *orderRemindDateString=[dateFormat stringFromDate:_appDelegate.currentUser.orderNotification.fireDate];
        NSInteger orderDataNum=[orderRemindDateString integerValue];
        if (orderDataNum-nowDateNum>0) {
            [dateFormat setDateFormat:@"yyyyMMdd"];
            NSString *todayDateString=[dateFormat stringFromDate:[NSDate date]];
            todayDateString =[todayDateString stringByAppendingString:orderRemindDateString];
            [dateFormat setDateFormat:@"yyyyMMddHHmm"];
            NSDate *turnTotoday=[dateFormat dateFromString:todayDateString];
            [_appDelegate.currentUser.orderNotification setFireDate:turnTotoday];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:_appDelegate.currentUser.orderNotification];
        }
    }
    [dateFormat release];
}

-(void) setUpTable{
    //[self.targetsTable addParallelViewWithUIView:self.awesomeZG withDisplayRadio:0.7 cutOffAtMax:YES];
    self.targetsTable.delegate=self;
    self.targetsTable.dataSource=self;
    [self.targetsTable setBackgroundView:nil];
    [self.targetsTable setBackgroundColor:[UIColor clearColor]];
}

-(void) getMyOADetail{
    //用户名
    NSString *userName=[_appDelegate.currentUser userNo];
    NSDictionary *userNameDic=[NetWorkEngine synthesisCookiePropertiesWithValue:userName name:KEY_UserNameOrNo];
    //起始结束时间
    
    //NSDate *date=[NSDate date];
    
    NSTimeInterval  interval =17*60*60;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-interval];   //每天17点前取前一天，17点后取今天
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    [date release];
    [dateFormatter release];
    
//    NSDictionary *dateDic=[NetWorkEngine synthesisCookiePropertiesWithValue:@"2013-07-24" name:KEY_START];
//    NSDictionary *dateEndDic=[NetWorkEngine synthesisCookiePropertiesWithValue:@"2013-07-24" name:KEY_END];
    
    NSDictionary *dateDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_START];
    NSDictionary *dateEndDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_END];
    
    NSMutableArray *inforArray=[NSMutableArray arrayWithObjects:userNameDic,dateDic,dateEndDic,nil];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_OADETAILLIST Method:@"GET" Tag:GetMyOADetail];
}

//处理我的OA信息
-(void) handleMyOAList:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MYOADETAIL object:nil];
    //去掉旋转圈圈
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [_refreshImgView.layer removeAnimationForKey:@"animation"];
        _isShowingActivity =NO;
    }
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_MyOaDetail];
    NSDictionary *OADetailDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        OADetailDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
    
        NSArray *OaDataArray=[OADetailDictionary objectForKey:KEY_DATA];
        if (OaDataArray && OaDataArray.count) {
            NSDictionary *oaLogDic=[OaDataArray objectAtIndex:0];
            self.myLogObj=[LogDataOjb logWithDictionary:oaLogDic];

            //日感想
            if (_myLogObj.feeling) {
                while (self.feelingLabel.subviews.lastObject) {
                    [self.feelingLabel.subviews.lastObject removeFromSuperview];
                }
                self.feelingLabel.text=nil;
                [self.feelingLabel addSubview:[self viewWithMessage:_myLogObj.feeling]];
            }
            //        self.todayTargetsArray=_myLogObj.todayTargetsArray;
            NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:1];
            [_targetsTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }
    
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
    
}
-(void) handleUserAvatar:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MyAvatar object:nil];
    id requestResult=[[notify userInfo] objectForKey:KEY_DATA];
    NSData *userAvatarData=nil;
    if([requestResult isKindOfClass:[NSData class]]){
        userAvatarData=requestResult;
        if (userAvatarData) {
            [_appDelegate.currentUser setUserFaceData:userAvatarData];  //保存用户头像
            [_appDelegate saveToUserDefaultAtOnce:YES];

            UIImage *userAvatar=[UIImage imageWithData:userAvatarData];
            [_userAvatarImgView setImage:userAvatar];
            [_targetsTable reloadData];
        }
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --UITableViewDelegate UITableViewDataSource--



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0? 152.0 : 22.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return self.tableCoverView;
    }
    UILabel *headerLabel=[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, 162)] autorelease];
    [headerLabel setFont:[UIFont systemFontOfSize:13]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setShadowColor:[UIColor colorWithWhite:.0 alpha:.5]];
    [headerLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    switch (section) {
        case 1:
            headerLabel.text=@"  今日任务";
            break;
        case 2:
            headerLabel.text=@"  其他信息";
            break;
        default:
            break;
    }
    return headerLabel;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==2 && indexPath.row==0) {
        if (_appDelegate.currentUser.oaDraft) {
            SummaryVC *summary=[[SummaryVC alloc] init];
            summary.useDraft=YES;
            [self.navigationController pushViewController:summary animated:YES];
            [summary release];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowsCount=0;
    if (section==1) {
        NSDate *date=[NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HHmmss"];
        NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
        [dateFormatter release];
        BOOL isLate = 170000-dateValue>0;
        rowsCount=_myLogObj? isLate ?  _myLogObj.tomorrowTargetsArray.count :  _myLogObj.todayTargetsArray.count : 0;
    }else if(section==2){
        rowsCount=4;
    }
    return rowsCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        static NSString *cellIdentify=@"targetCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify] autorelease];
            [cell.textLabel setTextColor:[UIColor colorWithRed:86/255.0 green:109/255.0 blue:150/255.0 alpha:1.0]];
        }
        if (_myLogObj) {
            //判断是否超过下午5点了（17）
            NSDate *date=[NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HHmmss"];
            NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
            [dateFormatter release];
            BOOL isLate = 170000-dateValue>0;

            TargetsDataObj *targetsObj= isLate ? [_myLogObj.tomorrowTargetsArray objectAtIndex:indexPath.row]:[_myLogObj.todayTargetsArray objectAtIndex:indexPath.row];
            
            cell.textLabel.text=targetsObj.tarContent;
            cell.detailTextLabel.text=[NSString stringWithFormat:@"预计用时：%@小时",targetsObj.tarMayCostTime];
        }
        return cell;
    }else{
        static NSString *cellIdentify=@"MsgCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentify] autorelease];
            [cell.detailTextLabel setTextColor:[UIColor grayColor]];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        if (indexPath.row==0) {
            cell.textLabel.text=@"今日总结：";
            cell.detailTextLabel.text= _appDelegate.currentUser.hadOaLog;
            if (_appDelegate.currentUser.oaDraft) {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
    
        }else if (indexPath.row==1) {
            cell.textLabel.text=@"OA提醒：";
            cell.detailTextLabel.text=_appDelegate.currentUser.oaNotification.fireDate ? [dateFormatter stringFromDate:_appDelegate.currentUser.oaNotification.fireDate] : @"没有设置";
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else if (indexPath.row==2) {
            cell.textLabel.text=@"报餐：";
            cell.detailTextLabel.text=[_appDelegate.currentUser.Lunch isEqualToString:@""] ?  @"没有报餐" : @"已经报餐" ;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else if (indexPath.row==3) {
            cell.textLabel.text=@"报餐提醒：";
            cell.detailTextLabel.text=_appDelegate.currentUser.orderNotification.fireDate ? [dateFormatter stringFromDate:_appDelegate.currentUser.orderNotification.fireDate] : @"没有设置";
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        [dateFormatter release];
        return cell;
    }
}

#pragma mark -- my function --
//处理今日任务结果
//-(void) handleTargetsResult:(NSNotification *)notify{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TARGETSRESULT object:nil];
//    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_TargetsResult];
//    NSDictionary *targetsResultDictionary=nil;
//    if([requestResult isKindOfClass:[NSDictionary class]]){
//        targetsResultDictionary=requestResult;
//    }else if ([requestResult isKindOfClass:[NSString class]]) {
//        [self.view makeToast:requestResult];    //显示错误信息
//        return;
//    }else{
//        [self.view makeToast:@"没有数据"];
//        return;
//    }
//    
//    NSArray *dataArray=[targetsResultDictionary objectForKey:KEY_DATA];
//    
//    if (dataArray) {
//        NSMutableArray *tmpArray=[[NSMutableArray alloc] initWithCapacity:0];
//        for (int i=0; i<dataArray.count; i++) {
//            NSDictionary *targetsDictionary=(NSDictionary *)[dataArray objectAtIndex:i];
//            TargetsDataObj *target=[TargetsDataObj targetsWithDictionary:targetsDictionary];
//            [tmpArray addObject:target];
//        }
//        [self setTodayTargetsArray:tmpArray];
//        [tmpArray release];
//        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:0];
//        [_targetsTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}
//查询到用户的报餐信息
-(void) handleOrederStatus:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERSTATUS object:nil];
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OrderStatus];
    NSDictionary *orderStatusDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        orderStatusDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[orderStatusDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
    
        NSDictionary *orderDataDic=[orderStatusDictionary objectForKey:KEY_DATA];
        NSArray *orderDetailArray=(NSArray *)[orderDataDic objectForKey:KEY_ORDERDETAILS];
        if (!orderDetailArray || orderDetailArray.count!=1) {
            [self.view makeToast:@"无法获取报餐情况"];
            return;
        }
        NSDictionary *orderDetails=[orderDetailArray objectAtIndex:0];
        
        //_报餐状态存到 当前用户，刷新
        [_appDelegate.currentUser setLunch:[orderDetails objectForKey:KEY_Lunch]];
        [_appDelegate.currentUser setSupper:[orderDetails objectForKey:KEY_Supper]];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:2];
        NSArray *indexArr=[NSArray arrayWithObject:indexPath];
        [_targetsTable reloadRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
//        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:1];
//        [_targetsTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        if ([[orderDetails objectForKey:KEY_Lunch] isEqualToString:@""] || [[orderDetails objectForKey:KEY_Supper] isEqualToString:@""]) {
            //是否超过10点了
            NSDate *date=[NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HHmmss"];
            NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
            [dateFormatter release];
            if (100000-dateValue>0) {
                [self setUpAlertView];  //NSLog(@"提醒报餐 ");
                [self performSelector:@selector(showAlertView) withObject:nil afterDelay:.2];
            }
            //        else{
            //            [self.view makeToast:@"您还未报餐"];
            //        }
        }
    
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[orderStatusDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
}
-(void) handleOAlogResult:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OaWriteLog object:nil];
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OaWriteLog];
    NSDictionary *oaWriteDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        oaWriteDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    //NSDictionary *oaWriteDictionary=(NSDictionary *)[[notify userInfo] objectForKey:KEY_MY_Dic_OaWriteLog];
    NSString *oalogString=[NSString stringWithFormat:@"%@",[oaWriteDictionary objectForKey:KEY_DATA]];
    _appDelegate.currentUser.hadOaLog=[oalogString isEqualToString:@"0"] ? @"还没提交" : @"已经提交";
    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:0 inSection:2];
    NSArray     *arr        = [NSArray arrayWithObject:indexPath];
    [_targetsTable reloadRowsAtIndexPaths:arr withRowAnimation:NO];
    
//    if ([oalogString isEqualToString:@"0"]) {   //没写 OA
//        //是否超过8点了
//        NSDate *date=[NSDate date];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"HHmmss"];
//        NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
//        [dateFormatter release];
//        if (80000-dateValue>0) {
//            UIAlertView *OAalertView=[[UIAlertView alloc] initWithTitle:@"OA提醒" message:@"是不是忘了写OA？"
//                                                       cancelButtonItem:[RIButtonItem itemWithLabel:@"好的"] otherButtonItems:nil, nil];
//            [OAalertView show];
//            [OAalertView release];
//        }
//    }
}

- (IBAction)writeSummary:(UIButton *)sender {
//5点之前写日志的话，要提示一下
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
    [dateFormatter release];
    if (170000-dateValue>0) {
        UIAlertView *earlyAlertView=[[UIAlertView alloc] initWithTitle:@"时间提醒" message:@"现在还不能提交日志！"
                                                 cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
            
        }]
                                                 otherButtonItems:[RIButtonItem itemWithLabel:@"继续" action:^{
            SummaryVC *summary=[[SummaryVC alloc] init];
            [self.navigationController pushViewController:summary animated:YES];
            [summary release];
        }], nil];
        [earlyAlertView show];
        [earlyAlertView release];
    }else{
        SummaryVC *summary=[[SummaryVC alloc] init];
        [self.navigationController pushViewController:summary animated:YES];
        [summary release];
    }
}

- (IBAction)refreshMyOA:(UIButton *)sender {
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        [_refreshImgView.layer addAnimation:animation forKey:@"animation"];
        _isShowingActivity =YES;
    }
    //查询oa填写情况
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.currentUser.hadOaLog) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAlogResult:) name:NOTIFY_OaWriteLog object:nil];
        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:nil apiString:URL_USER_GET_OAlog Method:@"GET" Tag:GetOAwriteLog];
    }
    //查询OA列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMyOAList:) name:NOTIFY_MYOADETAIL object:nil];
    [self getMyOADetail];
}

#pragma mark --showAlertView--
-(void) alertBtnPress:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"确定"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrderResult:) name:NOTIFY_ORDERRESULT_ALERT object:nil];
        //Log(@"午餐%d，晚餐%d",lunchBtn.selected,superBtn.selected);
        
        NSString *nendlunch=lunchBtn.selected ? @"True" : @"False";
        NSString *nendSuper=superBtn.selected ? @"True" : @"False";
        
        NSString *fullUrlString = [URL_BASE stringByAppendingString:URL_USER_POST_ORDER];
        NSURL *url=[NSURL URLWithString:fullUrlString];
        ASIFormDataRequest *requestItem = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [requestItem setPostValue:nendlunch forKey:KEY_Lunch];
        [requestItem setPostValue:nendSuper forKey:KEY_Supper];
        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES request:requestItem method:@"POST" tag:PostOrderAlert];
    }
    [self hideAlertView:nil];
}
//处理报餐结果
-(void) handleOrderResult:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERRESULT_ALERT object:nil];
    
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

    NSString *state=[NSString stringWithFormat:@"%@",[orderResultDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
        _appDelegate.currentUser.Lunch=lunchBtn.selected ? @"True" : @"False";
        _appDelegate.currentUser.Supper=superBtn.selected ? @"True" : @"False";
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:2];
        NSArray *indexArr=[NSArray arrayWithObject:indexPath];
        [_targetsTable reloadRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
    }

    [self.view makeToast:[NSString stringWithFormat:@"%@",[orderResultDictionary objectForKey:KEY_MSG]]];
}
//报餐选择按钮
-(void) selectBtnPress:(UIButton *)sender{
    sender.selected=!sender.selected;
}

//弹窗设置
-(void)setUpAlertView{
    alertBg=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [alertBg setBackgroundColor:[UIColor blackColor]];
    alertBg.alpha=.0;
    
    alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 180)];
    [alertView setCenter:CGPointMake(ScreenBoundsSize.width/2, ScreenBoundsSize.height/2)];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(FONT_MARGIN, FONT_MARGIN/2, 232, 32)];
    [titleLabel setText:@"报餐提醒"];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    [alertView addSubview:titleLabel];
    [titleLabel release];
    
    UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(FONT_MARGIN, 42, 232, 2)];
    [lineLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.4]];
    [alertView addSubview:lineLabel];
    [lineLabel release];

    lunchBtn =[[UIButton alloc] initWithFrame:CGRectMake(FONT_MARGIN*2,lineLabel.frame.origin.y+FONT_MARGIN, 26, 26)];
    [lunchBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
    [lunchBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateSelected];
    [lunchBtn addTarget:self action:@selector(selectBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:lunchBtn];
    [lunchBtn release];
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(lunchBtn.frame.origin.x+lunchBtn.frame.size.width+FONT_MARGIN, lunchBtn.frame.origin.y-4, 128, 32)];
    [textLabel setText:@"工作餐（午餐）"];
    [alertView addSubview:textLabel];
    [textLabel release];
    
    superBtn =[[UIButton alloc] initWithFrame:CGRectMake(FONT_MARGIN*2,lunchBtn.frame.origin.y+lunchBtn.frame.size.height+FONT_MARGIN, 26, 26)];
    [superBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
    [superBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateSelected];
    [superBtn addTarget:self action:@selector(selectBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:superBtn];
    [superBtn release];
    
    UILabel *superTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(lunchBtn.frame.origin.x+lunchBtn.frame.size.width+FONT_MARGIN, textLabel.frame.origin.y+40, 128, 32)];
    [superTextLabel setText:@"学习餐（晚餐）"];
    [alertView addSubview:superTextLabel];
    [superTextLabel release];
    
    UILabel *bottomLineLabel=[[UILabel alloc] initWithFrame:CGRectMake(FONT_MARGIN, superTextLabel.frame.origin.y+44, 232, 1)];
    [bottomLineLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.4]];
    [alertView addSubview:bottomLineLabel];
    [bottomLineLabel release];
    //确定按钮
    UIButton *confirmBtn=[[UIButton alloc] initWithFrame:CGRectMake(FONT_MARGIN, bottomLineLabel.frame.origin.y+2, bottomLineLabel.frame.size.width/2-1, 36)];
    [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"easyGray"] forState:UIControlStateHighlighted];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(alertBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:confirmBtn];
    [confirmBtn release];
    //取消按钮
    UIButton *cancelBtn=[[UIButton alloc] initWithFrame:CGRectMake(alertView.frame.size.width/2, bottomLineLabel.frame.origin.y+2, bottomLineLabel.frame.size.width/2, 36)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(alertBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"easyGray"] forState:UIControlStateHighlighted];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [alertView addSubview:cancelBtn];
    [cancelBtn release];
    
    //分隔线
    UILabel *btnTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(cancelBtn.frame.origin.x-1,cancelBtn.frame.origin.y, 1, 36)];
    [btnTextLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.4]];
    [alertView addSubview:btnTextLabel];
    [btnTextLabel release];
    
    [alertView.layer setCornerRadius:8.0f];
//    [alertView.layer setBorderColor:[[UIColor colorWithWhite:.1 alpha:.5] CGColor]];
//    [alertView.layer setBorderWidth:6.0];
    
    alertView.layer.shadowColor = [UIColor blackColor].CGColor;
    alertView.layer.shadowOpacity = .4;
    alertView.layer.shadowRadius = 8.0;
    
    alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.6, 0.6);
    [alertView setBackgroundColor:[UIColor whiteColor]];
}
//弹窗动画
- (void)showAlertView{
    [[[UIApplication sharedApplication] keyWindow] addSubview:alertBg];
    [alertBg release];
    [[[UIApplication sharedApplication] keyWindow] addSubview:alertView];
    [alertView release];
    
    [UIView animateWithDuration:0.2 animations:^(void){
        alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.1f, 1.1f);
        alertBg.alpha=0.3;
    }completion:^(BOOL finished){
        [self bounceOutAnimationStoped];
    }];
}
- (void)bounceOutAnimationStoped
{
    [UIView animateWithDuration:0.1 animations:^(void){
        alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.9, 0.9);
        alertBg.alpha=0.5;
    }completion:^(BOOL finished){
        [self bounceInAnimationStoped];
    }];
}
- (void)bounceInAnimationStoped
{
    [UIView animateWithDuration:0.1 animations:^(void){
         alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1, 1);
         alertBg.alpha=0.6;
     }completion:nil];
}
//取消弹窗
- (void)hideAlertView:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        alertBg.alpha = 0.2;
        alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            alertBg.alpha = 0.0;
            alertView.alpha=0.0;
            alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,.8, .8);
        } completion:^(BOOL finished) {
            [alertBg removeFromSuperview];
            [alertView removeFromSuperview];
        }];
    }];
}

- (void)viewDidUnload {
    [self setUserAvatarImgView:nil];
    [self setUserNameLabel:nil];
    [self setFeelingLabel:nil];
    [self setUserAvatarImgView:nil];
    [self setUserNameLabel:nil];
    [self setUserNameLabel:nil];
    [self setRefreshImgView:nil];
    [super viewDidUnload];
}


#pragma mark -- 处理图文 --
-(UIView *) viewWithMessage:(NSString *)message
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    [self getImageRange:message :array];
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            //NSLog(@"str--->%@",str);
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSString *imageName=[str substringWithRange:NSMakeRange(1, str.length - 2)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<150) X = upX;
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 150;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.textColor=[UIColor colorWithRed:255/255.0 green:93/255.0 blue:29/255.0 alpha:1.0];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<150) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(0,0,X, Y+18); //@ 需要将该view的尺寸记下，方便以后复用
    return returnView;
}

//图文混排
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是""的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
    } else if (message != nil) {
        [array addObject:message];
    }
}

@end
