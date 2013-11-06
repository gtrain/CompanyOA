//
//  todayRoutineDetailVC.m
//  OA_TGNET
//
//  Created by yzq on 13-7-17.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "PlanWorkDetailVC.h"
#import "NavigationBarWithBg.h"
#import "UIAlertView+Blocks.h"
#import <QuartzCore/QuartzCore.h>

@interface PlanWorkDetailVC (){
    BOOL isLegal;
}
@end

@implementation PlanWorkDetailVC

- (void)dealloc {
    [_tarCorperFiled release];
    [_tarContentFiled release];
    [_tarMayCostTimeFiled release];
    [_targets release];
    self.addCallBackBlock=nil;
    self.editCallBackBlock=nil;
    [_deleteBtn release];
    [_OKBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTarCorperFiled:nil];
    [self setTarContentFiled:nil];
    [self setTarMayCostTimeFiled:nil];
    self.targets=nil;
    [self setDeleteBtn:nil];
    [self setOKBtn:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_OA_Plane];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	MCRelease(keyBoardController);
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_OA_Plane];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:self.title LeftBtnTitle:@"确定" RightBtnTitle:@"取消"];
    [navBar.leftBarButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [navBar.rightBarButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    [navBar release];
    
    isLegal=NO; //限制某些必填的参数
    
    if (self.editCallBackBlock) {
        [self fillForm];    //填充数据
    }else if(self.addCallBackBlock){
        _deleteBtn.enabled=NO;      //添加的情况不需要删除按钮
        _deleteBtn.alpha=.5;
    }
    
    if (_targets.logID) {           //如果是编辑明天计划的话，不能删除 _mark 这里更改一下样式
        _deleteBtn.enabled=NO;
        _deleteBtn.alpha=.5;
    }
    
    //确定按钮
    [_OKBtn addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [_OKBtn.layer setCornerRadius:6.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(id) initWithTarType:(NSInteger)type addTargetsBlock:(AddTargetsBlock)callBackBlock{
    self=[super init];
    if (self) {
        self.targets=[[[TargetsDataObj alloc] init] autorelease];
        _targets.tarType=[NSString stringWithFormat:@"%d",type];
        self.addCallBackBlock=callBackBlock;
    }
    return self;
}

-(id) initWithTargetsDataObj:(TargetsDataObj *)dataObj objIndex:(NSInteger)index editTargetsBlock:(EditTargetsBlock)callBackBlock{
    self=[super init];
    if (self) {
        self.targets=dataObj;
        self.index=index;
        self.editCallBackBlock=callBackBlock;
    }
    return self;
}

- (IBAction)deleteBtnPress:(UIButton *)sender {
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"删除日志" message:@"确定删除吗？"
                                             cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
        
    }]
                                             otherButtonItems:[RIButtonItem itemWithLabel:@"确定" action:^{
        _editCallBackBlock(_index,_targets,YES);    //删除
        [self dismissModalViewControllerAnimated:YES];
    }], nil];
    [alertView show];
    [alertView release];
}

#pragma mark -- my function --
-(void) fillForm{
    //根据编辑对象填充
    if (_targets) {
        self.tarContentFiled.text=_targets.tarContent;
        self.tarMayCostTimeFiled.text=_targets.tarMayCostTime;
        self.tarCorperFiled.text=_targets.tarCorper;
    }
}

-(void) fillTargetsObj{
    //_mark 添加限制条件 ，完成编辑后的赋值对象
    isLegal=![_tarContentFiled.text isEqualToString:@""] && ![_tarMayCostTimeFiled.text isEqualToString:@""] ;
    
    if (_targets) {
        self.targets.tarContent=_tarContentFiled.text;
        self.targets.tarMayCostTime=_tarMayCostTimeFiled.text;
        self.targets.tarCorper=_tarCorperFiled.text;
    }
}

////点击取消或完成按钮 _mark 需要控制必填项
- (void)finishEdit:(UIButton *)sender {
    [self.tarContentFiled becomeFirstResponder];
    [self.tarContentFiled resignFirstResponder];    //回到顶层，再dismiss...
    
    if ([sender.titleLabel.text isEqualToString:@"取消"]) {
//        Log(@"取消编辑");
        [self dismissModalViewControllerAnimated:YES];
    }else if ([sender.titleLabel.text isEqualToString:@"确定"]){
        [self fillTargetsObj];
        if (!isLegal) {
            [self.view makeToast:@"请填写带*号的必填项"];
            return;
        }
        
        //判断时间是不是规范
        if (_tarMayCostTimeFiled.text.integerValue>24 || _tarMayCostTimeFiled.text.integerValue<=0 ) {
            [self.view makeToast:@"请填写有效的时间"];
            return;
        }
        
        if (_addCallBackBlock) {
            _addCallBackBlock(_targets);            //添加回调
            [self dismissModalViewControllerAnimated:YES];
        }else if(_editCallBackBlock){
            _editCallBackBlock(_index,_targets,NO);    //编辑回调
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    
}

//点击退下键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_tarContentFiled resignFirstResponder];
    [_tarCorperFiled resignFirstResponder];
    [_tarMayCostTimeFiled resignFirstResponder];
}

@end











