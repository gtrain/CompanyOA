//
//  OrderStatisticsVC.m
//  OA_TGNET
//
//  Created by yzq on 13-7-18.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "OrderStatisticsVC.h"
#import "NavigationBarWithBg.h"
#import "KxMenu.h"
#import "AppDelegate.h"
#import "NetWorkEngine.h"

#define SectionHeaderHeight 32
#define TableViewCellHeight 42

@implementation OrderStatus
+(OrderStatus *) orderStatusWithDictionary:(NSDictionary *)dataDictionary{
    return [[[self alloc] initWithDictionary:dataDictionary] autorelease];
}
-(id) initWithDictionary:(NSDictionary *)dataDictionary{
    self=[super init];
    if (self) {
        self.userName=[dataDictionary objectForKey:KEY_userName];
        self.Lunch=[self tranlate:[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_Lunch]]];
        self.Supper=[self tranlate:[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_Supper]]];
        self.OrderTime=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_OrderTime]];
    }
    return self;
}

-(NSString *) tranlate:(NSString *)value{
    NSString *str=nil;
    if ([value isEqualToString:@""]) {
        str=@"未报餐";
    }else if([value isEqualToString:@"True"]) {
        str=@"已报餐";
    }else if([value isEqualToString:@"False"]) {
        str=@"不报餐";
    }
    return str;
}

-(void) dealloc{
    self.userName=nil;
    self.Lunch=nil;
    self.Supper=nil;
    self.OrderTime=nil;
    [super dealloc];
}

@end


@interface OrderStatisticsVC ()

@end

#define DepartmentBtnHeight 36
#define LabelPartHeight     50

@implementation OrderStatisticsVC
-(void) dealloc{
    [_departMentBtn release];
    [_lunchStaLabel release];
    [_supperStaLabel release];
    self.departMentBtn=nil;
    [super dealloc];
}

-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ORDERLIST object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Stat_Order];
    [super viewDidDisappear:YES];
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self requestDataWithDepID:nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Stat_Order];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTargetsStatusResult:) name:NOTIFY_ORDERLIST object:nil];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    [self setupUI];
    [self setupTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置选择按钮跟报餐人数显示
-(void) setupUI{
    //导航栏
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:@"报餐统计" LeftBtnTitle:nil RightBtnTitle:@"返回"];
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
    
    self.lunchStaLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, navBarHeight+DepartmentBtnHeight, ScreenBoundsSize.width,LabelPartHeight/2)];
    //_lunchStaLabel.text=@" 午餐（共XXX人）";
    [_lunchStaLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:_lunchStaLabel];
    
    self.supperStaLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, navBarHeight+DepartmentBtnHeight+LabelPartHeight/2, ScreenBoundsSize.width,LabelPartHeight/2)];
    //_supperStaLabel.text=@" 晚餐（共XXX人）";
    [_supperStaLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:_supperStaLabel];
}
-(void) setupTable{
    self.orderResultArray=nil;     //初始化数据源
    self.orderResultTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, navBarHeight+DepartmentBtnHeight+LabelPartHeight, ScreenBoundsSize.width, ScreenBoundsSize.height-navBarHeight-DepartmentBtnHeight-LabelPartHeight-20)];

    _orderResultTableView.delegate=self;
    _orderResultTableView.dataSource=self;
    [_orderResultTableView setSectionHeaderHeight:SectionHeaderHeight];
    
    [_orderResultTableView setSeparatorColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];

    _orderResultTableView.alpha=.0;
    [self.view addSubview:_orderResultTableView];
}

#pragma mark --my function--
//请求数据
-(void) requestDataWithDepID:(NSString *)depID{
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
    }
    NSArray *inforArray=nil;
    if(depID){
        NSDictionary *depIdDic=[NetWorkEngine synthesisCookiePropertiesWithValue:depID name:KEY_DEPID];
        inforArray=[NSArray arrayWithObject:depIdDic];
    }
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES parameterDicArray:inforArray apiString:URL_USER_GET_ORDERLIST Method:@"GET" Tag:GetOrderList];
    
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

