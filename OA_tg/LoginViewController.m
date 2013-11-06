//
//  QQViewController.m
//  QQLogin
//
//  Created by Reese on 13-6-17.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
//标签页
#import "TodaySworkViewController.h"
#import "TodaySsummaryViewController.h"
#import "OrderViewController.h"
#import "SettingViewController.h"

#import "AppDelegate.h"
#import "Toast+UIView.h"

#import "UserObj.h"

#define ANIMATION_DURATION 0.3f

//_mark 对键盘的处理 dome

@interface LoginViewController (){
    BOOL _isShowingActivity;
    AppDelegate *appDelegate;
    
    NSMutableArray *savedUserArray;
}
// _important UserDefault存两个，一个是用户数组，另一个是
@end

@implementation LoginViewController
-(void) viewDidAppear:(BOOL)animated{
    self.savedUsersArray=[appDelegate savedUsersArray];
    [self reloadAccountBox];
    
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_Login];
    [super viewDidAppear:YES];
}
// _mark 增加用户名输入 begin edit 的代理； 收起box跟重置头像

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    _rememberBtn.selected=YES;   //默认记住密码
    _isShowingActivity=NO;      //选择视图
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate readFromUserDefaults]) {
        [[NetWorkEngine shareNetWorkEngine] getNewCookie];
        [self gotoTabPage];
        //[self performSelector:@selector(queryWhenLogined) withObject:nil afterDelay:.03];
//        _userNameInput.text=appDelegate.currentUser.userNo;
//        _userPasswordInput.text=appDelegate.currentUser.userPassword;
//        [self login:nil];
        return;
    }

    [super viewDidLoad];
    
    
    self.savedUsersArray=[appDelegate savedUsersArray];
    [self reloadAccountBox];
    
    [_userNameInput becomeFirstResponder];  //调出键盘
    [_userNameInput setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // _mark 也许需要
}

-(void) viewDidDisappear:(BOOL)animated{
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        _isShowingActivity =NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOGINRESULT object:nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_Login];
    [super viewDidDisappear:YES];
}

- (void)dealloc {
    self.savedUsersArray=nil;
    self.tabbarVC=nil;
    [_dropButton release];
    [_moveDownGroup release];
    [_account_box release];
    [_userNameInput release];
    [_userPasswordInput release];
    [_userLargeHead release];
    [_numberLabel release];
    [_passwordLabel release];
    [_rememberBtn release];
    [super dealloc];
}

#pragma mark --logical--

