//
//  OAStatisticsVC.m
//  OA_TGNET
//
//  Created by yzq on 13-7-22.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "OAStatisticsVC.h"
#import "NavigationBarWithBg.h"
#import "KxMenu.h"
#import "AppDelegate.h"
#import "NetWorkEngine.h"

@implementation OAStatus
-(void) dealloc{
    self.logPubDate=nil;
    self.logState=nil;
    self.userName=nil;
    [super dealloc];
}
+(OAStatus *) OAStatusWithDictionary:(NSDictionary *)dataDictionary{
    return [[[self alloc] initWithDictionary:dataDictionary] autorelease];
}
-(id) initWithDictionary:(NSDictionary *)dataDictionary{
    self=[super init];
    if (self) {
        self.userName=[dataDictionary objectForKey:KEY_userName];
        self.logState= [[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_LogState]] isEqualToString:@"0"] ?
                        @"已填写" : @"未填写";
        
        NSString *dateString=[dataDictionary objectForKey:KEY_LogPubDate];
        if (dateString) {
            NSRange tarRange = [dateString rangeOfString:@" "];
            if (tarRange.length !=0) {
                dateString=[dateString substringFromIndex:tarRange.location+1];
            }
        }
        self.logPubDate=[NSString stringWithFormat:@"%@",dateString];
    }
    return self;
}

@end

#define SectionHeaderHeight 32
#define DepartmentBtnHeight 36
#define LabelPartHeight     25
#define TableViewCellHeight 42

@implementation OAStatisticsVC
-(void) dealloc{
    self.dateString=nil;
    self.departMentBtn=nil;
    self.OASurveyLabel=nil;
    self.OAStatisticsTableView=nil;
    self.OAStatisticsArray=nil;
    [super dealloc];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_OASTATUSLIST object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Stat_OA];
    [super viewDidDisappear:YES];
}
//-(void) viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:YES];
//
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self requestDataWithDepID:nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Stat_OA];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAStatusList:) name:NOTIFY_OASTATUSLIST object:nil];
    
    [self setupUI];
    [self setupTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- my function --
//设置选择按钮跟报餐人数显示
-(void) setupUI{
    //导航栏
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:@"日总结统计" LeftBtnTitle:nil RightBtnTitle:@"返回"];
    [navBar.rightBarButton addTarget:self action:@selector(viewPopBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    [navBar release];
    
    //选择按钮
    self.departMentBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, navBarHeight, ScreenBoundsSize.width, DepartmentBtnHeight)];
    [_departMentBtn addTarget:self action:@selector(showDepartment:) forControlEvents:UIControlEventTouchUpInside];
    [_departMentBtn setBackgroundColor:[UIColor colorWithRed:250/255.0 green:251/255.0 blue:229/255.0 alpha:1.0]];
    [_departMentBtn setTitle:@"全部部门" forState:UIControlStateNormal];
    [_departMentBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [_departMentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_departMentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [_departMentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 140, 0, 0)];
    [_departMentBtn setImage:[UIImage imageNamed:@"login_textfield_more"] forState:UIControlStateNormal];
    [_departMentBtn setImage:[UIImage imageNamed:@"login_textfield_more_flip"] forState:UIControlStateSelected];
    [self.view addSubview:_departMentBtn];
    [_departMentBtn release];
    
    self.OASurveyLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, navBarHeight+DepartmentBtnHeight, ScreenBoundsSize.width,LabelPartHeight)];
    [_OASurveyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:_OASurveyLabel];
    //_OASurveyLabel.text=@"共___人，已填写__人，未填写__人";
}
-(void) setupTable{
    self.OAStatisticsArray=nil;
    self.OAStatisticsTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, navBarHeight+DepartmentBtnHeight+LabelPartHeight, ScreenBoundsSize.width, ScreenBoundsSize.height-navBarHeight-DepartmentBtnHeight-LabelPartHeight-20)];
    
    _OAStatisticsTableView.delegate=self;
    _OAStatisticsTableView.dataSource=self;
    [_OAStatisticsTableView setSectionHeaderHeight:SectionHeaderHeight];
    
    [_OAStatisticsTableView setSeparatorColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    
    _OAStatisticsTableView.alpha=.0;
    [self.view addSubview:_OAStatisticsTableView];
}

//返回
-(void) viewPopBack{
    [self.navigationController popViewControllerAnimated:YES];
}

//下拉菜单
-(void) showDepartment:(UIButton *)sender{
    //sender.selected=!sender.selected;
    NSArray *menuItems =@[
    [KxMenuItem menuItem:departmentAll
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)],
    [KxMenuItem menuItem:departmentYF
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)],
    [KxMenuItem menuItem:departmentSC
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)],
    [KxMenuItem menuItem:departmentXX
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)],
    [KxMenuItem menuItem:departmentXZ
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)],
    [KxMenuItem menuItem:departmentCW
                   image:nil
                  target:self
                  action:@selector(changeDepartment:)]
    ];
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

//选择部门.改变按钮，改变数据源
-(void) changeDepartment:(KxMenuItem *)sender{
    NSString *depID=nil;
    if ([sender.title isEqualToString:departmentYF]) {
        depID=@"1";
    }else if([sender.title isEqualToString:departmentSC]){
        depID=@"2";
    }else if([sender.title isEqualToString:departmentXZ]){
        depID=@"4";
    }else if([sender.title isEqualToString:departmentCW]){
        depID=@"5";
    }else if([sender.title isEqualToString:departmentXX]){
        depID=@"6";
    }else{
        depID=@"0";   //默认为0  全部
    }
    [_departMentBtn setTitle:sender.title forState:UIControlStateNormal];
    [self requestDataWithDepID:depID];
}

