//
//  FeelingsViewController.h
//  OA_TGNET
//
//  Created by yzq on 13-7-18.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FeellingTextBlock)(NSString *);
//这里注意不要加东西呀 eg:(NSString * xxxx);

@interface FeelingsViewController : UIViewController
- (IBAction)finishEdit:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) NSString *textViewContent;        //

//表情按钮
- (IBAction)faceBtnPress:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *faceBtn;
@property (strong,nonatomic) FeellingTextBlock feellingBlock;
-(id) initWithBlock:(FeellingTextBlock)callBackBlock;

@end
