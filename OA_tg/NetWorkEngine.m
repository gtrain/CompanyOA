//
//  NetWorkEngine.m
//  OA_TGNET
//
//  Created by yzq on 13-7-11.
//  Copyright (c) 2013年 yzq. All rights reserved.
//
/**
 * @description API的请求接口，方法中自动完成token信息的拼接
 * @param url: 请求的接口
 * @param params: 请求的参数，如发微博所带的文字内容等
 * @param httpMethod: http类型，GET或POST
 * @param _delegate: 处理请求结果的回调的对象，RequestDelegate类
 * @return 完成实际请求操作的Request对象
 */

#import "NetWorkEngine.h"
#import "AppDelegate.h"

//_mark release 检测内存泄露呀呀呀

@implementation NetWorkEngine
static NetWorkEngine *shareNetWorkEngine=nil;

//单例
+(NetWorkEngine *) shareNetWorkEngine{
    //@synchronized 限制在一个线程里面运行
    @synchronized(self){
        if (!shareNetWorkEngine) {
            shareNetWorkEngine=[[self alloc] init];
        }
    }
    return shareNetWorkEngine;
}
+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (!shareNetWorkEngine) {
            shareNetWorkEngine =[super allocWithZone:zone];
            return shareNetWorkEngine;
        }
    }
    return nil;
}

//合成cookie参数
+(NSDictionary *) synthesisCookiePropertiesWithValue:(id)value name:(NSString *)key{
    NSDictionary *propertiesDic=[[[NSMutableDictionary alloc] init] autorelease];
    [propertiesDic setValue:value forKey:NSHTTPCookieValue];
    [propertiesDic setValue:key forKey:NSHTTPCookieName];
    [propertiesDic setValue:@"tgnet.cn" forKey:NSHTTPCookieDomain];
    [propertiesDic setValue:@"/" forKey:NSHTTPCookiePath];
    return propertiesDic;
}

-(id) init{
    self=[super init];
    if (self) {
//        [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES]; //控制非wifi网络
        self.networkQueue=[ASINetworkQueue queue];          //获得网络队列实例
        _networkQueue.showAccurateProgress=YES;             //精确的进度
        _networkQueue.shouldCancelAllRequestsOnFailure=NO;
        
        //队列要处理  ASIHTTPRequest的Delegate
        //_networkQueue.downloadProgressDelegate=self;      //下载进程的代理
        [_networkQueue setDelegate:self];                //代理
        
        _networkQueue.requestDidStartSelector=@selector(requestStartedByQueue:);
        //        self.networkQueue.requestDidReceiveResponseHeadersSelector=@selector(requestReceivedResponseHeaders:);
        _networkQueue.requestDidFinishSelector=@selector(requestFinishedByQueue:);
        _networkQueue.requestDidFailSelector=@selector(requestFailedByQueue:);
        //        _networkQueue.queueDidFinishSelector=@selector(queueFinished:);
        
        //设置完成，启动队列
        [_networkQueue go];
    }
    return self;
}

-(void) dealloc{
    [_userCookie release];
    self.userCookie=nil;

    self.requestNeedToRestart=nil;
    
    self.createdDate=nil;
    self.networkQueue=nil;
    [super dealloc];
}


