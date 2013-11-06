//
//  TodayWorkCell.m
//  OA_TGNET
//
//  Created by yzq on 13-7-23.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "TodayWorkCell.h"

@implementation TodayWorkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_tarContentLabel release];
    [_tarMayCostTimeLabel release];
    [_tarCostTimeLabel release];
    [_tarAffectUserLabel release];
    [_tarCorperLabel release];
    [_tarProgressLabel release];
    [_tarFinishStateTextView release];
    [_tarTypeLabel release];
    [super dealloc];
}

@end
