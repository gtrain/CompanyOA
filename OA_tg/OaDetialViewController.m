//
//  OaDetialViewController.m
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-30.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "OaDetialViewController.h"
#import "NavigationBarWithBg.h"
#import "LogDataOjb.h"
#import "TargetsDataObj.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
@interface OaDetialViewController (){
    UITextView *textView;
    UIButton *submitBtn;
    UIView *feelingView;
}

@end

@implementation OaDetialViewController

#define HeaderViewHeight 32.0f


//表情的大小，跟文本框的宽度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH         280
//表情截取符
#define BEGIN_FLAG  @"["
#define END_FLAG    @"]"


#define OaCellHeight        206
#define RightPartX          78
#define RightHeaderHeight   22

#define FONT_SIZE           14.0f
#define CELL_CONTENT_WIDTH  320.0f
#define CELL_CONTENT_MARGIN 8.0f
#define CELL_CONTENT_MINIHEIGHT 44.0f

-(void) dealloc{
    self.oaDetailTable=nil;
    self.logObj=nil;
    [super dealloc];
}
-(void) viewDidAppear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Reply];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_REPLYRESULT object:nil];
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Reply];
    [super viewDidDisappear:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(id) initWithLogObj:(LogDataOjb *)logData{
    self=[super init];
    if (self) {
        self.logObj=logData;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupTable];
    [self setupNav];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    if (_scrolToReplyList) {
        [self scrollToReplyList];
//        [self performSelector:@selector(scrollToReplyList) withObject:nil afterDelay:.45];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --UITableViewDelegate,UITableViewDataSource--
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;   //6个章节
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows=0;
    switch (section) {
        case 0:     //oa个人信息
            numberOfRows=1;
            break;
        case 1:     //今日任务
            numberOfRows= self.logObj.todayTargetsArray ? self.logObj.todayTargetsArray.count : 0;
            //numberOfRows=2;
            break;
        case 2:     //明日常规
            numberOfRows=self.logObj.tomorrowTargetsArray ? self.logObj.tomorrowTargetsArray.count : 0;
            break;
        case 3:     //今日感想
            numberOfRows=1;
            break;
        case 4:     //点评列表
            numberOfRows=self.logObj.replyArray ? self.logObj.replyArray.count : 0;
            break;
        case 5:     //点评
            numberOfRows=1;
            break;
        default:
            break;
    }
    return numberOfRows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0.0f;
    }else if(section==5){
        return 22.0f;
    }else{
        return HeaderViewHeight;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat heightForRow=.0f;
    //今日任务
    if (indexPath.section==1) {
        TargetsDataObj *target=(TargetsDataObj *)[_logObj.todayTargetsArray objectAtIndex:indexPath.row];
        heightForRow=TodayWorkCellHeight+[self heightWithTextNoPadding:target.tarFinishState];
        return heightForRow;
    }
    //点评列表的cell
    if (indexPath.section==4) {
        NSDictionary *replyDic=[self.logObj.replyArray objectAtIndex:indexPath.row];
        NSString *replyContent=[NSString stringWithFormat:@"%@\n%@",[replyDic objectForKey:@"replyContent"],[replyDic objectForKey:@"replyPubDate"]];
        return [self heightWithText:replyContent];
    }
    
    switch (indexPath.section) {
        case 0:     //oa个人信息
            heightForRow=68;
            break;
        case 2:     //明日常规
            heightForRow=52;
            break;
        case 3:     //今日感想
            if (self.logObj.feeling) {
                feelingView=[self viewWithMessage:self.logObj.feeling];
                heightForRow=feelingView.frame.size.height+50;
            }else{
                heightForRow=68;
            }
            break;
        case 5:     //点评textView
            heightForRow=140;
            break;
        default:
            break;
    }
    
    return heightForRow;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {     //第一个个人的不需要，最后一个点评也不需要
        return nil;
    }
//    else if(section==5){
//        UILabel *replyLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, 22)];
//        [replyLabel setBackgroundColor:[UIColor grayColor]];
//        [replyLabel setFont:[UIFont systemFontOfSize:13]];
//        replyLabel.text=@"发表回复";
//        return replyLabel;
//    }
    UILabel *headerLabel=nil;
    headerLabel =[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, HeaderViewHeight)] autorelease];
    [headerLabel setBackgroundColor:[UIColor colorWithRed:72/255.0 green:136/255.0 blue:203/255.0 alpha:1.0]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont systemFontOfSize:13.0]];
    
    switch (section) {
        case 1:
            headerLabel.text=@"  今日工作";
            break;
        case 2:
            headerLabel.text=@"  明日计划";
            break;
        case 3:
            headerLabel.text=@"  今日感想";
            break;
        case 4:
            headerLabel.text=@"  点评列表";
            break;
        case 5:
            headerLabel.text=@"  发表回复";
            break;
        default:
            break;
    }
    return headerLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (indexPath.section==0) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"personalCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"personalCell"] autorelease];
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(ScreenBoundsSize.width-60-10, 4, 60, 60)];
            if (self.logObj.userFaceIMG) {
                [imgView setImage:self.logObj.userFaceIMG];
            }else{
                [imgView setImage:[UIImage imageNamed:@"login_avatar_default.png"]];
            }
            [cell.contentView addSubview:imgView];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
        cell.textLabel.text=self.logObj.userName;
        cell.detailTextLabel.text=self.logObj.depName;
        return cell;
    }
    //今日任务
    else if(indexPath.section==1) {
        static NSString *cellIdentify=@"todayWorkCell";
        TodayWorkCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (TodayWorkCell *)[[[NSBundle mainBundle] loadNibNamed:@"TodayWorkCell" owner:self options:nil] lastObject];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
        TargetsDataObj *tdObj=[self.logObj.todayTargetsArray objectAtIndex:indexPath.row];
        cell.tarContentLabel.text=tdObj.tarContent;
        cell.tarMayCostTimeLabel.text=tdObj.tarMayCostTime;
        cell.tarCostTimeLabel.text=tdObj.tarCostTime;
        cell.tarAffectUserLabel.text=tdObj.tarAffectUser;
        cell.tarCorperLabel.text=tdObj.tarCorper;
        cell.tarProgressLabel.text=tdObj.tarProgress;
        cell.tarFinishStateTextView.text=tdObj.tarFinishState;
        cell.tarTypeLabel.text=[tdObj workTypeName];
        return cell;
    }
    //明天计划
    else if(indexPath.section==2) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"tmWorkCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tmWorkCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
        }
        TargetsDataObj *tmObj=[self.logObj.tomorrowTargetsArray objectAtIndex:indexPath.row];
        cell.textLabel.text=tmObj.tarContent;
        cell.detailTextLabel.text=[NSString stringWithFormat:@"预计%@小时",tmObj.tarMayCostTime];
        return cell;
    }
    //今日感想
    else if(indexPath.section==3) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"feelingCell"];
