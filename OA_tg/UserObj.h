//
//  UserObj.h
//  OA_TGNET
//
//  Created by yzq on 13-7-20.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_userNo          @"userNo"
#define KEY_userName        @"userName"
#define KEY_userPassword    @"userPassword"
#define KEY_userFace        @"userFace"

#define KEY_userFaceData    @"userFaceData"

#define KEY_oaNotification @"oaNotification"
#define KEY_orderNotification @"orderNotification"
//#define KEY_oaDateSting     @"oaDateSting"
//#define KEY_oaUserInfoDic    @"oaUserInfoDic"
//#define KEY_orderDateSting    @"orderDateSting"
//#define KEY_orderUserInfoDic    @"orderUserInfoDic"

#define KEY_oaDraft         @"oaDraft"

// _mark 设置一个最后保存日期，如果不是今天，则过期的参数设置为 nil  并重新获取

@interface UserObj : NSObject<NSCoding>
//{
//    UILocalNotification *oaNotification;
//    UILocalNotification *orderNotification;
//}
@property (nonatomic,retain) NSString *Lunch;           //是否报午餐，没有的话要进行提示
@property (nonatomic,retain) NSString *Supper;          //是否报晚餐，没有的话要进行提示
@property (nonatomic,retain) NSString *hadOaLog;        //有没有写oa

@property (nonatomic,strong) NSString *userNo;          //用户id .登陆用的
@property (nonatomic,strong) NSString *userName;        //用户名，查询用的
@property (nonatomic,strong) NSString *userPassword;    //密码
@property (nonatomic,strong) NSString *userFace;        //头像链接

@property (nonatomic,strong) NSData *userFaceData;      //头像数据
@property (nonatomic,strong) NSDictionary *oaDraft;     //填写oa的草稿

////OA提醒的信息
//@property (nonatomic,strong) NSString *oaDateSting;
//@property (nonatomic,strong) NSDictionary *oaUserInfoDic;
////order提醒的信息
//@property (nonatomic,strong) NSString *orderDateSting;
//@property (nonatomic,strong) NSDictionary *orderUserInfoDic;

@property (nonatomic,strong) UILocalNotification *oaNotification;     //oa提醒，包含提醒时间；震动，响铃；（string）
@property (nonatomic,strong) UILocalNotification *orderNotification;  //报餐提醒，包含震动，响铃；（string）（系统设置了9点的时间）


//-(void) setNotificationName:(NSString *)name FireDateString:(NSString *)dateString UserInfo:(NSDictionary *)userInfo;
//-(UILocalNotification *) getLocalNotificationName:(NSString *)name;


-(id) initWithDictionary:(NSDictionary *)dataDictionary;
-(NSDictionary *) userDictionary;

@end






//depID = 1;
//isNeedChecked = 1;
//userAddress = "";
//userCompany = "";
//userEmail = "";
//userFace = "/Images/SmallUserFace/2012/2/liub_184629.jpg";
//userID = 7;
//userInfo = "";
//userMobile = 0;
//userName = "\U5218\U6ce2";
//userNo = liub;
//userOrder = 0;
//userPassword = 1234;
//userPower = 2;
//userQQ = 0;
//userSchool = "";
//userTel = 0;
