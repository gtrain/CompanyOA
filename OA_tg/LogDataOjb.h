//
//  LogDataOjb.h
//  OA_TGNET
//
//  Created by YANGZQ on 13-7-26.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KEY_logID          @"logID"
#define KEY_logPubDate     @"logPubDate"

#define KEY_userFace       @"userFace"
#define KEY_userName       @"userName"
#define KEY_depName        @"depName"

#define KEY_Targets        @"Targets"
#define KEY_logFeelings    @"logFeelings"

#define KEY_Reply          @"Reply"
#define KEY_content        @"content"   //提交回复的key

@interface LogDataOjb : NSObject
@property (nonatomic,strong) NSString *logID;         
@property (nonatomic,strong) NSString *logPubDate;
//@property (nonatomic,strong) NSMutableArray *targetsArray;          //工作数组

@property (nonatomic,strong) NSString *userFaceString;  //头像链接
@property (nonatomic,strong) UIImage *userFaceIMG;      //头像

@property (nonatomic,strong) NSString *userName;        //用户名
@property (nonatomic,strong) NSString *depName;         //部门

@property (nonatomic,strong) NSMutableArray *todayTargetsArray;     //今日的工作
@property (nonatomic,strong) NSMutableArray *tomorrowTargetsArray;  //明天的工作
@property (nonatomic,strong) NSString *feeling;         //日感想

@property (nonatomic,strong) NSMutableArray *replyArray;//点评数组


+(LogDataOjb *) logWithDictionary:(NSDictionary *)dataDictionary;
@end


/*
“logID”:6739,
"logPubDate":"2013/5/8 17:42:24",
"logFeelings":"11111",
"depName":"开发部",
"userName":"简锡敏",
"userFace":"/Images/userFace/2012/2/jianxm_164711.jpg",
"Targets":[
{"tarID":"127068",
    "tarType":"4",
    "logID":"6739",
 
    "tarContent":"明日常规工作内容",
    "tarProgress":"10",
    
    "tarMayCostTime":"3",
    "tarCostTime":"1",
    "tarAffectUser":"",
    "tarCorper":"协作人",
    "tarFinishState":""
},
{
    "tarID":"127064",
    "tarType":"1",
    "logID":"6739",
    "tarContent":"今日常规工作内容",
    "tarProgress":"50",
    "tarMayCostTime":"3",
    "tarCostTime":"4",
    "tarAffectUser":"影响人",
    "tarCorper":"",
    "tarFinishState":"工作详细说明"
}
           ]
“Reply”:[
{“replyID”:28651,
    “logID”:6749,
    “replyPubUser”:”简锡敏”,
    “replyPubDate”:”2013/5/21 14:50:49”,
    “replyContent”:”我来评论了”
},
{“replyID”:28652,
    “logID”:6749,
    “replyPubUser”:”刘波”,
    “replyPubDate”:”2013/5/21 14:58:49”,
    “replyContent”:”我也来评论了”
}
*/