-(void) gotoTabPage{
    TodaySworkViewController *todaySworkVC=[[[TodaySworkViewController alloc] initWithNibName:@"TodaySworkViewController" bundle:nil] autorelease];
    UITabBarItem *item=[[UITabBarItem alloc] initWithTitle:@"今日工作" image:[UIImage imageNamed:@"toolbar_today_work"] tag:0];
    todaySworkVC.tabBarItem=item;
    [item release];
    
    TodaySsummaryViewController *todaySsummaryVC=[[[TodaySsummaryViewController alloc] initWithNibName:@"TodaySsummaryViewController" bundle:nil] autorelease];
    UITabBarItem *tItem=[[UITabBarItem alloc] initWithTitle:@"日总结" image:[UIImage imageNamed:@"toolbar_day_sum"] tag:1];
    todaySsummaryVC.tabBarItem=tItem;
    [tItem release];
    
    OrderViewController *orderVC=[[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
    UITabBarItem *oItem=[[UITabBarItem alloc] initWithTitle:@"报餐" image:[UIImage imageNamed:@"toolbar_meal"] tag:2];
    orderVC.tabBarItem=oItem;
    [oItem release];
    
    SettingViewController *setVC=[[SettingViewController alloc] init];
    UITabBarItem *sItem=[[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"toolbar_setting"] tag:3];
    setVC.tabBarItem=sItem;
    [sItem release];
    
    NSArray *tabBarViewArray=[[NSArray alloc] initWithObjects:todaySworkVC,todaySsummaryVC,orderVC,setVC,nil];
    self.tabbarVC=[[UITabBarController alloc] init];
    _tabbarVC.viewControllers=tabBarViewArray;
    [tabBarViewArray release];
    
    _tabbarVC.view.frame=self.view.bounds;
    [self.navigationController pushViewController:_tabbarVC animated:NO];
    [_tabbarVC release];
}

//处理登录结果
-(void) handleLoginResult:(NSNotification *)notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOGINRESULT object:nil];
    //去掉旋转圈圈
    if (_isShowingActivity) {
        [self.view hideToastActivity];
        [self.view setUserInteractionEnabled:YES];
        _isShowingActivity =NO;
    }
    //错误处理
    id requestResult=[[notify userInfo] objectForKey:KEY_MY_Dic_LoginResult];
    NSDictionary *loginResultDictionary=nil;
    if([requestResult isKindOfClass:[NSDictionary class]]){
        loginResultDictionary=requestResult;
    }else if ([requestResult isKindOfClass:[NSString class]]) {
        [self.view makeToast:requestResult];    //显示错误信息
        return;
    }else{
        [self.view makeToast:@"没有数据"];
        return;
    }
    
    //NSDictionary *loginResultDictionary=[[notify userInfo] objectForKey:KEY_MY_Dic_LoginResult];
    NSString *state=[NSString stringWithFormat:@"%@",[loginResultDictionary objectForKey:KEY_STATE]];
    if ( [state isEqualToString:@"0"] ) {
        //更新cookies
        NSArray *cookiesArray=(NSArray *)[notify.userInfo objectForKey:KEY_MY_Arr_UserCookies];
        NSHTTPCookie *cookie=[cookiesArray objectAtIndex:0];
        
        [[NetWorkEngine shareNetWorkEngine] setUserCookie:cookie];
        [[NetWorkEngine shareNetWorkEngine] setCreatedDate:[NSDate date]];  //记下获取的时间 20分钟过期
        
        //如果是保存用户后的自动登陆，不要覆盖原有数据只更新cookie
        if (![appDelegate readFromUserDefaults] && ![appDelegate.currentUser.userNo isEqualToString:_userNameInput.text]) {
            //Log(@"没有保存用户");
            UserObj *currentUser=[[UserObj alloc] initWithDictionary:[loginResultDictionary objectForKey:KEY_DATA]];
            [appDelegate setCurrentUser:currentUser];
            [currentUser release];
            //有勾选的话，保存userDefault。没有则放在deletegate（内存）
            if (_rememberBtn.selected) {
                [appDelegate saveToUserDefaultAtOnce:YES];
            }else{
                appDelegate.dontSave=YES;
            }
        }
        [self gotoTabPage];
        //这里是正常登陆后，发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_FinishRefreshCookie object:nil userInfo:nil];
        
    }else{
        NSString *msg=[NSString stringWithFormat:@"%@ :(",[loginResultDictionary objectForKey:KEY_MSG]];
        ///显示提示信息错误
        [self.view makeToast:msg];
    }
}



#pragma mark --UI--

- (IBAction)dropDown:(id)sender {
    if ([sender isSelected]) {
        [self hideAccountBox];
    }else
    {
        [self showAccountBox];
    }
}

-(void)showAccountBox
{
    [_dropButton setSelected:YES];
    CABasicAnimation *move=[CABasicAnimation animationWithKeyPath:@"position"];
    [move setFromValue:[NSValue valueWithCGPoint:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y)]];
    [move setToValue:[NSValue valueWithCGPoint:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y+_account_box.frame.size.height)]];
    [move setDuration:ANIMATION_DURATION];
    [_moveDownGroup.layer addAnimation:move forKey:nil];

    [_account_box setHidden:NO];
    
    //模糊处理
    [_userLargeHead setAlpha:0.5f];
    [_numberLabel setAlpha:0.5f];
    [_passwordLabel setAlpha:0.5f];
    [_userNameInput setAlpha:0.5f];
    [_userPasswordInput setAlpha:0.5f];
    
    CABasicAnimation *scale=[CABasicAnimation animationWithKeyPath:@"transform"];
    [scale setFromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 0.2, 1.0)]];
    [scale setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    CABasicAnimation *center=[CABasicAnimation animationWithKeyPath:@"position"];
    [center setFromValue:[NSValue valueWithCGPoint:CGPointMake(_account_box.center.x, _account_box.center.y-_account_box.bounds.size.height/2+8)]];
    [center setToValue:[NSValue valueWithCGPoint:CGPointMake(_account_box.center.x, _account_box.center.y)]];
    
    CAAnimationGroup *group=[CAAnimationGroup animation];
    [group setAnimations:[NSArray arrayWithObjects:scale,center, nil]];
    [group setDuration:ANIMATION_DURATION];
    [_account_box.layer addAnimation:group forKey:nil];
    
    [_moveDownGroup setCenter:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y+_account_box.frame.size.height)];
}