//        UILabel *feelingLabel=nil;
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feelingCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
//            feelingLabel=[[UILabel alloc] initWithFrame:CGRectZero];
//            feelingLabel.tag=301;
//            [feelingLabel setBackgroundColor:[UIColor grayColor]];
//            [cell.contentView addSubview:feelingLabel];
        }
        
        if (self.logObj.feeling) {
            for (UIView *view in cell.subviews) {
                [view removeFromSuperview];
            }
            feelingView=[self viewWithMessage:self.logObj.feeling];
            [cell addSubview:feelingView];
        }
//        if (!feelingLabel) {
//            feelingLabel=(UILabel *)[cell viewWithTag:301];
//        }
//        [feelingLabel setText:self.logObj.feeling];
//        feelingLabel.frame=CGRectMake(0, 0, ScreenBoundsSize.width, 68);
        return cell;
    }
    //点评列表
    else if(indexPath.section==4) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"replyListCell"];
        UILabel *nameLabel=nil;
        UILabel *replyLabel=nil;
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replyListCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 68, 44)];
            nameLabel.tag=311;
            [cell.contentView addSubview:nameLabel];
            [nameLabel release];
            
//            replyLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width+10, 0, ScreenBoundsSize.width-nameLabel.frame.size.width-10*2, 64)];
//            replyLabel.tag=312;
//            [cell.contentView addSubview:replyLabel];
//            [todayWorkLabel setNumberOfLines:0];
//            [replyLabel release];
            
            replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [replyLabel setLineBreakMode:NSLineBreakByWordWrapping];
