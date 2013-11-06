//
//  TodaySsummaryViewController.m
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "TodaySsummaryViewController.h"
#import "OAStatisticsVC.h"
#import "OaDetialViewController.h"
#import "NetWorkEngine.H"
#import "LogDataOjb.h"
#import "OaDetailCell.h"
#import "TargetsDataObj.h"

//表情的大小，跟文本框的宽度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18

//表情截取符
#define BEGIN_FLAG @"["
#define END_FLAG @"]"//表情的大小，跟文本框的宽度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 226
//表情截取符
#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@interface TodaySsummaryViewController ()

@end

@implementation TodaySsummaryViewController

- (void)viewDidUnload {
//    [self setDatePicker:nil];
    [self setDateBtn:nil];
    [self setDepartMentBtn:nil];
    [self setRefreshImgView:nil];
    [super viewDidUnload];
}

-(void) dealloc{
    [alphaBgView release];
    
    [oaDatePicker release];
    //[_datePicker release];
    [_dateBtn release];
    [_departMentBtn release];
    [_oaDetailArray release];
    [_oaDetailListTable release];
    [_refreshImgView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OADETAILLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OADETAILLISTMORE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_UserAvatar object:nil];
    
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [_refreshImgView.layer removeAnimationForKey:@"animation"];
        _isShowingActivity =NO;
    }
    // 下拉刷新复位
    _isReloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.oaDetailListTable];
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Sum];
    [super viewDidDisappear:YES];
}
-(void) viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneLoadingMoreTableViewData:) name:NOTIFY_OADETAILLISTMORE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAListResult:) name:NOTIFY_OADETAILLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAvatar:) name:NOTIFY_UserAvatar object:nil];
    //按钮复位
    _departMentBtn.enabled=YES;
    _dateBtn.enabled=YES;
    _isReloading=NO;
    _isLoadMore=NO;
    
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Sum];
    [super viewDidAppear:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    //发起默认请求,五点前请求昨天的数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //NSDate *curDate=[NSDate date];
    NSTimeInterval  interval =17*60*60;
    NSDate *requestDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-interval];   //每天17点前取前一天，17点后取今天
    NSString *requestDateString = [dateFormatter stringFromDate:requestDate];
    [self getOADetailListWithPage:nil DepID:nil OAdate:requestDateString];
    
    //日期
    //NSDate *date=[NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:requestDate];
    [requestDate release];
    [dateFormatter release];
//    Log(@"日期串是 %@",dateString);
    [_dateBtn setTitle:dateString forState:UIControlStateNormal];
    
    
//    if (!_isShowingActivity) {
//        [self.view makeToastActivity];
//        [_refreshImgView.layer addAnimation:animation forKey:@"animation"];
//        _isShowingActivity =YES;
//    }

    [self setupTable];
    self.tabBarController.delegate=self;
    
    _departMentBtn.tag=0;       //默认全部部门
    loadPage=1;                 //默认第一页
    
    animation =[[CABasicAnimation alloc] init];
    [animation setKeyPath:@"transform"];
    animation.delegate = self;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI , 0, 0, 1.0)];
    animation.duration = 1.3;
    animation.cumulative = YES;
    animation.repeatCount = INT_MAX;
    
    
    oaDatePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 216)];
    [oaDatePicker setDatePickerMode:UIDatePickerModeDate];
    [[[UIApplication sharedApplication] keyWindow] addSubview:oaDatePicker];
    [oaDatePicker release];
    [oaDatePicker addTarget:self action:@selector(OADateChanged) forControlEvents:UIControlEventValueChanged];
    
    //  时间选择器
    alphaBgView=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [alphaBgView setBackgroundColor:[UIColor blackColor]];
    [alphaBgView setAlpha:.0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//统计按钮
- (IBAction)OAStatistics:(id)sender {
    if(_dateBtn.selected){
        return;
    }
    OAStatisticsVC *statistics=[[OAStatisticsVC alloc] init];
    [statistics setDateString:_dateBtn.currentTitle];
    [self.navigationController pushViewController:statistics animated:YES];
    [statistics release];
    
    [[BaiduMobStat defaultStat] logEvent:kStat_eStatList eventLabel:@"OA统计"];
}
//刷新按钮
- (IBAction)refreshBtnPress:(UIButton *)sender {
    //如果在选择日期按钮，则触发点击事件，因为这个函数包含网络连接事件； 否则自己触发事件
    //点击 刷新的请求
    if (_isReloading || _isLoadMore) return;
    _dateBtn.selected?[self dateBtnPress:_dateBtn]:[self getOADetailListWithPage:nil DepID:_departMentBtn.tag OAdate:_dateBtn.currentTitle];
    //下拉状态
    _isReloading=YES;
    
    
//    if (!_isShowingActivity) {
//        [self.view makeToastActivity];
//        [_refreshImgView.layer addAnimation:animation forKey:@"animation"];
//        _isShowingActivity =YES;
//    }
    
}
//部门菜单
- (IBAction)departmentMenu:(UIButton *)sender {
    NSArray *menuItems =@[
                          [KxMenuItem menuItem:departmentAll
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)],
                          [KxMenuItem menuItem:departmentYF
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)],
                          [KxMenuItem menuItem:departmentSC
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)],
                          [KxMenuItem menuItem:departmentXX
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)],
                          [KxMenuItem menuItem:departmentXZ
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)],
                          [KxMenuItem menuItem:departmentCW
                                         image:nil
                                        target:self
                                        action:@selector(changeBtnName:)]
                          ];
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

