//
//  WriteSummaryVC.m
//  testAlertMenu
//
//  Created by yzq on 13-7-17.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "SummaryVC.h"
#import "NavigationBarWithBg.h"
#import "KxMenu.h"
#import "WorkDetailVC.h"
#import "FeelingsViewController.h"
#import "TodayWorkCell.h"
#import "PlanWorkDetailVC.h"
#import "TargetsCell.h"
#import "ASIFormDataRequest.h"
#import "NetWorkEngine.h"

@interface SummaryVC (){
    CGPoint touchPoint;
    UIView *feellingView;
    NavigationBarWithBg *navBar;
    AppDelegate *appDelegate;
    
    NSInteger changedCount;
    
    BOOL _isShowingActivity;
}

@end

#define TitleViewHeight 38.0
#define RowHeight       64.0

//表情的大小，跟文本框的宽度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 280
//表情截取符
#define BEGIN_FLAG @"["
#define END_FLAG @"]"

static NSString *addRoutineWork=@"添加常规工作";
static NSString *addCreativeWork=@"添加微创新工作";
static NSString *addTemporaryWork=@"添加临时工作";

@implementation SummaryVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_OA];
    [super viewDidAppear:YES];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MYOADETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OAUPDATERESULT object:nil];
    
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [super viewDidDisappear:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    changedCount=0; //改动次数
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //如果直接使用草稿，否则提问是否使用
    if (_useDraft && appDelegate.currentUser.oaDraft) {
        self.todayWorkArray=[appDelegate.currentUser.oaDraft objectForKey:@"todayWorkArray"];
        self.tomorrowTargetsArray=[appDelegate.currentUser.oaDraft objectForKey:@"tomorrowTargetsArray"];
        self.feelingString=[appDelegate.currentUser.oaDraft objectForKey:@"feelingString"];
        [_summaryTable reloadData];
    }else if (appDelegate.currentUser.oaDraft) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"使用草稿" message:@"使用之前保存的草稿吗？"
                                                 cancelButtonItem:[RIButtonItem itemWithLabel:@"删除" action:^{
            [appDelegate.currentUser setOaDraft:nil];
            [appDelegate saveToUserDefaultAtOnce:YES];
            [[BaiduMobStat defaultStat] logEvent:kStat_eDraftUsage eventLabel:@"删除草稿"];
        }]
                                                 otherButtonItems:[RIButtonItem itemWithLabel:@"使用" action:^{
            self.todayWorkArray=[appDelegate.currentUser.oaDraft objectForKey:@"todayWorkArray"];
            self.tomorrowTargetsArray=[appDelegate.currentUser.oaDraft objectForKey:@"tomorrowTargetsArray"];
            self.feelingString=[appDelegate.currentUser.oaDraft objectForKey:@"feelingString"];
            [_summaryTable reloadData];
            
            [[BaiduMobStat defaultStat] logEvent:kStat_eDraftUsage eventLabel:@"保存草稿"];
            
        }], nil];
        [alertView show];
        [alertView release];
    }

    //判断是否超过下午5点了
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSInteger dateValue = [[dateFormatter stringFromDate:date] integerValue];
    [dateFormatter release];
    if (dateValue-170000>0) {
        if ([appDelegate.currentUser.hadOaLog isEqualToString:@"还没提交"]) {   //还没编辑的要加载昨天的计划
            //    获取今日任务
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTargetsResult:) name:NOTIFY_TARGETSRESULT object:nil];
            [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:nil apiString:URL_USER_GET_TARGETS Method:@"GET" Tag:GetTargets];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMyOA:) name:NOTIFY_MYOADETAIL object:nil];
            [self getMyOA];
        }
    }
    
    [self.view setBackgroundColor:[UIColor grayColor]];

    //导航栏
    navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:@"写日总结" LeftBtnTitle:@"提交" RightBtnTitle:@"返回"];
    [navBar.leftBarButton addTarget:self action:@selector(submitSummary) forControlEvents:UIControlEventTouchUpInside];
    [navBar.rightBarButton addTarget:self action:@selector(viewPopBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    [navBar release];
    
    [self setupTableView];
    
    //点击
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:nil] autorelease];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    self.summaryTable=nil;
    self.todayWorkArray=nil;
    self.tomorrowTargetsArray=nil;
    self.feelingString=nil;
    [super dealloc];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        TargetsDataObj *targets=[self.todayWorkArray objectAtIndex:indexPath.row];
        
        WorkDetailVC *workDetailVc=[[WorkDetailVC alloc] initWithTargetsDataObj:targets objIndex:indexPath.row editTargetsBlock:^(NSInteger index, TargetsDataObj *targetObj,BOOL isDelete) {
            //根据回调进行删除，插入操作。 然后更新
            isDelete ? [self.todayWorkArray removeObjectAtIndex:index] : [self.todayWorkArray setObject:targetObj atIndexedSubscript:index];
            
            NSIndexSet *indexset=[NSIndexSet indexSetWithIndex:0];
            [_summaryTable reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
            ++changedCount;
        }];
        [self presentModalViewController:workDetailVc animated:YES];
    }
    else if(indexPath.section==1){
        TargetsDataObj *targets=[self.tomorrowTargetsArray objectAtIndex:indexPath.row];
        
        PlanWorkDetailVC *planDetailVc=[[PlanWorkDetailVC alloc] initWithTargetsDataObj:targets objIndex:indexPath.row editTargetsBlock:^(NSInteger index, TargetsDataObj *targetObj,BOOL isDelete) {
            //根据回调进行删除，插入操作。 然后更新
            isDelete ? [self.tomorrowTargetsArray removeObjectAtIndex:index] : [self.tomorrowTargetsArray setObject:targetObj atIndexedSubscript:index];
            NSIndexSet *indexset=[NSIndexSet indexSetWithIndex:1];
            [_summaryTable reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
            ++changedCount;
        }];
        [self presentModalViewController:planDetailVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height= RowHeight;
    if (indexPath.section==0) {
        TargetsDataObj *target=(TargetsDataObj *)[_todayWorkArray objectAtIndex:indexPath.row];
        height=TodayWorkCellHeight+ [self heightWithText:target.tarFinishState];
    }else if(indexPath.section==2){
        if (_feelingString) {
            feellingView=[self viewWithMessage:_feelingString];
            height=feellingView.frame.size.height+50;
        }
    }
    return height;
}
//根据文本返回高度
-(CGFloat) heightWithText:(NSString *)string{
    CGSize constraint = CGSizeMake(235, 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return size.height-20 > 0 ? size.height-20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *routineLabe=[[[UILabel alloc] initWithFrame:CGRectMake(0, navBarHeight, ScreenBoundsSize.width,TitleViewHeight)] autorelease];
    [routineLabe setBackgroundColor:[UIColor colorWithRed:195/255.0 green:222/255.0 blue:241/255.0 alpha:1.0]];
    UILabel *lineLable=[[UILabel alloc] initWithFrame:CGRectMake(0, 1, ScreenBoundsSize.width, 1)];
    [lineLable setBackgroundColor:[UIColor whiteColor]];
    [routineLabe addSubview:lineLable];
    [lineLable release];
    
    [routineLabe setFont:[UIFont systemFontOfSize:14.0]];
    
    UIButton *addBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
    [addBtn setFrame:CGRectMake(ScreenBoundsSize.width-29-6,(TitleViewHeight-29)/2, 29, 29)];
    //[addBtn setBounds:CGRectMake(48,(navBarHeight-10-29)/2, 29, 29)];
    
    switch (section) {
        case 0:
            routineLabe.text=@"  今日工作";
            break;
        case 1:
            routineLabe.text=@"  明天计划";
            break;
        case 2:
            routineLabe.text=@"  日感想";
            break;
        default:
            break;
    }
    
    addBtn.tag=section;
    [addBtn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [routineLabe addSubview:addBtn];
    routineLabe.userInteractionEnabled=YES;

    return routineLabe;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRow = 0;
    switch (section) {
        case 0:
            numberOfRow=_todayWorkArray.count;
            break;
        case 1:
            numberOfRow=_tomorrowTargetsArray.count;
            break;
        case 2:
            numberOfRow=1;
            break;
        default:
            break;
    }
    return numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //今日任务章节
    if (indexPath.section==0) {
        static NSString *cellIdentify=@"todayWorkCell";
        TodayWorkCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (TodayWorkCell *)[[[NSBundle mainBundle] loadNibNamed:@"TodayWorkCell" owner:self options:nil] lastObject];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }

        TargetsDataObj *obj=[_todayWorkArray objectAtIndex:indexPath.row];
        cell.tarContentLabel.text=obj.tarContent;
        cell.tarMayCostTimeLabel.text=obj.tarMayCostTime;
        cell.tarCostTimeLabel.text=obj.tarCostTime;
        cell.tarAffectUserLabel.text=obj.tarAffectUser;
        cell.tarCorperLabel.text=obj.tarCorper;
        cell.tarProgressLabel.text=obj.tarProgress;
        cell.tarFinishStateTextView.text=obj.tarFinishState;
        
        cell.tarTypeLabel.text=[obj workTypeName];
        
        return cell;
    }
    //明天计划章节
    if (indexPath.section==1) {
        //明天任务的，也定制一下
        static NSString *cellIdentify=@"tomorrowWorkCell";
        TargetsCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (TargetsCell *)[[[NSBundle mainBundle] loadNibNamed:@"TargetsCell" owner:self options:nil] lastObject];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        TargetsDataObj *obj=(TargetsDataObj *)[_tomorrowTargetsArray objectAtIndex:indexPath.row];
        cell.tarContentLabel.text=obj.tarContent;
        cell.tarMayCostTimeLabel.text=obj.tarMayCostTime;
        cell.tarCorperLabel.text=obj.tarCorper;
        return cell;
    }
    //日感想章节
    if (indexPath.section==2) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"feelingViewCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feelingViewCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
        if (_feelingString) {
            for (UIView *view in cell.subviews) {
                [view removeFromSuperview];
            }
            feellingView=[self viewWithMessage:_feelingString];
            [cell addSubview:feellingView];
        }
        return cell;
    }
    return nil;
}

#pragma mark --点击事件--
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    touchPoint=[touch locationInView:self.view];
    return NO;          //这里只是为了获取点击的坐标
}

#pragma mark --my function--
//提交按钮
-(void) submitSummary{
    NSMutableArray *jsonArray=[NSMutableArray arrayWithCapacity:0];
    if (_todayWorkArray) {
        for (int i=0; i<_todayWorkArray.count; i++) {
            TargetsDataObj *obj=(TargetsDataObj *)[_todayWorkArray objectAtIndex:i];
            [jsonArray addObject:[obj jsonDictionary]];
        }
    }
    if (_tomorrowTargetsArray) {
        for (int i=0; i<_tomorrowTargetsArray.count; i++) {
            TargetsDataObj *obj=(TargetsDataObj *)[_tomorrowTargetsArray objectAtIndex:i];
            [jsonArray addObject:[obj jsonDictionary]];
        }
    }

    if (jsonArray.count!=0 && _feelingString) {
        //_mark 禁止多次提交
        [navBar.leftBarButton setEnabled:NO];
        [navBar.rightBarButton setEnabled:NO];
        
        //Log(@"要提交的日志是:%@",[NSString jsonStringWithArray:jsonArray]);
        //Log(@"要提交的感想是%@",_feelingString);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAupdateResult:) name:NOTIFY_OAUPDATERESULT object:nil];
        
        NSString *fullUrlString = [URL_BASE stringByAppendingString:URL_USER_POST_OAUPDATE];
        NSURL *url=[NSURL URLWithString:fullUrlString];
        if (!_isShowingActivity) {
            [self.view makeToastActivity];
            _isShowingActivity =YES;
        }
        
        ASIFormDataRequest *requestItem = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
        [requestItem setPostValue:[NSString jsonStringWithArray:jsonArray] forKey:@"Targets"];
        [requestItem setPostValue:_feelingString forKey:@"LogFeeling"];
        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES request:requestItem method:@"POST" tag:PostOAupdate];
    }else{
        [self.view makeToast:@"日总结跟感想不能为空."];
    }

    //起始结束时间
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    [[BaiduMobStat defaultStat] logEvent:kStat_eOADate eventLabel:dateString];
}