//获取图片资源，启用缓存功能 并保存本地CacheStorage
-(void) addRequestWithUrlString:(NSString *)urlString Method:(NSString *)requestMethod Tag:(RequestTag) tag Index:(NSInteger)index{
    //根据基础地址跟API合成链接，创建请求
    if (!urlString) {
        return;
    }
    
    NSString *fullUrlString = [NSString stringWithFormat:@"%@%@",URL_BASE,urlString];
    NSURL *url=[NSURL URLWithString:fullUrlString];
    
    NSNumber *indexNum=[NSNumber numberWithInteger:index];
    NSDictionary *userInfoDic=[NSDictionary dictionaryWithObject:indexNum forKey:@"index"];
    
    ASIHTTPRequest *request=[[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
//    [request setAllowCompressedResponse:NO];
//    [request setShouldWaitToInflateCompressedResponses:NO];
    
    [request setRequestMethod:requestMethod];
    [request setTag:tag];
    [request setUserInfo:userInfoDic];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    //缓存
    
    [self.networkQueue addOperation:request];
}

//自己创建请求，用于post方法
-(void) addRequestUseCookie:(BOOL)useCookie request:(ASIHTTPRequest *)request method:(NSString *)requestMethod tag:(RequestTag) tag{
    request.tag=tag;
    [request setRequestMethod:requestMethod];
    
    //取本地的cookies
    if (useCookie) {
//        if (!_userCookie) {
//            [self postNotificationWithRequest:request requestFinish:NO errorMsg:@"用户未登录"];  //没有可用的cookie
//            return;
//        }
          if (!_userCookie || [self isExpires]) {
            if (!_requestNeedToRestart) {
                self.requestNeedToRestart =[[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            }
            [_requestNeedToRestart addObject:request];
//            Log(@"未处理的request，保存起来");
            [self getNewCookie];
            return;
        }
        else{
            [request setRequestCookies:[NSMutableArray arrayWithObject:_userCookie]];
        }
    }
    
    [self.networkQueue addOperation:request];
}

-(void) addRequestUseCookie:(BOOL)useCookie parameterDicArray:(NSArray *)parameterArray apiString:(NSString *)api Method:(NSString *)requestMethod Tag:(RequestTag) tag{
    
    NSMutableArray *cookiesArray=[NSMutableArray arrayWithCapacity:0];
    //如果有参数，添加参数
    if (parameterArray && parameterArray.count !=0) {
        for (NSDictionary *dic in parameterArray) {
            NSHTTPCookie *cookie=[[NSHTTPCookie alloc] initWithProperties:dic];
            if (cookie) {   //数组不能添加空的元素，这里要注意了
                [cookiesArray addObject:cookie];
                [cookie release];
            }
        }
    }
    //根据基础地址跟API合成链接，创建请求
    NSString *fullUrlString = [URL_BASE stringByAppendingString:api];
    NSURL *url=[NSURL URLWithString:fullUrlString];
    
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:url];
//    [request setShouldWaitToInflateCompressedResponses:NO];
//    [request setAllowCompressedResponse:NO];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:cookiesArray];
    [request setRequestMethod:requestMethod];
    [request setTag:tag];
    
    //取本地的cookies
    if (useCookie) {
        //判断cookie是否存在，是否过期
        if (!_userCookie || [self isExpires]) {
            if (!_requestNeedToRestart) {
                self.requestNeedToRestart =[[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            }
            [_requestNeedToRestart addObject:request];
            [request release];
//            Log(@"未处理的request，保存起来");
            [self getNewCookie];
            return;
        }
        else{
            [request.requestCookies addObject:_userCookie];
        }
    }
    
    [self.networkQueue addOperation:request];
    [request release];
}

-(void) getNewCookie{
//    Log(@"自动刷新cookies");
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *userNameDic=[NetWorkEngine synthesisCookiePropertiesWithValue:delegate.currentUser.userNo name:KEY_USERNO];
    NSDictionary *userPasswordDic=[NetWorkEngine synthesisCookiePropertiesWithValue:delegate.currentUser.userPassword name:KEY_PASSWORD];
    NSArray *infoArray=[NSArray arrayWithObjects:userNameDic,userPasswordDic,nil];
    [self addRequestUseCookie:NO parameterDicArray:infoArray apiString:URL_LOGIN_GET_COOKIE Method:@"GET" Tag:ReFreshCookie];
}

-(BOOL) isExpires{
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMddHHmmss"];
    NSInteger currentDateNum = [[dateFormatter stringFromDate:currentDate] integerValue];
    NSInteger createdDateNum = [[dateFormatter stringFromDate:_createdDate] integerValue];
    [dateFormatter release];
    if (currentDateNum-createdDateNum > 1900) {
        return YES;
    }else{
        return NO;
    }
}
//_mark 处理网络错误，认证错误，吧错误建成一张表吧。不在这里处理，不管是正确还是错误，返回到发起者去
// 这里要保证传过去的是 json ，error是服务器的error。  网络错误在这里进行处理，或者打包传过去？
//_makr handel函数有的事需要判断是否存在试图中，要是已经离开主视图的就不进行处理了！

//对request的返回结果进行处理，并发送通知
-(void) postNotificationWithRequest:(ASIHTTPRequest *)request requestFinish:(BOOL)finish errorMsg:(NSString *)errorSting{
    //头像请求，特殊处理
    if(request.tag==GetUserAvatar){
        NSNumber *indexNum=[request.userInfo objectForKey:@"index"];
        NSDictionary *userAvatarDic=[NSDictionary dictionaryWithObjectsAndKeys:request.responseData,KEY_DATA,indexNum,@"index",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UserAvatar object:nil userInfo:userAvatarDic];
        return;
    }
    if (request.tag==GetMyAvatar) {
        NSDictionary *userAvatarDic=[NSDictionary dictionaryWithObjectsAndKeys:request.responseData,KEY_DATA,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MyAvatar object:nil userInfo:userAvatarDic];
        return;
    }
    
    //请求成功的是requestResult一个json转得dictionary,请求失败则是一个包含错误信息的string, handle函数需要对其进行判断
    id requestResult=nil;
    if (finish) {
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *bufStr = [[[NSString alloc] initWithData:request.responseData encoding:encoding] autorelease];
        NSData *bufData=[bufStr dataUsingEncoding:NSUTF8StringEncoding];
        if (bufData) {
            NSError *error=nil;
            requestResult = [NSJSONSerialization JSONObjectWithData:bufData  options:NSJSONReadingMutableLeaves error:&error];
            if (error) {
                error=nil;
                bufStr=[bufStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                bufData=[bufStr dataUsingEncoding:NSUTF8StringEncoding];
                requestResult = [NSJSONSerialization JSONObjectWithData:bufData  options:NSJSONReadingMutableLeaves error:&error];
                if (error) {
                    requestResult=@"不正确的UTF8字符";
                }
            }
        }else{
            requestResult=@"没数据或者数据转换失败";
        }
        
    }else{
        requestResult=errorSting;
        //requestResult=request. error ??; 如果有自定义的error， 否则显示request的error 这样？
    }
//    这里是判断登陆结果是不是显示未登陆，但是request已经过时了，所以不能这样处理
//    if (request.tag!=ReFreshCookie && request.tag!=GetUserCookie && [requestResult isKindOfClass:[NSDictionary class]]) {
//        NSString *state=[NSString stringWithFormat:@"%@",[requestResult objectForKey:KEY_STATE]];
//        if ( [state isEqualToString:@"1"] ) {
//
//            requestResult=@"请重试.";
//            if (!_requestNeedToRestart) {
//                self.requestNeedToRestart=[[NSMutableArray alloc] initWithCapacity:0];
//            }
//            
//            [_requestNeedToRestart addObject:request];
//            return;
//        }
//    }
    
    //开始按照tag分发
    if (request.tag==GetUserCookie) {
        //登陆结果，如果成功是包含cookie的，需要区分
        NSDictionary *loginResultDic=nil;
        if (request.responseCookies.count==0) {
            loginResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_LoginResult,nil];
        }else{
            loginResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_LoginResult,
                            request.responseCookies,KEY_MY_Arr_UserCookies,nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOGINRESULT object:nil userInfo:loginResultDic];
    }
    //刷新Cookie,特殊处理
    else if (request.tag==ReFreshCookie) {
        [self setCreatedDate:[NSDate date]];
        //更新cookie的创建时间；
        if (request.responseCookies && request.responseCookies.count!=0) {
            NSHTTPCookie *cookie=[request.responseCookies objectAtIndex:0];
            [self setUserCookie:cookie];
        }
        //刷新cookies后，重新请求失败的request
        if (_requestNeedToRestart && _requestNeedToRestart.count>0) {
            for (ASIHTTPRequest *reRequest in _requestNeedToRestart) {
                if (_userCookie) {
                    if (reRequest.requestCookies) {
                        [reRequest.requestCookies addObject:_userCookie];
                    }else{
                        reRequest.requestCookies=[NSMutableArray arrayWithObject:_userCookie];
                    }
                }
                [reRequest setDelegate:self];
                [reRequest setDidFinishSelector:@selector(requestFinished:)];
                [reRequest setDidFailSelector:@selector(requestFailed:)];
                //requestFailed
                [reRequest startAsynchronous];
                //[self.networkQueue addOperation:request];
            }
            self.requestNeedToRestart=nil;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_FinishRefreshCookie object:nil userInfo:nil];
        //这里是指保存用户信息后，只需要后台刷新cookie，然后再发送头像请求
        return;
    }
    else if(request.tag==PostOrder){
        //订餐结果
        NSDictionary *orderResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OrderResult,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ORDERRESULT object:nil userInfo:orderResultDic];
    }
    else if(request.tag==PostOrderAlert){
        NSDictionary *orderResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OrderResult,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ORDERRESULT_ALERT object:nil userInfo:orderResultDic];
    }
    else if(request.tag==GetTargets){
        //昨天计划
        NSDictionary *targetsResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_TargetsResult,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TARGETSRESULT object:nil userInfo:targetsResultDic];
    }
    //报餐统计列表
    else if(request.tag==GetOrderList){
        NSDictionary *orderListDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OrderList,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ORDERLIST object:nil userInfo:orderListDic];
    }
    //我的报餐信息
    else if(request.tag==GetUserOrderStatues){
        NSDictionary *OrderStatusDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OrderStatus,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ORDERSTATUS object:nil userInfo:OrderStatusDic];
    }
    //OA统计
    else if(request.tag==GetOAStatusList){
        NSDictionary *OAListDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OAStatusList,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_OASTATUSLIST object:nil userInfo:OAListDic];
    }
    //OA结果查询
    else if(request.tag==GetOADetailList){
        NSDictionary *OADetailListDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OADetailList,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_OADETAILLIST object:nil userInfo:OADetailListDic];
    }
    //OA结果加载更多
    else if(request.tag==GetMoreOADetailList){
        NSDictionary *moreOADetailListDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OADetailList,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_OADETAILLISTMORE object:nil userInfo:moreOADetailListDic];
    }
    
    //点评
    else if(request.tag==PostReply){
        NSDictionary *replyResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_ReplyResult,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REPLYRESULT object:nil userInfo:replyResultDic];
    }     
    //更新日志
    else if(request.tag==PostOAupdate){
        NSDictionary *oaUpdateResultDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OaUpdateResult,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_OAUPDATERESULT object:nil userInfo:oaUpdateResultDic];
    }
    //获取个人oa
    else if(request.tag==GetMyOADetail){
        NSDictionary *myOaDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_MyOaDetail,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MYOADETAIL object:nil userInfo:myOaDic];
    }
    //获取oa填写情况
    else if(request.tag==GetOAwriteLog){
        NSDictionary *oaWriteDic=[NSDictionary dictionaryWithObjectsAndKeys:requestResult,KEY_MY_Dic_OaWriteLog,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_OaWriteLog object:nil userInfo:oaWriteDic];
    }
}



#pragma mark --------NETWORKQUEUE---------
-(void) requestStartedByQueue:(ASIHTTPRequest *)request{
    //Log(@"发起请求>>  %@",request.url);
}
-(void) requestFinishedByQueue:(ASIHTTPRequest *)request{
    [self postNotificationWithRequest:request requestFinish:YES errorMsg:nil];
}
-(void) requestFailedByQueue:(ASIHTTPRequest *) request{
    [self postNotificationWithRequest:request requestFinish:NO errorMsg:@"网络请求失败"];
}
//-(void) queueFinished:(ASIHTTPRequest *) request{
//}

#pragma mark --------Asynchronous Delegate---------

//- (void)requestStarted:(ASIHTTPRequest *)request;
//- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
//- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL;
//- (void)requestRedirected:(ASIHTTPRequest *)request;

- (void)requestFinished:(ASIHTTPRequest *)request{
    [self postNotificationWithRequest:request requestFinish:YES errorMsg:nil];
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    [self postNotificationWithRequest:request requestFinish:NO errorMsg:@"网络请求失败"];
    //NSError *error = [request error];
}


@end
