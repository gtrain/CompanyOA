//
//  UserObj.m
//  OA_TGNET
//
//  Created by yzq on 13-7-20.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "UserObj.h"

@implementation UserObj

//+(UserObj *) userWithDictionary:(NSDictionary *)dataDictionary{
//    return [[[self alloc] initWithDictionary:dataDictionary] autorelease];
//}

-(id) initWithDictionary:(NSDictionary *)dataDictionary{
    self=[super init];
    if (self) {
        self.userNo=[dataDictionary objectForKey:KEY_userNo];
        self.userName=[dataDictionary objectForKey:KEY_userName];
        self.userPassword=[dataDictionary objectForKey:KEY_userPassword];
        self.userFace=[dataDictionary objectForKey:KEY_userFace];
//        self.userFaceData=[dataDictionary objectForKey:KEY_userFaceData];
//        self.oaDraft=[dataDictionary objectForKey:KEY_oaDraft];
    }
    return self;
}

//返回一个精简的用户数组字典
-(NSDictionary *) userDictionary{
    NSMutableDictionary *userDic=[NSMutableDictionary dictionaryWithCapacity:0];
    _userNo    ? [userDic setValue:_userNo forKey:KEY_userNo]:nil;
    _userPassword  ? [userDic setValue:_userPassword forKey:KEY_userPassword]:nil;
    _userFaceData  ? [userDic setValue:_userFaceData forKey:KEY_userFaceData]:nil;
    return userDic;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_userNo forKey:KEY_userNo];
    [aCoder encodeObject:_userName forKey:KEY_userName];
    [aCoder encodeObject:_userPassword forKey:KEY_userPassword];
    [aCoder encodeObject:_userFace forKey:KEY_userFace];
    [aCoder encodeObject:_userFaceData forKey:KEY_userFaceData];

    [aCoder encodeObject:_oaDraft forKey:KEY_oaDraft];
    [aCoder encodeObject:_oaNotification forKey:KEY_oaNotification];
    [aCoder encodeObject:_orderNotification forKey:KEY_orderNotification];
    
//    [aCoder encodeObject:_oaDateSting forKey:KEY_oaDateSting];
//    [aCoder encodeObject:_oaUserInfoDic forKey:KEY_oaUserInfoDic];
//    [aCoder encodeObject:_orderDateSting forKey:KEY_orderDateSting];
//    [aCoder encodeObject:_orderUserInfoDic forKey:KEY_orderUserInfoDic];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.userNo=[aDecoder decodeObjectForKey:KEY_userNo];
        self.userName=[aDecoder decodeObjectForKey:KEY_userName];
        self.userPassword=[aDecoder decodeObjectForKey:KEY_userPassword];
        self.userFace=[aDecoder decodeObjectForKey:KEY_userFace];
        self.userFaceData=[aDecoder decodeObjectForKey:KEY_userFaceData];
        
        self.oaDraft=[aDecoder decodeObjectForKey:KEY_oaDraft];
        self.oaNotification=[aDecoder decodeObjectForKey:KEY_oaNotification];
        self.orderNotification=[aDecoder decodeObjectForKey:KEY_orderNotification];
        
//        self.oaDateSting=[aDecoder decodeObjectForKey:KEY_oaDateSting];
//        self.oaUserInfoDic=[aDecoder decodeObjectForKey:KEY_oaUserInfoDic];
//        self.orderDateSting=[aDecoder decodeObjectForKey:KEY_orderDateSting];
//        self.orderUserInfoDic=[aDecoder decodeObjectForKey:KEY_orderUserInfoDic];
        
    }
    return self;
}



-(void) dealloc{
//    [orderNotification release];
//    [oaNotification release];
    self.oaNotification=nil;
    self.orderNotification=nil;
    self.oaDraft=nil;
    self.userFaceData=nil;
    self.userFace=nil;
    self.userNo=nil;
    self.userName=nil;
    self.userPassword=nil;
    self.Lunch=nil;
    self.Supper=nil;
    self.hadOaLog=nil;
    [super dealloc];
}

@end



//-(void) setNotificationName:(NSString *)name FireDateString:(NSString *)dateString UserInfo:(NSDictionary *)userInfo{
//    if ([name isEqualToString:@"OA"]) {
//        self.oaDateSting=dateString;
//        self.oaUserInfoDic=userInfo;
//    }else if([name isEqualToString:@"ORDER"]){
//        self.orderDateSting=dateString;
//        self.orderUserInfoDic=userInfo;
//    }
//}
//
//-(UILocalNotification *) getLocalNotificationName:(NSString *)name{
//    if ([name isEqualToString:@"OA"]) {
//        if (_oaDateSting) {
//            if (!oaNotification) {
//                oaNotification =[[UILocalNotification alloc] init];
//            }
//            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
//            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            NSDate *oaDate=[dateFormat dateFromString:_oaDateSting];
//            [dateFormat release];
//
//
//            [oaNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//            [oaNotification setSoundName:UILocalNotificationDefaultSoundName];
//            [oaNotification setAlertBody:@"到写日志的时间了."];
//            [oaNotification setUserInfo:_oaUserInfoDic];
//            [oaNotification setFireDate:oaDate];
//        }
//        return oaNotification;
//    }else if([name isEqualToString:@"ORDER"]){
//        if (_orderDateSting) {
//            if (!orderNotification) {
//                orderNotification =[[UILocalNotification alloc] init];
//            }
//            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
//            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            NSDate *orderDate=[dateFormat dateFromString:_orderDateSting];
//            [dateFormat release];
//
//
//            [orderNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//            [orderNotification setSoundName:UILocalNotificationDefaultSoundName];
//            [orderNotification setAlertBody:@"报餐的时间到了."];
//            [orderNotification setUserInfo:_orderUserInfoDic];
//            [orderNotification setFireDate:orderDate];
//        }
//        return orderNotification;
//    }else{
//        return nil;
//    }
//}