//隐藏下拉框
-(void)hideAccountBox
{
    [_dropButton setSelected:NO];
    CABasicAnimation *move=[CABasicAnimation animationWithKeyPath:@"position"];
    [move setFromValue:[NSValue valueWithCGPoint:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y)]];
    [move setToValue:[NSValue valueWithCGPoint:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y-_account_box.frame.size.height)]];
    [move setDuration:ANIMATION_DURATION];
    [_moveDownGroup.layer addAnimation:move forKey:nil];
    
    [_moveDownGroup setCenter:CGPointMake(_moveDownGroup.center.x, _moveDownGroup.center.y-_account_box.frame.size.height)];
    [_userLargeHead setAlpha:1.0f];
    [_numberLabel setAlpha:1.0f];
    [_passwordLabel setAlpha:1.0f];
    [_userNameInput setAlpha:1.0f];
    [_userPasswordInput setAlpha:1.0f];
    
    CABasicAnimation *scale=[CABasicAnimation animationWithKeyPath:@"transform"];
    [scale setFromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [scale setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 0.2, 1.0)]];
    
    CABasicAnimation *center=[CABasicAnimation animationWithKeyPath:@"position"];
    [center setFromValue:[NSValue valueWithCGPoint:CGPointMake(_account_box.center.x, _account_box.center.y)]];
    [center setToValue:[NSValue valueWithCGPoint:CGPointMake(_account_box.center.x, _account_box.center.y-_account_box.bounds.size.height/2+8)]];
    
    CAAnimationGroup *group=[CAAnimationGroup animation];
    [group setAnimations:[NSArray arrayWithObjects:scale,center, nil]];
    [group setDuration:ANIMATION_DURATION];
    [_account_box.layer addAnimation:group forKey:nil];
    
    [UIView animateWithDuration:0.16 animations:^(void) {
        _account_box.alpha=.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 animations:^(void) {
            _account_box.alpha=.3;
        } completion:^(BOOL finished) {
            _account_box.hidden=YES;
            _account_box.alpha=1.0;
        }];
    }];
    //[_account_box performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:NO] afterDelay:.25f];
}


