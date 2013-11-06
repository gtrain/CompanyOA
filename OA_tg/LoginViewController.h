//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetWorkEngine.h"

// _mark 检测alloc 跟 release ；
// _检查 dealloc跟 viewDealloc 中跟 property interface中有没有什么不同

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong) NSMutableArray *savedUsersArray;

@property (nonatomic,strong) UITabBarController *tabbarVC;

@property (retain, nonatomic) IBOutlet UIButton *dropButton;
- (IBAction)dropDown:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *moveDownGroup;
@property (retain, nonatomic) IBOutlet UIView *account_box;

@property (retain, nonatomic) IBOutlet UITextField *userNameInput;
@property (retain, nonatomic) IBOutlet UILabel *numberLabel;
@property (retain, nonatomic) IBOutlet UITextField *userPasswordInput;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;

@property (retain, nonatomic) IBOutlet UIImageView *userLargeHead;
- (IBAction)login:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *rememberBtn;
- (IBAction)rememberMe:(UIButton *)sender;

@end
