//
//  todayRoutineDetailVC.m
//  OA_TGNET
//
//  Created by yzq on 13-7-17.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "WorkDetailVC.h"
#import "NavigationBarWithBg.h"
#import <QuartzCore/QuartzCore.h>

@interface WorkDetailVC (){
    BOOL isLegal;
}
@end

@implementation WorkDetailVC

- (void)dealloc {
    [_progressSlider release];
    [_progressTextFiled release];
    [_tarFinishStateTextView release];
    [_tarCorperFiled release];
    [_tarContentFiled release];
    [_tarMayCostTimeFiled release];
    [_tarCostTimeFiled release];
    [_tarAffectUserFiled release];
    [_targets release];
    self.addCallBackBlock=nil;
    self.editCallBackBlock=nil;
    [_deleteBtn release];
    [_OKBtn release];
    [_scrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setProgressSlider:nil];
    [self setProgressTextFiled:nil];
    [self setTarFinishStateTextView:nil];
    [self setTarCorperFiled:nil];
    [self setTarContentFiled:nil];
    [self setTarMayCostTimeFiled:nil];
    [self setTarCostTimeFiled:nil];
    [self setTarAffectUserFiled:nil];
    self.targets=nil;
    [self setDeleteBtn:nil];
    [self setOKBtn:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
	keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
	[keyBoardController addToolbarToKeyboard];
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_OA_Totay];
    [super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	MCRelease(keyBoardController);
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_OA_Totay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    [self.scrollView setContentSize:CGSizeMake(ScreenBoundsSize.width, 500)];
    
    [self.progressSlider setValue:.0];  //进度显示0
    
    NavigationBarWithBg *navBar=[[NavigationBarWithBg alloc] initWithDefaultFrame:YES Title:self.title LeftBtnTitle:@"确定" RightBtnTitle:@"取消"];
    [navBar.leftBarButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [navBar.rightBarButton addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBar];
    [navBar release];
    
    //动态改变滑块的值
    [self.progressTextFiled addTarget:self action:@selector(progressChanged) forControlEvents:UIControlEventEditingChanged];
    
    isLegal=NO; //用于限制某些必填的参数
    if (self.editCallBackBlock) {
        [self fillForm];            //填充数据
    }else if(self.addCallBackBlock){
        _deleteBtn.enabled=NO;      //添加的情况不需要删除按钮
        _deleteBtn.alpha=.5;
    }
    
    if (_targets.logID) {           //如果是编辑对象的话，那么内容跟预计用时，不可以更改，也不能删除 _mark 这里更改一下样式
        _tarContentFiled.enabled=NO;
        _tarMayCostTimeFiled.enabled=NO;
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

-(void) progressChanged{
    //NSLog(@"滑动 %@",_progressTextFiled.text);
    CGFloat sliderValue=_progressTextFiled.text.integerValue/100.0;
    [self.progressSlider setValue:sliderValue animated:YES];
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
//删除操作
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
        [self.tarContentFiled setText:[NSString stringWithFormat:@"%@",_targets.tarContent]];
        self.tarMayCostTimeFiled.text=_targets.tarMayCostTime;
        self.tarCostTimeFiled.text=_targets.tarCostTime;
        self.tarAffectUserFiled.text=_targets.tarAffectUser;
        self.tarCorperFiled.text=_targets.tarCorper;
        self.progressTextFiled.text=_targets.tarProgress;
        [self.progressSlider setValue:_targets.tarProgress.floatValue/100];
        self.tarFinishStateTextView.text=_targets.tarFinishState;
    }
}

-(void) fillTargetsObj{
    //检查必填项是否为空
    if(_targets.logID){        //编辑的话，实际跟进度可以不填    (可能没完成活没做) 用 have logid来判断
        isLegal=![_tarContentFiled.text isEqualToString:@""] && ![_tarMayCostTimeFiled.text isEqualToString:@""]&&![_tarFinishStateTextView.text isEqualToString:@""];
    }
    else{                       //添加的话，实际时间跟进度都要填   (实际做的才要添加)
        isLegal=![_tarContentFiled.text isEqualToString:@""]&&![_tarMayCostTimeFiled.text isEqualToString:@""]&&![_tarCostTimeFiled.text isEqualToString:@""]&&![_progressTextFiled.text isEqualToString:@""]&&![_tarFinishStateTextView.text isEqualToString:@""];
    }
    
    if (_targets) {
        self.targets.tarContent=[_tarContentFiled.text isEqualToString:@""]? nil:_tarContentFiled.text;
        self.targets.tarMayCostTime=[_tarMayCostTimeFiled.text isEqualToString:@""]? nil:_tarMayCostTimeFiled.text;
        self.targets.tarCostTime=[_tarCostTimeFiled.text isEqualToString:@""]? nil:_tarCostTimeFiled.text;
        self.targets.tarAffectUser=[_tarAffectUserFiled.text isEqualToString:@""]? nil:_tarAffectUserFiled.text;
        self.targets.tarCorper=[_tarCorperFiled.text isEqualToString:@""]? nil:_tarCorperFiled.text;
        self.targets.tarProgress=[_progressTextFiled.text isEqualToString:@""]? nil:_progressTextFiled.text;
        self.targets.tarFinishState=[_tarFinishStateTextView.text isEqualToString:@""]? nil:_tarFinishStateTextView.text;
    }
}

////点击取消或完成按钮 _mark 需要控制必填项
- (void)finishEdit:(UIButton *)sender {
    [self.tarContentFiled becomeFirstResponder];
    [self.tarContentFiled resignFirstResponder];    //回到顶层textFiled，再dismiss...
    
    if ([sender.titleLabel.text isEqualToString:@"取消"]) {
        [self dismissModalViewControllerAnimated:YES];
    }else if ([sender.titleLabel.text isEqualToString:@"确定"]){
        [self fillTargetsObj];  //根据填写信息赋值给对象
        //判断有没有填
        if (!isLegal) {
            [self.view makeToast:@"请填写带*号的必填项"];
            return;
        }
        //判断时间是不是规范
        if (_tarMayCostTimeFiled.text.integerValue>24 || _tarMayCostTimeFiled.text.integerValue<=0 || _tarCostTimeFiled.text.integerValue>24 ) {
            [self.view makeToast:@"请填写有效的时间"];
            return;
        }
        
        if (_addCallBackBlock) {
            _addCallBackBlock(_targets);                //添加的回调
            [self dismissModalViewControllerAnimated:YES];
        }else if(_editCallBackBlock){
            _editCallBackBlock(_index,_targets,NO);     //编辑的回调
            [self dismissModalViewControllerAnimated:YES];
        }
        
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSInteger proIntValue=sender.value*100;
    self.progressTextFiled.text=[NSString stringWithFormat:@"%d",proIntValue];
}

- (IBAction)hideKeyBoard:(UIButton *)sender {
    [_tarContentFiled resignFirstResponder];
    [_tarMayCostTimeFiled resignFirstResponder];
    [_tarCostTimeFiled resignFirstResponder];
    [_tarAffectUserFiled resignFirstResponder];
    [_tarFinishStateTextView resignFirstResponder];
    [_progressTextFiled resignFirstResponder];
    [_tarCorperFiled resignFirstResponder];
}
@end