//            [replyLabel setMinimumScaleFactor:FONT_SIZE];
            [replyLabel setNumberOfLines:0];
            [replyLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
            [replyLabel setTag:312];
            [[cell contentView] addSubview:replyLabel];
            [replyLabel release];
        }
        if (!nameLabel) nameLabel=(UILabel *)[cell viewWithTag:311];
        if (!replyLabel)replyLabel=(UILabel *)[cell viewWithTag:312];
        
        NSDictionary *replyDic=[self.logObj.replyArray objectAtIndex:indexPath.row];
        nameLabel.text=[NSString stringWithFormat:@"  %@",[replyDic objectForKey:@"replyPubUser"]];
        
        NSString *replyContent=[NSString stringWithFormat:@"%@\n%@",[replyDic objectForKey:@"replyContent"],[replyDic objectForKey:@"replyPubDate"]];
        if(!replyLabel) replyLabel=(UILabel *)[cell viewWithTag:312];
        [replyLabel setText:replyContent];
        [replyLabel setFrame:CGRectMake(RightPartX+CELL_CONTENT_MARGIN, 0, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN*2 + RightPartX), [self heightWithText:replyContent])];
        return cell;
        
    }else if(indexPath.section==5) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"replyCell"];
        if (!cell) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replyCell"] autorelease];
        
            UIKeyboardView *keyboardToolbar = [[UIKeyboardView alloc] initWithDoneKeyAndFrame:CGRectMake(0, 0, ScreenBoundsSize.width, 38)];
            [keyboardToolbar setDelegate:self];
            
            textView=[[UITextView alloc] initWithFrame:CGRectMake(0, 1, ScreenBoundsSize.width, 92)];
            textView.inputAccessoryView=keyboardToolbar;
            [textView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
            [keyboardToolbar release];
            [textView setFont:[UIFont systemFontOfSize:18]];
            textView.delegate=self;
            [cell.contentView addSubview:textView];
            [textView release];
            
            submitBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [submitBtn setFrame:CGRectMake(0, textView.frame.size.height+6, ScreenBoundsSize.width, 42)];
            [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
            [submitBtn addTarget:self action:@selector(submitReply) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:submitBtn];

        }
        return cell;
    }
    return cell;
}

//根据文本返回高度
-(CGFloat) heightWithText:(NSString *)string{
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN*2 + RightPartX), 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(size.height, CELL_CONTENT_MINIHEIGHT)+CELL_CONTENT_MARGIN;
}

-(CGFloat) heightWithTextNoPadding:(NSString *)string{
    CGSize constraint = CGSizeMake(235, 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return size.height-20 > 0 ? size.height : 0;
}
#pragma makr --UIKeyboardViewDelegate UITextViewDelegate--
//显示与隐藏键盘
- (void)toolbarButtonTap:(UIButton *)button{
    [textView resignFirstResponder];
    CGRect curFrame=self.oaDetailTable.frame;
    curFrame.origin.y += 254.0;
    [UIView animateWithDuration:.3f animations:^{
        self.oaDetailTable.frame=curFrame;
    }];
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect curFrame=self.oaDetailTable.frame;
    curFrame.origin.y -= 254.0;
    [UIView animateWithDuration:.3f animations:^{
        self.oaDetailTable.frame=curFrame;
    }];
}

#pragma mark --my function--
-(void) setupNav{
    //导航栏
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:@"日总结详情" LeftBtnTitle:@"点评" RightBtnTitle:@"返回"];
    [navBar.rightBarButton addTarget:self action:@selector(viewPopBack) forControlEvents:UIControlEventTouchUpInside];
    [navBar.leftBarButton addTarget:self action:@selector(replyBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    [navBar release];
}
//表格设置
-(void)setupTable{
    self.oaDetailTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 44, ScreenBoundsSize.width, ScreenBoundsSize.height-44-20)];  //44 header  36 部门按钮  20状态栏
    _oaDetailTable.delegate=self;
    _oaDetailTable.dataSource=self;
    [_oaDetailTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self.view addSubview:_oaDetailTable];
    [_oaDetailTable release];
}