-(void) handleOAupdateResult:(NSNotification *)notify{
    [navBar.leftBarButton setEnabled:YES];
    [navBar.rightBarButton setEnabled:YES];
    
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OAUPDATERESULT object:nil];
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OaUpdateResult];
    NSDictionary *oaUpdateDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        oaUpdateDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    //NSDictionary *oaUpdateDictionary=[[notify userInfo] objectForKey:KEY_MY_Dic_OaUpdateResult];

    [self.view makeToast:[oaUpdateDictionary objectForKey:KEY_MSG]];
    
    

    NSString *statusString=[NSString stringWithFormat:@"%@",[oaUpdateDictionary objectForKey:KEY_STATE]];
    //NSLog(@"状态是%@",oaUpdateDictionary);
    if ([statusString isEqualToString:@"0"]) {
        self.todayWorkArray=nil;
        self.tomorrowTargetsArray=nil;
        self.feelingString=nil;
        
        [appDelegate.currentUser setHadOaLog:@"已经填写"];  //更新日志状态
        [appDelegate.currentUser setOaDraft:nil];
        [appDelegate saveToUserDefaultAtOnce:YES];
        [self performSelector:@selector(viewPopBack) withObject:nil afterDelay:.5];
    }
}

-(void) viewPopBack{
    //如果有数据在的话
    BOOL saveDraft=_todayWorkArray!=nil || _tomorrowTargetsArray!=nil || _feelingString!=nil;
    saveDraft=saveDraft && changedCount!=0;
    
    if (saveDraft) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"保存草稿" message:@"保存到草稿箱吗？"
                                                 cancelButtonItem:[RIButtonItem itemWithLabel:@"不保存" action:^{
            [appDelegate.currentUser setOaDraft:nil];
            [appDelegate saveToUserDefaultAtOnce:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }]
                                                 otherButtonItems:[RIButtonItem itemWithLabel:@"保存" action:^{
            NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:_todayWorkArray forKey:@"todayWorkArray"];
            [dic setValue:_tomorrowTargetsArray forKey:@"tomorrowTargetsArray"];
            [dic setValue:_feelingString forKey:@"feelingString"];
            //Log(@"保存的草稿是 :%@",dic);
            [appDelegate.currentUser setOaDraft:dic];
            [appDelegate saveToUserDefaultAtOnce:YES];
            
            //[[BaiduMobStat defaultStat] logEvent:@"oaDraftUser" eventLabel:@"用户保存草稿"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }], nil];
        [alertView show];
        [alertView release];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_OA];
}

-(void) showMenu:(UIButton *) sender{
    NSArray *menuItems =nil;
    if (sender.tag==0) {
        menuItems =
        @[
        [KxMenuItem menuItem:addRoutineWork
                       image:nil
                      target:self
                      action:@selector(pushTodayMenuItem:)],
        [KxMenuItem menuItem:addCreativeWork
                       image:nil
                      target:self
                      action:@selector(pushTodayMenuItem:)],
        [KxMenuItem menuItem:addTemporaryWork
                       image:nil
                      target:self
                      action:@selector(pushTodayMenuItem:)]
        ];
    }
    else if(sender.tag==1){
        menuItems =
        @[
        [KxMenuItem menuItem:addRoutineWork
                       image:nil
                      target:self
                      action:@selector(pushTomorrowMenuItem:)],
        [KxMenuItem menuItem:addCreativeWork
                       image:nil
                      target:self
                      action:@selector(pushTomorrowMenuItem:)]
        ];
    }else{
        //写感想
        FeelingsViewController *feelingVC=[[FeelingsViewController alloc] initWithBlock:^(NSString *feellingContent) {
            self.feelingString=feellingContent;
            NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:2];
            [_summaryTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            //改动次数
            ++changedCount;
        }];
        feelingVC.textViewContent=_feelingString;
        
        [self presentModalViewController:feelingVC animated:YES];
        [feelingVC release];
        return;
    }
    //点击的点，作微调
    CGRect buttonRect=CGRectMake(touchPoint.x-sender.frame.size.width/2-4, touchPoint.y-sender.frame.size.height/2-navBarHeight-2, sender.frame.size.width, sender.frame.size.height);
    [KxMenu showMenuInView:self.summaryTable
                  fromRect:buttonRect
                 menuItems:menuItems];
}

#pragma mark --添加/编辑今天工作--
-(void) pushTodayMenuItem:(KxMenuItem *)selectedItem{
    NSInteger type=0;
    if ([selectedItem.title isEqualToString:addRoutineWork]) {
        type=1;
    }else if([selectedItem.title isEqualToString:addCreativeWork]){
        type=2;
    }else if([selectedItem.title isEqualToString:addTemporaryWork]){
        type=3;
    }
    WorkDetailVC *workDetailVC=[[WorkDetailVC alloc] initWithTarType:type addTargetsBlock:^(TargetsDataObj *targets) {
        if (_todayWorkArray) {
            [self.todayWorkArray addObject:targets];
            //[_summaryTable reloadRowsAtIndexPaths:nil withRowAnimation:UITableViewRowAnimationAutomatic];
            //_summaryTable insertRowsAtIndexPaths:nil withRowAnimation:nil
        }else{
            self.todayWorkArray=[NSMutableArray arrayWithObject:targets];
        }
        [_summaryTable reloadData];
        ++changedCount;
        //插入新行，刷新表格
    }];
    workDetailVC.title=selectedItem.title;
    
    [self presentViewController:workDetailVC animated:YES completion:nil];
    //[self presentModalViewController:workDetailVC animated:YES];
}
-(void) pushTomorrowMenuItem:(KxMenuItem *)selectedItem{
    NSInteger type=0;
    if ([selectedItem.title isEqualToString:addRoutineWork]) {
        type=4;
    }else if([selectedItem.title isEqualToString:addCreativeWork]){
        type=5;
    }
    PlanWorkDetailVC *workDetailVC=[[PlanWorkDetailVC alloc] initWithTarType:type addTargetsBlock:^(TargetsDataObj *targets) {
        if (_tomorrowTargetsArray) {
            [self.tomorrowTargetsArray addObject:targets];
            //[_summaryTable reloadRowsAtIndexPaths:nil withRowAnimation:UITableViewRowAnimationAutomatic];
            //_summaryTable insertRowsAtIndexPaths:nil withRowAnimation:nil
        }else{
            self.tomorrowTargetsArray=[NSMutableArray arrayWithObject:targets];
        }
        [_summaryTable reloadData]; //_mark reload这里优化一下
        ++changedCount;
        //插入新行，刷新表格
    }];
    workDetailVC.title=selectedItem.title;
    [self presentModalViewController:workDetailVC animated:YES];
}

-(void) setupTableView{
    self.summaryTable=[[UITableView alloc] initWithFrame:CGRectMake(0, navBarHeight, ScreenBoundsSize.width, ScreenBoundsSize.height-navBarHeight-20) style:UITableViewStylePlain];
    _summaryTable.delegate=self;
    _summaryTable.dataSource=self;
    [_summaryTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_summaryTable setSectionHeaderHeight:TitleViewHeight];
//    [_summaryTable setRowHeight:RowHeight];
    [self.view addSubview:_summaryTable];
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
                //NSLog(@"str(image)---->%@",str);
                NSString *imageName=[str substringWithRange:NSMakeRange(1, str.length - 2)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                //NSLog(@"imageName:%@",imageName);
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
    returnView.frame = CGRectMake(12.0f,12.0f,X, Y+18); //@ 需要将该view的尺寸记下，方便以后复用
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

#pragma makr --NetWork
-(void) getMyOA{
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
    }
    
    //用户名
//    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSString *userName=appDelegate.currentUser.userNo;
    NSDictionary *userNameDic=[NetWorkEngine synthesisCookiePropertiesWithValue:userName name:KEY_UserNameOrNo];
    //起始结束时间
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];

    [dateFormatter release];
    NSDictionary *dateDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_START];
    NSDictionary *dateEndDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_END];
    
    NSMutableArray *inforArray=[NSMutableArray arrayWithObjects:userNameDic,dateDic,dateEndDic,nil];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_OADETAILLIST Method:@"GET" Tag:GetMyOADetail];
}