-(void)reloadAccountBox
{
    for (UIView* view in _account_box.subviews) {
        if (view.tag!=20000) {
            [view removeFromSuperview];
        } 
    }
    int count=_savedUsersArray.count;
    //图片之间的间距
    CGFloat insets=0.0;
    //图片的宽度与背景的宽度
    CGFloat imageWidth=49,bgWidth=288,bgHeight=80;
    //根据账号数量对3的商来计算整个view高度的调整
    CGFloat newHeight;
    newHeight=((count-1)/3)*80+80;
    if (newHeight!=bgHeight) {
        [_account_box setFrame:CGRectMake(_account_box.frame.origin.x, _account_box.frame.origin.y, _account_box.frame.size.width, newHeight)];
    }
    CGFloat paddingTop=(bgHeight-imageWidth)/2;
    CGFloat paddingLeft=(320-bgWidth)/2;
    if (count >3) {
        insets=(bgWidth-imageWidth*3)/4;
    }else{
    //根据图片数量对3取模计算间距
    switch (count%3) {
        case 0:
            insets=(bgWidth-imageWidth*3)/4;
            
            break;
        case 1:
            insets=(bgWidth-imageWidth)/2;
            break;
        case 2:
            insets=(bgWidth-imageWidth*2)/3;
            break;
        default:
            break;
        }
    }
    for (int i=0;i<_savedUsersArray.count;i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(paddingLeft+insets+(i%3)*(imageWidth+insets), paddingTop+80*(i/3), imageWidth, imageWidth)];
        [button setBackgroundImage:[UIImage imageNamed:@"login_dropdown_avatar_border"] forState:UIControlStateNormal];
        [button.imageView setImage:[UIImage imageNamed:@"login_avatar"]];
        button.tag=10000+i;
        [button addTarget:self action:@selector(chooseAccount:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *headImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 45 , 45)];
        [headImage.layer setCornerRadius:3.0];
        [headImage setClipsToBounds:YES];
        [headImage setCenter:CGPointMake(button.center.x, button.center.y)];
        
        //NSData *imgData=[_savedUsersArray[i] objectForKey:KEY_userFaceData];
        NSData *imgData=[_savedUsersArray[i] userFaceData];
        if (imgData) {
            [headImage setImage:[UIImage imageWithData:imgData]];
        }else{
            [headImage setImage:[UIImage imageNamed:@"login_avatar_default"]];
        }
        
        [_account_box addSubview:headImage];
        [headImage release];
        [_account_box addSubview:button];
    }
}
//点击账号
- (void)chooseAccount:(UIButton*)button
{
    int accountIndex=button.tag-10000;
    //当前帐号也进行设置。
    [appDelegate setCurrentUser:[_savedUsersArray objectAtIndex:accountIndex]];
    [_userNameInput setText:appDelegate.currentUser.userNo];
    [_userPasswordInput setText:appDelegate.currentUser.userPassword];

    //[UIImage imageNamed:@"login_avatar_default"]
    NSData *imgData=[[_savedUsersArray objectAtIndex:accountIndex] userFaceData];
    if (imgData) {
        [_userLargeHead setImage:[UIImage imageWithData:imgData]];
    }else{
        [_userLargeHead setImage:[UIImage imageNamed:@"login_avatar_default"]];
    }
    
    [self hideAccountBox];
}
//登陆
- (IBAction)login:(id)sender {
    if (_isShowingActivity) {
        return;
    }
    [self touchesBegan:nil withEvent:nil];     //退下键盘
    
    if ([_userNameInput.text isEqualToString:@""]) { //密码初始为空，所以不做要求
        [self.view makeToast:@"请输入用户名 :）"];
        return;
    }
    //Log(@"正在登陆，跳转 _mark 弹窗提示");  这里要判断一下是不是有active的view
    if (!_isShowingActivity) {
        [self.view makeToastActivity];
        _isShowingActivity =YES;
        [self.view setUserInteractionEnabled:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginResult:) name:NOTIFY_LOGINRESULT object:nil];
    //发起请求
    NSDictionary *userNameDic=[NetWorkEngine synthesisCookiePropertiesWithValue:_userNameInput.text name:KEY_USERNO];
    NSDictionary *userPasswordDic=[NetWorkEngine synthesisCookiePropertiesWithValue:_userPasswordInput.text name:KEY_PASSWORD];
    NSArray *infoArray=[NSArray arrayWithObjects:userNameDic,userPasswordDic,nil];
    [[NetWorkEngine shareNetWorkEngine] addRequestUseCookie:NO parameterDicArray:infoArray apiString:URL_LOGIN_GET_COOKIE Method:@"GET" Tag:GetUserCookie];
}

//点击退下键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userNameInput resignFirstResponder];
    [_userPasswordInput resignFirstResponder];
    if(_dropButton.selected)    [self hideAccountBox];
}
- (void)viewDidUnload {
    [self setUserNameInput:nil];
    [self setUserPasswordInput:nil];
    
    [self setRememberBtn:nil];
    [super viewDidUnload];
}
- (IBAction)rememberMe:(UIButton *)sender {
    sender.selected=!sender.selected;
}

#pragma mark --UITextFieldDelegate--
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([_dropButton isSelected]) {
        _dropButton.selected=NO;
        [self hideAccountBox];
    }
    [_userLargeHead setImage:[UIImage imageNamed:@"login_avatar_default"]];
    [self reloadAccountBox];
}

@end
