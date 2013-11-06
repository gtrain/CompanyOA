//
//  FeelingsViewController.m
//  OA_TGNET
//
//  Created by yzq on 13-7-18.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "FeelingsViewController.h"
#import "FaceBoard.h"

@interface FeelingsViewController (){
    FaceBoard *_faceBoard;
}
@end

@implementation FeelingsViewController

- (void)dealloc {
    [_textView release];
    [_faceBoard release];
    [_faceBtn release];
    [_textViewContent release];
    self.feellingBlock=nil;
    [super dealloc];
}
- (void)viewDidUnload {
    self.textViewContent=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [self setTextView:nil];
    [self setFaceBtn:nil];
    self.feellingBlock=nil;
    [super viewDidUnload];
}
-(void) viewDidAppear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewStartWithName:kStat_Page_OA_Feel];
    [super viewDidAppear:YES];
}
-(void) viewDidDisappear:(BOOL)animated{
    [[BaiduMobStat defaultStat] pageviewEndWithName:kStat_Page_OA_Feel];
    [super viewDidDisappear:YES];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithBlock:(FeellingTextBlock)callBackBlock{
    self=[super init];
    if (self) {
        self.feellingBlock=callBackBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:241/255.0 blue:243/255.0 alpha:1.0]];
    _faceBoard = [[FaceBoard alloc]init];
    [self.textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    if (_textViewContent) {
        self.textView.text=_textViewContent;
    }
//    else{
//        //_mark 今天有什么新鲜事
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishEdit:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];
    if ([sender.titleLabel.text isEqualToString:@"取消"]) {
        return;
    }else if ([sender.titleLabel.text isEqualToString:@"确定"]){
        if (_feellingBlock) {
            _feellingBlock(_textView.text);
        }
    }
}

- (IBAction)faceBtnPress:(UIButton *)sender {
    [self.textView resignFirstResponder];
    _faceBtn.selected=!_faceBtn.selected;
}

- (void)keyboardDidHide:(NSNotification*)notification {
    //键盘退下后，键盘换成表情键盘
    if (_faceBtn.selected) {
        _faceBoard.inputTextView = self.textView;
        self.textView.inputView = _faceBoard;
    }else{
        self.textView.inputView = nil;
    }
    [self.textView becomeFirstResponder];
}
@end