//处理OA列表
-(void) handleMyOA:(NSNotification *)notify{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
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
    
        NSArray *OaDataArray=(NSArray *)[OADetailDictionary objectForKey:KEY_DATA];
        if (OaDataArray && [OaDataArray isKindOfClass:[NSArray class]] && OaDataArray.count) {
            NSDictionary *oaLogDic=[OaDataArray objectAtIndex:0];
            LogDataOjb *log=[LogDataOjb logWithDictionary:oaLogDic];
            NSLog(@"%@",oaLogDic);
            //五点后要追加上去
            if (self.todayWorkArray) {
                [self.todayWorkArray addObjectsFromArray:log.todayTargetsArray];
            }else{
                self.todayWorkArray=log.todayTargetsArray;
            }
            self.tomorrowTargetsArray=log.tomorrowTargetsArray;
            self.feelingString=log.feeling;
            [_summaryTable reloadData];
        }else{
            [self.view makeToast:@"没有数据"];
        }
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
}

//处理今日任务结果
-(void) handleTargetsResult:(NSNotification *)notify{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TARGETSRESULT object:nil];
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_TargetsResult];
    NSDictionary *targetsResultDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        targetsResultDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[targetsResultDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
        NSArray *dataArray=[targetsResultDictionary objectForKey:KEY_DATA];
        NSMutableArray *tmpArray=[[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary *targetsDictionary=(NSDictionary *)[dataArray objectAtIndex:i];
            TargetsDataObj *target=[TargetsDataObj targetsWithDictionary:targetsDictionary];
            NSLog(@"%@",targetsDictionary);
//            target.tarID=nil;
//            target.logID=nil;
            target.tarType=@"1";
            [tmpArray addObject:target];
        }
        [self setTodayWorkArray:tmpArray];
        [tmpArray release];
        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:0];
        [_summaryTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[targetsResultDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }

}


@end