//处理订餐结果
-(void) handleTargetsStatusResult:(NSNotification *)notify{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_OrderList];
    NSDictionary *orderListDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        orderListDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    NSString *state=[NSString stringWithFormat:@"%@",[orderListDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
    
        NSDictionary *orderDataDictionary=[orderListDictionary objectForKey:KEY_DATA];
        NSInteger noOrderLunch=[[orderDataDictionary objectForKey:KEY_UserCount] integerValue]-[[orderDataDictionary objectForKey:KEY_LunchCount] integerValue];
        NSInteger noOrderSuper=[[orderDataDictionary objectForKey:KEY_UserCount] integerValue]-[[orderDataDictionary objectForKey:KEY_SupperCount] integerValue];
        _lunchStaLabel.text=[NSString stringWithFormat:@"午餐（共%@人,订餐%@人,未订餐%d）",[orderDataDictionary objectForKey:KEY_UserCount],[orderDataDictionary objectForKey:KEY_LunchCount],noOrderLunch];
        _supperStaLabel.text=[NSString stringWithFormat:@"晚餐（共%@人,订餐%@人,未订餐%d）",[orderDataDictionary objectForKey:KEY_UserCount],[orderDataDictionary objectForKey:KEY_SupperCount],noOrderSuper];
        
        //详细信息处理
        NSArray *orderDetailsArray=[orderDataDictionary objectForKey:KEY_ORDERDETAILS];
        if (orderDetailsArray) {
            NSMutableArray *tmpArray=[NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<orderDetailsArray.count; i++) {
                NSDictionary *statusDictionary=(NSDictionary *)[orderDetailsArray objectAtIndex:i];
                OrderStatus *oStatus=[OrderStatus orderStatusWithDictionary:statusDictionary];
                [tmpArray addObject:oStatus];
            }
            [self setOrderResultArray:tmpArray];
        }
        _orderResultTableView.alpha=1.0;
        [_orderResultTableView reloadData];
    
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@",[orderListDictionary objectForKey:KEY_MSG]];
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
    
    UILabel *lunchLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3+1, 1, (ScreenBoundsSize.width-2)/3, SectionHeaderHeight-2)];
    lunchLabel.text=@"午餐";
    [lunchLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:lunchLabel];
    [lunchLabel release];
    
    UILabel *supperLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+2, 1, (ScreenBoundsSize.width-2)/3, SectionHeaderHeight-2)];
    supperLabel.text=@"晚餐";
    [supperLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:supperLabel];
    [supperLabel release];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _orderResultArray?_orderResultArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"orderResultCell"];
    UILabel *nameLabel=nil;
    UILabel *lineLabel=nil;
    UILabel *lunchLabel=nil;
    UILabel *lineLabel2=nil;
    UILabel *supperLabel=nil;
    
    if (!cell) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"orderResultCell"] autorelease];
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
        
        lunchLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3+1, 0, (ScreenBoundsSize.width-2)/3, TableViewCellHeight)];
        lunchLabel.tag=102;
        [lunchLabel setTextAlignment:NSTextAlignmentCenter];
        [lunchLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:lunchLabel];
        [lunchLabel release];
        
        lineLabel2=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+1, 0, 1, TableViewCellHeight)];
        [lineLabel2 setBackgroundColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        [cell.contentView addSubview:lineLabel2];
        [lineLabel2 release];
        
        supperLabel=[[UILabel alloc] initWithFrame:CGRectMake((ScreenBoundsSize.width-2)/3*2+2, 0, (ScreenBoundsSize.width-2)/3, TableViewCellHeight)];
        supperLabel.tag=103;
        [supperLabel setTextAlignment:NSTextAlignmentCenter];
        [supperLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:supperLabel];
        [supperLabel release];
    }
    //设置单行背景
    cell.contentView.backgroundColor= indexPath.row%2 ? nil : [UIColor colorWithRed:170/255.0 green:191/255.0 blue:229/255.0 alpha:1.0];
    [cell setSelectionStyle:UITableViewCellEditingStyleInsert];

    if (!nameLabel) nameLabel=(UILabel *)[cell viewWithTag:101];
    if (!lunchLabel) lunchLabel=(UILabel *)[cell viewWithTag:102];
    if (!supperLabel) supperLabel=(UILabel *)[cell viewWithTag:103];
    
    OrderStatus *status=[self.orderResultArray objectAtIndex:indexPath.row];
    nameLabel.text=status.userName;
    lunchLabel.text=status.Lunch;
    supperLabel.text=status.Supper;
    
    return cell;
}

@end











