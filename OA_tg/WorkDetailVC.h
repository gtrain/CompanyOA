//
//  todayRoutineDetailVC.h
//  OA_TGNET
//
//  Created by yzq on 13-7-17.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKeyboardViewController.h"
#import "TargetsDataObj.h"
#import "UIAlertView+Blocks.h"
#import "Toast+UIView.h"

@interface WorkDetailVC : UIViewController<UIKeyboardViewControllerDelegate> {
    UIKeyboardViewController *keyBoardController;
}

@property (retain, nonatomic) IBOutlet UISlider *progressSlider;//滑块
- (IBAction)sliderValueChanged:(UISlider *)sender;              //根据更改进度值
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

//填写内容框框
@property (retain, nonatomic) IBOutlet UITextField *tarContentFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarMayCostTimeFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarCostTimeFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarAffectUserFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarCorperFiled;
@property (retain, nonatomic) IBOutlet UITextField *progressTextFiled;
@property (retain, nonatomic) IBOutlet UITextView *tarFinishStateTextView;

@property (retain, nonatomic) IBOutlet UIButton *OKBtn;

//要填充和提交的内容
@property (retain, nonatomic) TargetsDataObj *targets;
@property (assign,nonatomic) NSInteger index;       //编辑对象的索引值

//回调Block
@property (strong, nonatomic) AddTargetsBlock addCallBackBlock;
@property (strong, nonatomic) EditTargetsBlock editCallBackBlock;

//编辑的初始化函数跟添加的初始化函数
-(id) initWithTarType:(NSInteger)type addTargetsBlock:(AddTargetsBlock)callBackBlock;
-(id) initWithTargetsDataObj:(TargetsDataObj *)dataObj objIndex:(NSInteger)index editTargetsBlock:(EditTargetsBlock)callBackBlock;

//删除
- (IBAction)deleteBtnPress:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)hideKeyBoard:(UIButton *)sender;

@end
