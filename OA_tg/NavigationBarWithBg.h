//
//  NavigationBarWithBg.h
//  南苑新声
//
//  Created by yzq on 13-5-3.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>

#define navBarHeight    44.0
@interface NavigationBarWithBg : UINavigationBar

@property (nonatomic,strong) UIButton *leftBarButton;
@property (nonatomic,strong) UIButton *rightBarButton;
@property (nonatomic,strong) UILabel *titleLabe;

-(id) initWithDefaultFrame:(BOOL)useDefault Title:(NSString *)title LeftBtnTitle:(NSString *)leftBtnTitle RightBtnTitle:(NSString *)rightBtnTitle;

@end