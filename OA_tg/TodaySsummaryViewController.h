//
//  TodaySsummaryViewController.h
//  OA_tg
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KxMenu.h"
#import "EGORefreshTableHeaderView.h"
#import "PWLoadMoreTableFooterView.h"

@interface TodaySsummaryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITabBarControllerDelegate,UIScrollViewDelegate,EGORefreshTableHeaderDelegate,PWLoadMoreTableFooterDelegate>{
    BOOL _isReloading;                //是否在刷新中.
    BOOL _isLoadMore;                //是否在刷新中
    
    bool _allLoaded;                //是否没有数据加载了
    NSInteger loadPage;                 //加载更多的时候选择的页数
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    PWLoadMoreTableFooterView *_loadMoreFooterView;
    
    UIView *alphaBgView;        //遮罩层
    UIDatePicker *oaDatePicker;   //时间
    BOOL _isShowingActivity;
    
    CABasicAnimation *animation;
}

//统计按钮呵刷新按钮
- (IBAction)OAStatistics:(UIButton *)sender;
- (IBAction)refreshBtnPress:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIImageView *refreshImgView;

//部门下拉按钮
@property (retain, nonatomic) IBOutlet UIButton *departMentBtn;
- (IBAction)departmentMenu:(UIButton *)sender;

//日期选择
@property (retain, nonatomic) IBOutlet UIButton *dateBtn;
- (IBAction)dateBtnPress:(UIButton *)sender;
//@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;


//表格，数据源
@property (strong,nonatomic) UITableView *oaDetailListTable;
@property (strong,nonatomic) NSMutableArray *oaDetailArray;

@end
