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
#import "Toast+UIView.h"

//_mark 这里没用的要删掉

@interface PlanWorkDetailVC : UIViewController<UIKeyboardViewControllerDelegate> {
    UIKeyboardViewController *keyBoardController;
}

//填写内容框框
@property (retain, nonatomic) IBOutlet UITextField *tarContentFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarMayCostTimeFiled;
@property (retain, nonatomic) IBOutlet UITextField *tarCorperFiled;
@property (retain, nonatomic) IBOutlet UIButton *OKBtn;

//要填充和提交的内容
@property (retain, nonatomic) TargetsDataObj *targets;
@property (assign,nonatomic) NSInteger index;       //编辑对象的索引值

//回调Block
@property (strong, nonatomic) AddTargetsBlock addCallBackBlock;
@property (strong, nonatomic) EditTargetsBlock editCallBackBlock;


-(id) initWithTarType:(NSInteger)type addTargetsBlock:(AddTargetsBlock)callBackBlock;
-(id) initWithTargetsDataObj:(TargetsDataObj *)dataObj objIndex:(NSInteger)index editTargetsBlock:(EditTargetsBlock)callBackBlock;

- (IBAction)deleteBtnPress:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *deleteBtn;

@end
