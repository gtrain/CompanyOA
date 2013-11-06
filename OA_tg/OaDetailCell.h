//
//  OaDetailCell.h
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-29.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OaCellHeight        206
#define RightPartX          78
#define RightHeaderHeight   22

#define FONT_SIZE           14.0f
#define CELL_CONTENT_WIDTH  320.0f
#define CELL_CONTENT_MARGIN 8.0f
#define CELL_CONTENT_MINIHEIGHT 44.0f

@interface OaDetailCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *userAvatarImgView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *userDepartmentLabel;
@property (retain, nonatomic) IBOutlet UILabel *replyCountLabel;

@property (retain, nonatomic) IBOutlet UIButton *replyBtn;      //点评按钮

@end
