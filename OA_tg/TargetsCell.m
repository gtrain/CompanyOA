//
//  TargetsCell.m
//  OA_TGNET
//
//  Created by yzq on 13-7-24.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "TargetsCell.h"

@implementation TargetsCell

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

    // Configure the view for the selected state
}

- (void)dealloc {
    [_tarContentLabel release];
    [_tarMayCostTimeLabel release];
    [_tarCorperLabel release];
    [super dealloc];
}
@end
