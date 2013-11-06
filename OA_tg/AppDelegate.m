//
//  AppDelegate.m
//  OA_tg
//
//  Created by yzq on 13-7-10.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIAlertView+Blocks.h"
#import <AudioToolbox/AudioToolbox.h>

id returnSelf;

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_loginViewController release];
    self.navigationController=nil;
    self.currentUser=nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self baiduTrack];  //移动统计
    //程序载后台允许的时候，提醒
    returnSelf=self;
    UILocalNotification *localNotify=[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotify) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.loginViewController=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    self.navigationController=[[[UINavigationController alloc] initWithRootViewController:_loginViewController] autorelease];
    self.navigationController.navigationBar.hidden=YES;
    
//    if (IsDebug) {
//        self.testViewController=[[TestClass alloc] init];
//        self.window.rootViewController=_testViewController;
//        [self.window makeKeyAndVisible];
//        return YES;
//    }
    
    self.window.rootViewController=_navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //清除通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDictionary *userInfoDic=(NSDictionary *)notification.userInfo;
    
    if ([[userInfoDic objectForKey:key_voice] isEqualToString:@"1"]) {
        AudioServicesAddSystemSoundCompletion (
                                               1151,
                                               NULL,
                                               NULL,
                                               SystemSoundCompletionProc,
                                               NULL
                                               );
        AudioServicesPlaySystemSound(1151);
    }
    
    if ([[userInfoDic objectForKey:key_shake] isEqualToString:@"1"]) {
        AudioServicesAddSystemSoundCompletion (
                                               kSystemSoundID_Vibrate,
                                               NULL,
                                               NULL,
                                               SystemVibrateCompletionProc,
                                               NULL
                                               );
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:[userInfoDic objectForKey:key_titile] message:[userInfoDic objectForKey:key_message]
                                             cancelButtonItem:[RIButtonItem itemWithLabel:@"好的" action:^{
                                                            //Log(@"_停止震动或者响铃");
                                                            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
                                                            AudioServicesRemoveSystemSoundCompletion(1151);
                                                        }] otherButtonItems:nil, nil];
    [alertView show];
    [alertView release];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark --Moblie App Stat--
-(void) baiduTrack{
    BaiduMobStat *statTracker=[BaiduMobStat defaultStat];
    statTracker.channelId = @"内部下载渠道";              //设置您的app的发布渠道名字,默认AppStore渠道。用于统计不同渠道的下载，比如AppStore，Cydia，91，PP
    statTracker.enableExceptionLog = YES;               // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch; //根据开发者设定的时间间隔接口发送，也可以选启动时发送
    statTracker.logSendInterval = 1;                            //发送日志的时间间隔为1小时，logStrategy 设置自定义的时候有效
    statTracker.logSendWifiOnly = NO;                   //仅在WIfi下发送日志数据
    statTracker.sessionResumeInterval = 60;             //设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    statTracker.shortAppVersion = IosAppVersion;       //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [statTracker startWithAppId:kStat_APPKEY];          //设置您在mtj网站上添加的app的appkey
}


#pragma mark --MyFunction--
void SystemSoundCompletionProc (SystemSoundID ssID,void *clientData) {
    @synchronized(returnSelf){
        [returnSelf performSelector:@selector(ring) withObject:nil afterDelay:1.4];
    }
}
-(void) ring{
    AudioServicesPlaySystemSound(1151);
}

void SystemVibrateCompletionProc (SystemSoundID ssID,void *clientData) {
    @synchronized(returnSelf){
        [returnSelf performSelector:@selector(vibrate) withObject:nil afterDelay:.8];
    }
}
-(void) vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


//保存现在的用户
-(void) saveToUserDefaultAtOnce:(BOOL)atOnce{
    if (_dontSave) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
    [userDefaults setObject:userData forKey:@"USER_DATA"];
    if (atOnce) {
        [userDefaults synchronize];
    }
}
//读取用户
-(BOOL) readFromUserDefaults{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userData=[userDefaults objectForKey:@"USER_DATA"];
    if (userData) {
        UserObj *user=[NSKeyedUnarchiver unarchiveObjectWithData:userData];
        [self setCurrentUser:user];
        return YES;
    }else{
        return NO;
    }
}

//删除用户
-(void) removeUserInUserDefault{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"USER_DATA"];
    [userDefaults synchronize];
}

//保存到用户组
-(void) pushToUsersBox{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tmpUserArray=(NSArray *)[userDefaults objectForKey:@"USERS_ARRAY"];
    NSMutableArray *userArray=nil;
    if (!tmpUserArray) {
        userArray=[NSMutableArray arrayWithCapacity:0];
    }else{
        userArray=[NSMutableArray arrayWithArray:tmpUserArray];
    }
    //限制保存用户数量在6个
    if (userArray.count>5) {
        [userArray removeObjectAtIndex:0];
    }

    //检查重复
    NSData *targetData=nil;
    if (userArray.count !=0) {
        for (NSData *uData in userArray) {
            UserObj *targetUser=[NSKeyedUnarchiver unarchiveObjectWithData:uData];
            NSString *userNo=targetUser.userNo;
            if ([_currentUser.userNo isEqualToString:userNo]) {
                targetData=uData;
            }
        }
    }

    //如果已经存在则删除掉，再更新
    if(targetData){
        [userArray removeObject:targetData];
    }
//    if (!targetDic) {
        //NSDictionary *userDic=[_currentUser userDictionary];
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
        [userArray addObject:userData];
        //加入后更新
        [userDefaults setObject:userArray forKey:@"USERS_ARRAY"];
        [userDefaults synchronize];
//    }
}
//从用户组删除
-(void) popFromUsersBox{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *userArray=(NSArray *)[userDefaults objectForKey:@"USERS_ARRAY"];
    NSMutableArray *mutableUserArray=nil;
    if (userArray && [userArray isKindOfClass:[NSArray class]] && userArray.count !=0) {
        mutableUserArray=[NSMutableArray arrayWithArray:userArray];

        NSData *targetData=nil;
        for (NSData *uData in mutableUserArray) {
            UserObj *targetUser=[NSKeyedUnarchiver unarchiveObjectWithData:uData];
            NSString *userNo=targetUser.userNo;
            if ([_currentUser.userNo isEqualToString:userNo]) {
                targetData=uData;
            }
        }
        if (targetData) {
            [mutableUserArray removeObject:targetData];
        }
    }
    
    if (mutableUserArray) {
        //删除后更新
        [userDefaults setObject:mutableUserArray forKey:@"USERS_ARRAY"];
        [userDefaults synchronize];
    }
    else{
        [userDefaults removeObjectForKey:@"USERS_ARRAY"];
        [userDefaults synchronize];
    }
}

//取出用户组
-(NSMutableArray *) savedUsersArray{
    NSArray *dataArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"USERS_ARRAY"];
    NSMutableArray *objArray=[NSMutableArray arrayWithCapacity:0];
    for (NSData *uData in dataArray) {
        UserObj *uObj=[NSKeyedUnarchiver unarchiveObjectWithData:uData];
        [objArray addObject:uObj];
    }
    return objArray;
}

//-(void) setLocalNotify:(UILocalNotification *)notify for:(NSString *)name{
//    if ([name isEqualToString:@"oa"]) {
//    name 当作key来用
//    }else if([name isEqualToString:@"order"]){}
//}
//-(UILocalNotification *) getLocalNotifyName:(NSString *)name{
//
//}
//-(void) removeLocalNotifyName:(NSString *)name{
//
//}

@end







