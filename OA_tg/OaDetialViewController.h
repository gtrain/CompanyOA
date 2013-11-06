//
//  OaDetialViewController.h
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-30.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogDataOjb.h"
#import "TodayWorkCell.h"
#import "UIKeyboardView.h"
#import "NetWorkEngine.h"
#import "ASIFormDataRequest.h"

@interface OaDetialViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIKeyboardViewDelegate,UITextViewDelegate>{
    BOOL _isShowingActivity;
}
@property (nonatomic,strong) UITableView *oaDetailTable;
@property (nonatomic,strong) LogDataOjb *logObj;

@property (nonatomic) BOOL scrolToReplyList;

-(id) initWithLogObj:(LogDataOjb *)logData;

@end