#pragma mark //点击日期按钮
- (IBAction)dateBtnPress:(UIButton *)sender {
    _oaDetailListTable.scrollEnabled=!_oaDetailListTable.scrollEnabled;
    _departMentBtn.enabled=!_departMentBtn.enabled;
    _dateBtn.selected=!_dateBtn.selected;
    
    [self.view addSubview:alphaBgView];
    [UIView animateWithDuration:.2 animations:^(void){
        oaDatePicker.frame = CGRectMake(0, ScreenBoundsSize.height-216, ScreenBoundsSize.width, 216);
        alphaBgView.alpha = 0.6;
    }completion:nil];
    

    //UIToolbar *doneToolbar=(UIToolbar *)[self.view viewWithTag:99];

    if (_dateBtn.selected) {
        [self.view addSubview:alphaBgView];
        [UIView animateWithDuration:.2 animations:^(void){
            oaDatePicker.frame = CGRectMake(0, ScreenBoundsSize.height-216, ScreenBoundsSize.width, 216);
            alphaBgView.alpha = 0.6;
        }completion:nil];
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        [UIView beginAnimations:nil context:context];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.2];//动画时间长度，单位秒，浮点数
//        self.datePicker.frame = CGRectMake(0, ScreenBoundsSize.height-284, ScreenBoundsSize.width, 260);
//        doneToolbar.frame = CGRectMake(0, ScreenBoundsSize.height-322, ScreenBoundsSize.width, 38);
//        [UIView commitAnimations];
    }else{
        [UIView animateWithDuration:.2 animations:^(void){
            oaDatePicker.frame = CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 216);
            alphaBgView.alpha = .0;
        }completion:^(BOOL finished) {
            [alphaBgView removeFromSuperview];
            //发起请求
            [self getOADetailListWithPage:nil DepID:_departMentBtn.tag OAdate:_dateBtn.currentTitle];
            
            
            
        }];
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        [UIView beginAnimations:nil context:context];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.2];//动画时间长度，单位秒，浮点数
//        self.datePicker.frame = CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 260);
//        doneToolbar.frame = CGRectMake(0, ScreenBoundsSize.height, ScreenBoundsSize.width, 38);
//        [UIView commitAnimations];
//点击 日期的请求
        
    }
}
//点击退下日期选择
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _dateBtn.selected?[self dateBtnPress:_dateBtn]:nil;
}

