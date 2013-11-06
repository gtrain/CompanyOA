//
//  LogDataOjb.m
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-26.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "LogDataOjb.h"
#import "TargetsDataObj.h"

@implementation LogDataOjb

+(LogDataOjb *) logWithDictionary:(NSDictionary *)dataDictionary{
    return [[[self alloc] initWithDictionary:dataDictionary] autorelease];
}

-(id) initWithDictionary:(NSDictionary *)dataDictionary{
    self=[super init];
    if (self) {
        self.logID=[dataDictionary objectForKey:KEY_logID];
        self.logPubDate=[dataDictionary objectForKey:KEY_logPubDate];

        self.userFaceString=[dataDictionary objectForKey:KEY_userFace];
        self.userName=[dataDictionary objectForKey:KEY_userName];
        self.depName=[dataDictionary objectForKey:KEY_depName];
        self.feeling=[dataDictionary objectForKey:KEY_logFeelings];
        self.replyArray=[dataDictionary objectForKey:KEY_Reply];
        
        [self sortTargets:[dataDictionary objectForKey:KEY_Targets]];
    }
    return self;
}

-(void) sortTargets:(NSArray *)targetsArray{
    if (targetsArray) {
        self.todayTargetsArray=[NSMutableArray arrayWithCapacity:0];
        self.tomorrowTargetsArray=[NSMutableArray arrayWithCapacity:0];
        
        for (int i=0; i<targetsArray.count; i++) {
            NSDictionary *targetDic=[targetsArray objectAtIndex:i];
            NSInteger tarType=[(NSString *)[targetDic objectForKey:KEY_tarType] intValue];
            if (tarType<=3) {
                [_todayTargetsArray addObject:[TargetsDataObj targetsWithDictionary:targetDic]];
            }else{
                [_tomorrowTargetsArray addObject:[TargetsDataObj targetsWithDictionary:targetDic]];
            }
        }
    }
}

-(void) dealloc{
    self.logID=nil;
    self.logPubDate=nil;
//    self.targetsArray=nil;    
    self.userFaceString=nil;
    self.userName=nil;
    self.depName=nil;
    self.todayTargetsArray=nil;
    self.tomorrowTargetsArray=nil;
    self.feeling=nil;
    self.replyArray=nil;

    [super dealloc];
}

@end
