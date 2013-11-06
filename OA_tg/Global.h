//
//  Header.h
//  OA_TGNET
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#ifndef OA_TGNET_Header_h
#define OA_TGNET_Header_h

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define ScreenBoundsSize [UIScreen mainScreen].bounds.size

#define IosAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define FONT_MARGIN 14.0f

//API URL           接口链接
//#define URL_BASE                    @"http://192.168.0.224:20000/"
#define URL_BASE                    @"http://oa.XXXXXX.cn/"

#define URL_LOGIN_GET_COOKIE        @"OaWebService/OAHandler.ashx?op=Login"
#define URL_USER_POST_ORDER         @"OaWebService/OAHandler.ashx?op=OrderMeal"
#define URL_USER_GET_TARGETS        @"OaWebService/OAHandler.ashx?op=GetYesterdayTargets"
#define URL_USER_GET_ORDERLIST      @"OaWebService/OAHandler.ashx?op=GetMealOrderList"
#define URL_USER_GET_OASTATUSLIST   @"OaWebService/OAHandler.ashx?op=GetLogState"
#define URL_USER_GET_OADETAILLIST   @"OaWebService/OAHandler.ashx?op=GetLogList"
#define URL_USER_POST_OAREPLY       @"OaWebService/OAHandler.ashx?op=EditReply"
#define URL_USER_POST_OAUPDATE      @"OaWebService/OAHandler.ashx?op=EditLog"
#define URL_USER_GET_OAlog          @"OaWebService/OAHandler.ashx?op=IsWriteLog"

//API KEY           服务器接口定义的变量名
#define KEY_USERNO      @"UserNo"
#define KEY_PASSWORD    @"Password"

#define KEY_STATE           @"State"
#define KEY_MSG             @"Msg"
#define KEY_DATA            @"Data"

#define KEY_DEPID           @"depID"
#define KEY_DATE            @"date"
#define KEY_START           @"start"
#define KEY_END             @"end"
#define KEY_PAGE            @"p"

//报餐
#define KEY_UserCount       @"UserCount"
#define KEY_LunchCount      @"LunchCount"
#define KEY_SupperCount     @"SupperCount"
#define KEY_ORDERDETAILS    @"OrderDetails"

#define KEY_userName        @"userName"
#define KEY_Lunch           @"Lunch"
#define KEY_Supper          @"Supper"
#define KEY_OrderTime       @"OrderTime"

#define KEY_UserNameOrNo    @"UserNameOrNo"



//My Dictionary KEY 通知中心userInfo的KEY
//#define KEY_MY_Dic_Failed           @"requestFailed"
#define KEY_MY_Dic_LoginResult      @"loginResultDic"
#define KEY_MY_Arr_UserCookies      @"userCookiesArray"
#define KEY_MY_Dic_OrderResult      @"orderResultDic"
#define KEY_MY_Dic_TargetsResult    @"targetsResultDic"
#define KEY_MY_Dic_OrderList        @"OrderListDic"
#define KEY_MY_Dic_OrderStatus      @"OrderStatus"
#define KEY_MY_Dic_OAStatusList     @"OrderListDic"
#define KEY_MY_Dic_OADetailList     @"OrderDetailListDic"
#define KEY_MY_Dic_ReplyResult      @"ReplyResult"
#define KEY_MY_Dic_OaUpdateResult   @"oaUpdateResult"
#define KEY_MY_Dic_MyOaDetail       @"myOaDetail"
#define KEY_MY_Dic_OaWriteLog       @"oaWriteLog"


//NOTIFY NAME       通知中心的注册名
#define NOTIFY_LOGINRESULT      @"loginResult"
#define NOTIFY_ORDERRESULT      @"orderResult"
#define NOTIFY_ORDERRESULT_ALERT @"orderResultAlert"
#define NOTIFY_TARGETSRESULT    @"targetsResult"
#define NOTIFY_ORDERLIST        @"orderList"
#define NOTIFY_ORDERSTATUS      @"orderStatus"
#define NOTIFY_OASTATUSLIST     @"OAStatusList"
#define NOTIFY_OADETAILLIST     @"OADetailList"
#define NOTIFY_OADETAILLISTMORE  @"MoreOADetailList"
#define NOTIFY_MYOADETAIL       @"MYOADetail"
#define NOTIFY_REPLYRESULT      @"replyResult"
#define NOTIFY_OAUPDATERESULT   @"OAupdateResult"
#define NOTIFY_OaWriteLog      @"OaWriteLog"
#define NOTIFY_UserAvatar      @"userAvatar"
#define NOTIFY_FinishRefreshCookie      @"FinishRefreshCookie"
#define NOTIFY_MyAvatar      @"myAvatar"

//提醒的定义
#define key_titile @"alertTitle"
#define key_message @"alertMessage"

#define key_voice @"voiceRemind"
#define key_shake @"shakeRemind"

#endif