-(void)OADateChanged{
    NSDate *date = [oaDatePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateValue = [dateFormatter stringFromDate:date];
    [_dateBtn setTitle:dateValue forState:UIControlStateNormal];
    [dateFormatter release];
}

#pragma mark -- my function --

//选择部门.改变按钮，改变数据源
-(void) changeBtnName:(KxMenuItem *)sender{
    // 设置tag 为部门id数值。刷新的时候可以使用
    if ([sender.title isEqualToString:departmentYF]) {
        _departMentBtn.tag=1;
    }else if([sender.title isEqualToString:departmentSC]){
        _departMentBtn.tag=2;
    }else if([sender.title isEqualToString:departmentXZ]){
        _departMentBtn.tag=4;
    }else if([sender.title isEqualToString:departmentCW]){
        _departMentBtn.tag=5;
    }else if([sender.title isEqualToString:departmentXX]){
        _departMentBtn.tag=6;
    }else{
        _departMentBtn.tag=0;   //默认为0  全部
    }
    [_departMentBtn setTitle:sender.title forState:UIControlStateNormal];
//  点击部门的请求
    [self getOADetailListWithPage:nil DepID:_departMentBtn.tag OAdate:_dateBtn.currentTitle];
}
#pragma mark -- 获取oa列表 --
-(void) getOADetailListWithPage:(NSInteger)page DepID:(NSInteger)depID OAdate:(NSString *)dateString{
    //_mark 如果为nil 则设置一下默认值 count是现在table的行数
    
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        [_refreshImgView.layer addAnimation:animation forKey:@"animation"];
        _isShowingActivity =YES;
    }
    
    _dateBtn.enabled=NO;
    
    //请求OA的详细列表
    NSMutableArray *inforArray=nil;
    if (depID) {
        NSDictionary *depIdDic=[NetWorkEngine synthesisCookiePropertiesWithValue:[NSString stringWithFormat:@"%d",depID] name:KEY_DEPID];
        if ([depIdDic objectForKey:NSHTTPCookieValue]) {
            inforArray=[NSMutableArray arrayWithObject:depIdDic];
        }
    }
    if (dateString) {
        NSDictionary *dateDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_START];
        if ([dateDic objectForKey:NSHTTPCookieValue]) {
            if (inforArray) {
                [inforArray addObject:dateDic];
            }else{
                inforArray=[NSMutableArray arrayWithObject:dateDic];
            }
//#warning 这里设置oa结果的结束日期，测试结束去掉注释
            NSDictionary *dateEndDic=[NetWorkEngine synthesisCookiePropertiesWithValue:dateString name:KEY_END];    //起始跟结束是同一天.
            [inforArray addObject:dateEndDic];
        }
    }

    if (page) {     //含page的请求是 “加载更多” 区分对待
        NSString *pageString=[NSString stringWithFormat:@"%d",page];
        NSDictionary *pageDic=[NetWorkEngine synthesisCookiePropertiesWithValue:pageString name:KEY_PAGE];
        if ([pageDic objectForKey:NSHTTPCookieValue]) {
            if (inforArray) {
                [inforArray addObject:pageDic];
            }else{
                inforArray=[NSMutableArray arrayWithObject:pageDic];
            }
        }
        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_OADETAILLIST Method:@"GET" Tag:GetMoreOADetailList];
        return;
    }else{
        loadPage=1; //刷新的时候页码重置
        [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_OADETAILLIST Method:@"GET" Tag:GetOADetailList];
    }
}

