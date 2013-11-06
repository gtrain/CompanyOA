//
//  AppDelegate.h
//  OA_tg
//
//  Created by yzq on 13-7-10.
//  Copyright (c) 2013年 yzq. All rights reserved.
//


//#define TestClass AboutViewController
//#define TestClassHeader "AboutViewController.h"
//#define IsDebug NO
//#import TestClassHeader

#import <UIKit/UIKit.h>
#import "UserObj.h"

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) TestClass *testViewController;   //_test

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) LoginViewController *loginViewController;

@property (strong, nonatomic) UserObj *currentUser;

@property (nonatomic) BOOL dontSave;


-(void) saveToUserDefaultAtOnce:(BOOL)atOnce;
-(void) removeUserInUserDefault;
-(BOOL) readFromUserDefaults;

-(void) pushToUsersBox;
-(void) popFromUsersBox;
-(NSMutableArray *) savedUsersArray;

//-(void) setLocalNotify:(UILocalNotification *)notify for:(NSString *)name;
//-(UILocalNotification *) getLocalNotifyName:(NSString *)name;
//-(void) removeLocalNotifyName:(NSString *)name;

@end
