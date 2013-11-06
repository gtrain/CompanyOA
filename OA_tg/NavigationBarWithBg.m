//
//  NavigationBarWithBg.m
//  南苑新声
//
//  Created by yzq on 13-5-3.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "NavigationBarWithBg.h"
#import <QuartzCore/QuartzCore.h>

@implementation NavigationBarWithBg

-(id) initWithDefaultFrame:(BOOL)useDefault Title:(NSString *)title{
    self= useDefault ? [super initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, navBarHeight)] : [super init] ;
    
    if (self) {
        //标题，这里用items数组添加
        self.titleLabe=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width,navBarHeight)];
        _titleLabe.textColor=[UIColor whiteColor];
        [_titleLabe setBackgroundColor:[UIColor clearColor]];
        [_titleLabe setFont:[UIFont systemFontOfSize:20.0]];
        [_titleLabe setTextAlignment:NSTextAlignmentCenter];
        _titleLabe.text=title;                                                      //
        
        UINavigationItem *item = [[UINavigationItem alloc] init];
        item.titleView=_titleLabe;
        [_titleLabe release];
        NSArray *items = [[NSArray alloc] initWithObjects:item,nil];
        [item release];
        [self setItems:items];
        [items release];
    }
    return self;
}

-(id) initWithDefaultFrame:(BOOL)useDefault Title:(NSString *)title LeftBtnTitle:(NSString *)leftBtnTitle RightBtnTitle:(NSString *)rightBtnTitle{
    self= useDefault ? [super initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width, navBarHeight)] : [super init] ;
    
    if (self) {
        //标题，这里用items数组添加
        self.titleLabe=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenBoundsSize.width,navBarHeight)];
        _titleLabe.textColor=[UIColor whiteColor];
        [_titleLabe setBackgroundColor:[UIColor clearColor]];
        [_titleLabe setFont:[UIFont systemFontOfSize:20.0]];
        [_titleLabe setTextAlignment:NSTextAlignmentCenter];
        _titleLabe.text=title;                                                      //
        
        UINavigationItem *item = [[UINavigationItem alloc] init];
        item.titleView=_titleLabe;
        [_titleLabe release];
        NSArray *items = [[NSArray alloc]initWithObjects:item,nil];
        [item release];
        [self setItems:items];
        [items release];

        if (leftBtnTitle) {
            self.leftBarButton=[[UIButton alloc] initWithFrame:CGRectMake(263, 6, 52, 28)];
            [_leftBarButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barItem_nor"]]];
            _leftBarButton.titleLabel.font=[UIFont systemFontOfSize:12.0];
            [_leftBarButton setTitle:leftBtnTitle forState:UIControlStateNormal];       //
            [self addSubview:_leftBarButton];
            [_leftBarButton release];
        }
        if (rightBtnTitle) {
            self.rightBarButton=[[UIButton alloc] initWithFrame:CGRectMake(6, 6, 52, 28)];
            [_rightBarButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barItem_nor"]]];
            [_rightBarButton setTitle:rightBtnTitle forState:UIControlStateNormal];     //
            _rightBarButton.titleLabel.font=[UIFont systemFontOfSize:12.0];
            [self addSubview:_rightBarButton];
            [_rightBarButton release];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"navBg"] drawInRect:rect];
}
-(void) dealloc{
    RELEASE_SAFELY(_leftBarButton)
    RELEASE_SAFELY(_rightBarButton)
    RELEASE_SAFELY(_titleLabe)
    [super dealloc];
}

@end