//下拉加载完成
- (void)doneLoadingMoreTableViewData:(NSNotification *)notify{
    
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [_refreshImgView.layer removeAnimationForKey:@"animation"];
        _isShowingActivity =NO;
    }
    
    _dateBtn.enabled=YES;
    _isLoadMore = NO;
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OADetailList];
    NSDictionary *OADetailDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        OADetailDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        --loadPage;
        _allLoaded=NO;
        [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        --loadPage;
        _allLoaded=NO;
        [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        [self.view makeToast:@"没有数据"];  
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
    
        NSArray *OaArray=[OADetailDictionary objectForKey:KEY_DATA];
        //这里对加载更多按钮进行状态调整
        if (!OaArray || OaArray.count == 0) {
            --loadPage;      //没有数据的话，页数也要复位
            _allLoaded=YES;
            [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
            return;
        }else{
            _allLoaded=NO;
            [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        }
        NSMutableArray *tmpDicArray=[NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<OaArray.count; i++) {
            NSDictionary *oaLogDic=[OaArray objectAtIndex:i];
            NSString *logKeyString=[NSString stringWithFormat:@"%@",[oaLogDic objectForKey:KEY_logID]];
            // 过滤同样的oa出现
            for (LogDataOjb *log in self.oaDetailArray) {
                if ([logKeyString isEqualToString:log.logID]) {
                    break;
                }
            }
            LogDataOjb *log=[LogDataOjb logWithDictionary:oaLogDic];
            [tmpDicArray addObject:log];
        }
        [self.oaDetailArray addObjectsFromArray:tmpDicArray]; //下拉刷新的时候才用到
        [self.oaDetailListTable reloadData];
        [self getUserAvatar];
    
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
}



//处理OA列表
-(void) handleOAListResult:(NSNotification *)notify{
    _dateBtn.enabled=YES;
    
    // 下拉刷新复位
    _isReloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.oaDetailListTable];
    
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [_refreshImgView.layer removeAnimationForKey:@"animation"];
        _isShowingActivity =NO;
    }
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OADetailList];
    NSDictionary *OADetailDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        OADetailDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        // 加载更多复位
        _allLoaded=NO;
        [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        // 加载更多复位
        _allLoaded=NO;
        [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {

        NSArray *OaArray=[OADetailDictionary objectForKey:KEY_DATA];
        //这里对加载更多按钮进行状态调整
        if (!OaArray || OaArray.count == 0) {
            [self.view makeToast:@"没有数据"];
            _allLoaded=YES;
            return;
        }else{
            _allLoaded=NO;
        }
        
        if (_loadMoreFooterView == nil) {
            PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
            view.delegate = self;
            _loadMoreFooterView = view;
            self.oaDetailListTable.tableFooterView = _loadMoreFooterView;
            [_loadMoreFooterView release];
        }
        // 加载更多复位
        [_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
        
        NSMutableArray *tmpDicArray=[NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<OaArray.count; i++) {
            NSDictionary *oaLogDic=[OaArray objectAtIndex:i];
            LogDataOjb *log=[LogDataOjb logWithDictionary:oaLogDic];
            [tmpDicArray addObject:log];
        }
        self.oaDetailArray=tmpDicArray;      //刷新的时候是重置这个数组呀～
        [_oaDetailListTable reloadData];
        [_oaDetailListTable setContentOffset:CGPointZero animated:YES];
        [self getUserAvatar];   //获取文本信息后加载头像
    
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[OADetailDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
    
}

#pragma mark --//获取头像--
-(void) getUserAvatar{
    if (!_oaDetailArray || _oaDetailArray.count==0) {
        return;
    }

    _departMentBtn.enabled=NO;
    _dateBtn.enabled=NO;
    _isReloading=YES;
    _isLoadMore=YES;
    int noAvatarCount=0;
    
    for (int i=0; i<_oaDetailArray.count; i++) {
        //url index tag
        LogDataOjb *logObj=[_oaDetailArray objectAtIndex:i];
        //有头像链接，而且头像信息为空的的才需要请求
        if (logObj.userFaceString && !logObj.userFaceIMG) {
            [[NetWorkEngine shareNetWorkEngine] addRequestWithUrlString:logObj.userFaceString Method:@"GET" Tag:GetUserAvatar Index:i];
        }else{
            ++noAvatarCount;
        }
    }
    
    //如果全部人都没有头像信息的话，把按钮复位      
    if (noAvatarCount==_oaDetailArray.count) {
        _departMentBtn.enabled=YES;
        _dateBtn.enabled=YES;
        _isReloading=NO;
        _isLoadMore=NO;
    }

}
-(void) handleUserAvatar:(NSNotification *)notify{
    _departMentBtn.enabled=YES;
    _dateBtn.enabled=YES;
    _isReloading=NO;
    _isLoadMore=NO;
    
    id requestResult=[[notify userInfo] objectForKey:KEY_DATA];
    NSData *userAvatarData=nil;
    if([requestResult isKindOfClass:[NSData class]]){
        userAvatarData=requestResult;
        NSNumber *indexNum=[notify.userInfo objectForKey:@"index"];
        if (userAvatarData && indexNum) {
            if (indexNum.intValue>_oaDetailArray.count-1) {
                return;
            }
            LogDataOjb *obj=[_oaDetailArray objectAtIndex:indexNum.intValue];
            UIImage *userAvatar=[UIImage imageWithData:userAvatarData];
            [obj setUserFaceIMG:userAvatar];
            
            NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:indexNum.intValue inSection:0];
            NSArray     *arr        = [NSArray arrayWithObject:indexPath];
            [_oaDetailListTable reloadRowsAtIndexPaths:arr withRowAnimation:NO];
        }
    }
    else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
    }
}

//表格的cell点评按钮事件
- (void)replyBtnPress:(UIButton *)sender {
    NSInteger objIndex=[[sender titleForState:UIControlEventTouchCancel] integerValue];
    if (objIndex>_oaDetailArray.count-1) {
        return;
    }
    LogDataOjb *selectLog=[_oaDetailArray objectAtIndex:objIndex];
    OaDetialViewController *oaDetialVC=[[OaDetialViewController alloc] initWithLogObj:selectLog];
    [oaDetialVC setScrolToReplyList:YES];
    [self.navigationController pushViewController:oaDetialVC animated:YES];
    [oaDetialVC release];
}

//表格设置
-(void)setupTable{
    self.oaDetailArray=[NSMutableArray arrayWithCapacity:0];
    self.oaDetailListTable=[[[UITableView alloc] initWithFrame:CGRectMake(0, 44+36, ScreenBoundsSize.width, ScreenBoundsSize.height-44-36-20-48)] autorelease];
    //44 header  36 部门按钮  20状态栏 48 tarbar
    _oaDetailListTable.delegate=self;
    _oaDetailListTable.dataSource=self;
    [_oaDetailListTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //加入上拉跟下拉
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.oaDetailListTable.bounds.size.height, self.view.frame.size.width, self.oaDetailListTable.bounds.size.height)];
        view.delegate = self;
        [self.oaDetailListTable addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self.view addSubview:_oaDetailListTable];
    //[self.view insertSubview:_oaDetailListTable belowSubview:_datePicker];  //表格插入到 picker 后面
    [_oaDetailListTable release];
}

//根据文本返回高度
-(CGFloat) heightWithText:(NSString *)string{
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN+ RightPartX), 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(size.height, CELL_CONTENT_MINIHEIGHT)+CELL_CONTENT_MARGIN;
}

#pragma mark --UITableViewDelegate,UITableViewDataSource--
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row>_oaDetailArray.count-1) {
        return;
    }
    LogDataOjb *selectLog=[_oaDetailArray objectAtIndex:indexPath.row];
    OaDetialViewController *oaDetialVC=[[OaDetialViewController alloc] initWithLogObj:selectLog];
    [self.navigationController pushViewController:oaDetialVC animated:YES];
    [oaDetialVC release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.oaDetailArray || self.oaDetailArray.count==0) {
        //Log(@"没有日志记录");
        return 0;
    }
    LogDataOjb *logObj=[self.oaDetailArray objectAtIndex:indexPath.row];
    NSString *todayWork=@"";
    for (TargetsDataObj *target in logObj.todayTargetsArray) {
//        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",[dic objectForKey:KEY_tarContent],[dic objectForKey:KEY_tarProgress]];
        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",target.tarContent,target.tarProgress];
        todayWork= [todayWork isEqualToString:@""] ? itemString: [todayWork stringByAppendingString:[NSString stringWithFormat:@"\n%@",itemString]];
    }

    NSString *tomorrowPlan=@"";
    for (TargetsDataObj *target in logObj.tomorrowTargetsArray) {
//        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",[dic objectForKey:KEY_tarContent],[dic objectForKey:KEY_tarProgress]];
        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",target.tarContent,target.tarProgress];  
        tomorrowPlan= [tomorrowPlan isEqualToString:@""] ? itemString: [tomorrowPlan stringByAppendingString:[NSString stringWithFormat:@"\n%@",itemString]];
    }
    CGFloat height=[self heightWithText:todayWork]+[self heightWithText:tomorrowPlan]+[self heightWithText:logObj.feeling]+RightHeaderHeight*3;
    return MAX(height, OaCellHeight)+10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _oaDetailArray ?_oaDetailArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentify=@"OaDetailCell";
    OaDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    UILabel *twLabel=nil;
    UILabel *todayWorkLabel = nil;
    
    UILabel *tmLabel=nil;
    UILabel *tomorrowLabel=nil;
    
    UILabel *flLabel=nil;
    //UILabel *feelingLabel=nil;
    UIView *feelingView=nil;
    
    if (!cell) {
        //cell = (OaDetailCell *)[[[NSBundle mainBundle] loadNibNamed:@"OaDetailCell" owner:self options:nil] lastObject];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OaDetailCell" owner:self options:nil] lastObject];
        //今日工作标题
        twLabel=[[UILabel alloc] initWithFrame:CGRectMake(RightPartX, 10, 234, RightHeaderHeight)];
        [twLabel setBackgroundColor:[UIColor colorWithRed:72/255.0 green:136/255.0 blue:203/255.0 alpha:1.0]];
        twLabel.tag=201;
        [twLabel setTextColor:[UIColor whiteColor]];
        [twLabel setFont:[UIFont systemFontOfSize:12.0]];
        [cell addSubview:twLabel];
        [twLabel release];
        //今日工作内容
        todayWorkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [todayWorkLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //[todayWorkLabel setMinimumScaleFactor:FONT_SIZE];
        [todayWorkLabel setNumberOfLines:0];
        [todayWorkLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [todayWorkLabel setTag:202];
        [[cell contentView] addSubview:todayWorkLabel];
        [todayWorkLabel release];
        
        //明天计划标题
        tmLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        [tmLabel setBackgroundColor:[UIColor colorWithRed:72/255.0 green:136/255.0 blue:203/255.0 alpha:1.0]];
        tmLabel.tag=211;
        [tmLabel setTextColor:[UIColor whiteColor]];
        [tmLabel setFont:[UIFont systemFontOfSize:12.0]];
        [cell addSubview:tmLabel];
        [tmLabel release];
        
        tomorrowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [tomorrowLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //[tomorrowLabel setMinimumScaleFactor:FONT_SIZE];
        [tomorrowLabel setNumberOfLines:0];
        [tomorrowLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [tomorrowLabel setTag:212];
        [[cell contentView] addSubview:tomorrowLabel];
        [tomorrowLabel release];
        
        //今日感想
        flLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        [flLabel setBackgroundColor:[UIColor colorWithRed:72/255.0 green:136/255.0 blue:203/255.0 alpha:1.0]];
        flLabel.tag=221;
        [flLabel setTextColor:[UIColor whiteColor]];
        [flLabel setFont:[UIFont systemFontOfSize:12.0]];
        [cell addSubview:flLabel];
        [flLabel release];

//        feelingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [feelingLabel setLineBreakMode:NSLineBreakByWordWrapping];
//        [feelingLabel setMinimumScaleFactor:FONT_SIZE];
//        [feelingLabel setNumberOfLines:0];
//        [feelingLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//        [feelingLabel setTag:222];
//        [[cell contentView] addSubview:feelingLabel];
//        [feelingLabel release];
        [cell.replyBtn addTarget:self action:@selector(replyBtnPress:) forControlEvents:UIControlEventTouchUpInside];   //点击事件
    }
    [cell.replyBtn setTitle:[NSString stringWithFormat:@"%d",indexPath.row] forState:UIControlEventTouchCancel];    //标记行号.
    //左侧
    LogDataOjb *logObj=self.oaDetailArray.count==0 ? nil : [self.oaDetailArray objectAtIndex:indexPath.row];
    cell.userNameLabel.text=logObj.userName;
    cell.userDepartmentLabel.text=logObj.depName;
    cell.replyCountLabel.text=[NSString stringWithFormat:@"已有%d人",logObj.replyArray? logObj.replyArray.count : 0];
    
    if (logObj.userFaceIMG) {
        [cell.userAvatarImgView setImage:logObj.userFaceIMG];
    }else{
        [cell.userAvatarImgView setImage:[UIImage imageNamed:@"login_avatar_default"]];
    }
    
    //右侧
    CGFloat yCoord=0.0;
    
    //今日工作
    if(!twLabel) twLabel=(UILabel *)[cell viewWithTag:201];
    twLabel.text=@"  今日工作";
    yCoord=twLabel.frame.origin.y + twLabel.frame.size.height;
    
    NSString *todayWork=@"";
    for (TargetsDataObj *target in logObj.todayTargetsArray) {
        //        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",[dic objectForKey:KEY_tarContent],[dic objectForKey:KEY_tarProgress]];
        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",target.tarContent,target.tarProgress];
        todayWork= [todayWork isEqualToString:@""] ? itemString: [todayWork stringByAppendingString:[NSString stringWithFormat:@"\n%@",itemString]];
    }
    if(!todayWorkLabel) todayWorkLabel=(UILabel *)[cell viewWithTag:202];
    [todayWorkLabel setText:todayWork];
    [todayWorkLabel setFrame:CGRectMake(RightPartX, yCoord, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN*2 + RightPartX), [self heightWithText:todayWork])];
    
    //明天计划
    yCoord=todayWorkLabel.frame.origin.y + todayWorkLabel.frame.size.height;
    if(!tmLabel) tmLabel=(UILabel *)[cell viewWithTag:211];
    [tmLabel setFrame:CGRectMake(RightPartX, yCoord, 234, RightHeaderHeight)];
    tmLabel.text=@"  明天计划";
    yCoord=tmLabel.frame.origin.y + tmLabel.frame.size.height;
    
    NSString *tomorrowPlan=@"";
    for (TargetsDataObj *target in logObj.tomorrowTargetsArray) {
        //        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",[dic objectForKey:KEY_tarContent],[dic objectForKey:KEY_tarProgress]];
        NSString *itemString=[NSString stringWithFormat:@"%@ (完成进度:%@ %%)",target.tarContent,target.tarProgress];
        tomorrowPlan= [tomorrowPlan isEqualToString:@""] ? itemString: [tomorrowPlan stringByAppendingString:[NSString stringWithFormat:@"\n%@",itemString]];
    }
    if(!tomorrowLabel) tomorrowLabel=(UILabel *)[cell viewWithTag:212];
    [tomorrowLabel setText:tomorrowPlan];
    [tomorrowLabel setFrame:CGRectMake(RightPartX, yCoord, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN*2 + RightPartX), [self heightWithText:tomorrowPlan])];
    
    //今日感想
    yCoord=tomorrowLabel.frame.origin.y + tomorrowLabel.frame.size.height;
    if(!flLabel) flLabel=(UILabel *)[cell viewWithTag:221];
    [flLabel setFrame:CGRectMake(RightPartX, yCoord, 234, RightHeaderHeight)];
    flLabel.text=@"  今日感想";
    yCoord=flLabel.frame.origin.y + flLabel.frame.size.height + CELL_CONTENT_MARGIN/2;
    
//    if(!feelingLabel) feelingLabel=(UILabel *)[cell viewWithTag:222];
//    [feelingLabel setText:logObj.feeling];
//    [feelingLabel setFrame:CGRectMake(RightPartX+CELL_CONTENT_MARGIN, yCoord, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN*2 + RightPartX), [self heightWithText:logObj.feeling]-10)];
    
    if (logObj.feeling) {
        UIView *tmpView=[cell viewWithTag:123];
        if (tmpView) {
            [tmpView removeFromSuperview];
        }
        feelingView=[self viewWithMessage:logObj.feeling];
        feelingView.tag=123;
        
        CGRect flViewFrame=feelingView.frame;
        flViewFrame.origin.x=RightPartX;
        flViewFrame.origin.y=yCoord;
        feelingView.frame=flViewFrame;
        
        [cell addSubview:feelingView];
    }
    
    return cell;
}

#pragma mark --UITabBarControllerDelegate--
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //tab跳转的时候 如果dateBtn选中的话  把 _dateBtn 复位
    if(_dateBtn.selected){
        _dateBtn.selected=NO;
    }
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


#pragma mark -- 以下是上拉下拉的实现 --

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -- 下拉 刷新 EGORefreshTableHeaderDelegate Methods --
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self refreshBtnPress:nil];
    
    [[BaiduMobStat defaultStat] logEvent:kStat_eDropUp eventLabel:@"下拉刷新"];
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _isReloading; // should return if data source model is reloading
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark -- 加载更多刷新 PWLoadMoreTableFooterDelegate Methods
- (void)pwLoadMore {
    //加载更多的时候禁止刷新
    //刷新的时候禁止加载更多 根据reloading判断，还是锁定UI ？
    if (_isReloading) {
        return;
    }
    
    _isLoadMore = YES;
    ++loadPage;
    [self getOADetailListWithPage:loadPage DepID:_departMentBtn.tag OAdate:_dateBtn.currentTitle];
    
    [[BaiduMobStat defaultStat] logEvent:kStat_eDropDown eventLabel:@"点击加载更多"];
}
- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _isLoadMore;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}



#pragma mark --

-(void)reloadTableViewDataSource
{
    //可以删除
//    NSLog(@"==开始加载数据,发起请求");
//    [self.oaDetailListTable reloadData];
//    _reloading = YES;
}


@end















