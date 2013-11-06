//
//  OaDetailCell.m
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-29.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "OaDetailCell.h"

@implementation OaDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setSelectionStyle:UITableViewCellEditingStyleNone];
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_userAvatarImgView release];
    [_userNameLabel release];
    [_userDepartmentLabel release];
    [_replyCountLabel release];
    [_replyBtn release];
    [super dealloc];
}

@end