//请求数据
-(void) requestDataWithDepID:(NSString *)depID{
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
    }
    NSMutableArray *inforArray=nil;
    if (depID) {
        NSDictionary *inforDic=[NetWorkEngine synthesisCookiePropertiesWithValue:depID name:KEY_DEPID];
        if (!inforArray) {
            inforArray=[NSMutableArray arrayWithCapacity:0];
        }
        [inforArray addObject:inforDic];
    }
    if (_dateString) {
        NSDictionary *depIdDic=[NetWorkEngine synthesisCookiePropertiesWithValue:_dateString name:KEY_DATE];
        if (!inforArray) {
            inforArray=[NSMutableArray arrayWithCapacity:0];
        }
        [inforArray addObject:depIdDic];
    }
    
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_OASTATUSLIST Method:@"GET" Tag:GetOAStatusList];    
}

//处理OA填写结果
-(void) handleOAStatusList:(NSNotification *)notify{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OAStatusList];
    NSDictionary *OAListDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        OAListDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[OAListDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
        
        //NSDictionary *OAListDictionary=[[notify userInfo] objectForKey:KEY_MY_Dic_OAStatusList];
        //这个data,返回的json不一定有
        NSDictionary *OADataDictionary=[OAListDictionary objectForKey:KEY_DATA];
        if (!OADataDictionary) {
            [self.view makeToast:@"没有数据"];
            return;
        }
        NSInteger noWriteOa=[[OADataDictionary objectForKey:KEY_UserCount] integerValue] - [[OADataDictionary objectForKey:KEY_WriteCount] integerValue];
        _OASurveyLabel.text=[NSString stringWithFormat:@"共%@人，已填写%@人，未填写%d人",[OADataDictionary objectForKey:KEY_UserCount],[OADataDictionary objectForKey:KEY_WriteCount],noWriteOa];
        
        //详细信息处理
        NSArray *OADetailsArray=[OADataDictionary objectForKey:KEY_LogDetails];
        if (OADetailsArray) {
            NSMutableArray *tmpArrar=[NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<OADetailsArray.count; i++) {
                NSDictionary *statusDictionary=(NSDictionary *)[OADetailsArray objectAtIndex:i];
                OAStatus *oaStatus=[OAStatus OAStatusWithDictionary:statusDictionary];
                [tmpArrar addObject:oaStatus];
            }
            [self setOAStatisticsArray:tmpArrar];
        }
        _OAStatisticsTableView.alpha=1.0;
        [_OAStatisticsTableView reloadData];
        
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[OAListDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
}

#pragma mark --UITableViewDelegate,UITableViewDataSource--
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, SectionHeaderHeight)] autorelease];
    
    UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 1, (ScreenBoundsSize.width-2)/3, SectionHeaderHeight-2)];
    nameLabel.text=@"姓名";
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:nameLabel];
    [nameLabel release];
    
    UILabel *statusLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3+1, 1, (ScreenBoundsSize.width-2)/3, SectionHeaderHeight-2)];
    statusLabel.text=@"填写情况";
    [statusLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:statusLabel];
    [statusLabel release];
    
    UILabel *timeLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+2, 1, (ScreenBoundsSize.width-2)/3, SectionHeaderHeight-2)];
    timeLabel.text=@"填写时间";
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:timeLabel];
    [timeLabel release];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    return headerView;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _OAStatisticsArray ? _OAStatisticsArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OAStatiCell"];
    UILabel *nameLabel=nil;
    UILabel *lineLabel=nil;
    UILabel *statusLabel=nil;
    UILabel *lineLabel2=nil;
    UILabel *timeLabel=nil;
    
    if (!cell) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OAStatiCell"] autorelease];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, (ScreenBoundsSize.width-2)/3, TableViewCellHeight)];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        nameLabel.tag=101;
        [cell.contentView addSubview:nameLabel];
        [nameLabel release];
        
        lineLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3, 0, 1, TableViewCellHeight)];
        [lineLabel setBackgroundColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        [cell.contentView addSubview:lineLabel];
        [lineLabel release];
        
        statusLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3+1, 0, (ScreenBoundsSize.width-2)/3, TableViewCellHeight)];
        statusLabel.tag=102;
        [statusLabel setTextAlignment:NSTextAlignmentCenter];
        [statusLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:statusLabel];
        [statusLabel release];
        
        lineLabel2=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+1, 0, 1, TableViewCellHeight)];
        [lineLabel2 setBackgroundColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        [cell.contentView addSubview:lineLabel2];
        [lineLabel2 release];
        
        timeLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+2, 0, (ScreenBoundsSize.width-2)/3, TableViewCellHeight)];
        timeLabel.tag=103;
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
    }
    //设置单行背景
    cell.contentView.backgroundColor= indexPath.row%2 ? nil : [UIColor colorWithRed:170/255.0 green:191/255.0 blue:229/255.0 alpha:1.0];
    [cell setSelectionStyle:UITableViewCellEditingStyleInsert];
    
    if (!nameLabel) nameLabel=(UILabel *)[cell viewWithTag:101];
    if (!statusLabel) statusLabel=(UILabel *)[cell viewWithTag:102];
    if (!timeLabel) timeLabel=(UILabel *)[cell viewWithTag:103];
    
    OAStatus *status=[self.OAStatisticsArray objectAtIndex:indexPath.row];
    nameLabel.text=status.userName;
    statusLabel.text=status.logState;
    timeLabel.text=status.logPubDate;
    
    return cell;
}


@end
