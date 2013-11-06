//
//  TargetsDataObj.h
//  OA_TGNET
//
//  Created by yzq on 13-7-16.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+HXAddtions.h"

//logID = 6846;             //数据id
//tarAffectUser = "";       //影响人，（被协助的那个）
//tarContent = 53123123;    //计划的内容
//tarCorper = "";           //协助人
//tarCostTime = 0;          //实际用时
//tarFinishState = "";      //完成情况
//tarID = 127389;           //计划的id (相当于标题)
//tarMayCostTime = 5;       //可能花费的时间
//tarProgress = 0;          //进度
//tarType = 4;              //类型，可能是常规任务，临时任务，这些
#define KEY_logID           @"logID"
#define KEY_tarAffectUser   @"tarAffectUser"
#define KEY_tarContent      @"tarContent"
#define KEY_tarCorper       @"tarCorper"
#define KEY_tarCostTime     @"tarCostTime"
#define KEY_tarFinishState  @"tarFinishState"
#define KEY_tarID           @"tarID"
#define KEY_tarMayCostTime  @"tarMayCostTime"
#define KEY_tarProgress     @"tarProgress"
#define KEY_tarType         @"tarType"

@interface TargetsDataObj : NSObject<NSCoding>

@property (nonatomic,retain) NSString *logID;
@property (nonatomic,retain) NSString *tarAffectUser;
@property (nonatomic,retain) NSString *tarContent;
@property (nonatomic,retain) NSString *tarCorper;
@property (nonatomic,retain) NSString *tarCostTime;
@property (nonatomic,retain) NSString *tarFinishState;
@property (nonatomic,retain) NSString *tarID;
@property (nonatomic,retain) NSString *tarMayCostTime;
@property (nonatomic,retain) NSString *tarProgress;
@property (nonatomic,retain) NSString *tarType;

+(TargetsDataObj *) targetsWithDictionary:(NSDictionary *)dataDictionary;
-(NSDictionary *) jsonDictionary;
-(NSString *) workTypeName;

@end

typedef void (^AddTargetsBlock)(TargetsDataObj *);                  //添加任务的回调block，回传一个添加对象(类型在对象里面了)
typedef void (^EditTargetsBlock)(NSInteger,TargetsDataObj *,BOOL);  //编辑任务的回调block，回传索引值跟编辑的对象,如果是删除的话，回传一个YES
