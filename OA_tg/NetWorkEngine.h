//
//  NetWorkEngine.h
//  OA_TGNET
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

typedef enum{
    GetUserCookie=0,
    PostOrder,
    PostOrderAlert,
    GetTargets,
    PostOrderList,
    GetOrderList,
    GetUserOrderStatues,
    GetOAStatusList,
    GetOADetailList,
    GetMoreOADetailList,
    PostReply,
    PostOAupdate,
    GetMyOADetail,
    GetOAwriteLog,
    GetUserAvatar,
    GetMyAvatar,
    ReFreshCookie,
} RequestTag;

@interface NetWorkEngine : NSObject<ASIHTTPRequestDelegate>
@property (nonatomic,retain) ASINetworkQueue *networkQueue; // 请求队列

@property (strong, nonatomic) NSHTTPCookie *userCookie;             //用户cookie
@property (strong,nonatomic) NSMutableArray *requestNeedToRestart;  //请求失败的request

@property (strong,nonatomic) NSDate *createdDate;

+(NetWorkEngine *) shareNetWorkEngine;  //单例
+(NSDictionary *) synthesisCookiePropertiesWithValue:(id)value name:(NSString *)key;

-(void) getNewCookie;

-(void) addRequestWithUrlString:(NSString *)urlString Method:(NSString *)requestMethod Tag:(RequestTag) tag Index:(NSInteger)index;
-(void) addRequestUseCookie:(BOOL)useCookie request:(ASIHTTPRequest *)request method:(NSString *)requestMethod tag:(RequestTag) tag;
-(void) addRequestUseCookie:(BOOL)useCookie parameterDicArray:(NSArray *)parameterArray apiString:(NSString *)api Method:(NSString *)requestMethod Tag:(RequestTag) tag;

@end