-(void) viewPopBack{
    [self.navigationController popViewControllerAnimated:YES];
}

//滚动到点评列表
-(void) scrollToReplyList{
    if (_logObj.replyArray && _logObj.replyArray.count !=0) {
        NSIndexPath *listIndex=[NSIndexPath indexPathForRow:0 inSection:4];
        [_oaDetailTable scrollToRowAtIndexPath:listIndex atScrollPosition:UITableViewScrollPositionTop animated:!_scrolToReplyList];
    }else{
        [self replyBtnPress];
    }
}
//滚动到底部
-(void) replyBtnPress{
//    NSIndexPath *bottomIndex=[NSIndexPath indexPathForItem:0 inSection:_oaDetailTable.numberOfSections-1];
    NSIndexPath *bottomIndex=[NSIndexPath indexPathForRow:0 inSection:_oaDetailTable.numberOfSections-1];
    [_oaDetailTable scrollToRowAtIndexPath:bottomIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) submitReply{
    // _mark 点击之后加上旋转或者 disable
    if ([textView.text isEqualToString:@""]) return;
    
    //退下键盘,防止用户点击按钮活编辑
    if ([textView isFirstResponder]) {
        [self toolbarButtonTap:nil];
    }
    
    textView.editable=NO;
    submitBtn.enabled=NO;
    //注册通知中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReplyResult:) name:NOTIFY_REPLYRESULT object:nil];
    
    long long logid=self.logObj.logID.integerValue;
    NSNumber *logIDNum=[NSNumber numberWithLongLong:logid];

    NSString *fullUrlString = [URL_BASE stringByAppendingString:URL_USER_POST_OAREPLY];
    NSURL *url=[NSURL URLWithString:fullUrlString];
    
    ASIFormDataRequest *requestItem = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    [requestItem setPostValue:logIDNum forKey:KEY_logID];
    [requestItem setPostValue:textView.text forKey:KEY_content];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:YES request:requestItem method:@"POST" tag:PostReply];

    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
    }
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[BaiduMobStat defaultStat] logEvent:kStat_eReply eventLabel:appDelegate.currentUser.userName];
}

-(void) handleReplyResult:(NSNotification *)notify{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_REPLYRESULT object:nil];
    
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_ReplyResult];
    NSDictionary *replyStatusDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        replyStatusDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    //NSDictionary *replyStatusDictionary=[[notify userInfo] objectForKey:KEY_MY_Dic_ReplyResult];
    [self.view makeToast:[replyStatusDictionary objectForKey:KEY_MSG]];
    
    NSString *submitStatu=[NSString stringWithFormat:@"%@",[replyStatusDictionary objectForKey:KEY_STATE]];
    if ([submitStatu isEqualToString:@"0"]) {
        //更新回复列表
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *userName=appDelegate.currentUser.userName;
        
        NSDate *currentDate=[NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        [dateFormatter release];
        NSDictionary *replyDic=[NSDictionary dictionaryWithObjectsAndKeys:userName,@"replyPubUser",
                                                                        dateString,@"replyPubDate",
                                                                     textView.text,@"replyContent", nil];
        NSMutableArray *replyArray=[NSMutableArray arrayWithArray:self.logObj.replyArray];  //属性的属性是固定的，所以只能替换了
        [replyArray addObject:replyDic];
        [self.logObj setReplyArray:replyArray];

        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:4];
        [_oaDetailTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
        textView.text=@"";  //清空内容
    }
    else{
        NSString *msg=[NSString stringWithFormat:@"%@",[replyStatusDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
    //恢复按钮点击
    textView.editable=YES;
    submitBtn.enabled=YES;
//    NSLog(@"handleReplyResult_end");
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

@end










