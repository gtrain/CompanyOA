//
//  TargetsDataObj.m
//  OA_TGNET
//
//  Created by yzq on 13-7-16.
//  Copyright (c) 2013年 yzq. All rights reserved.
//

#import "TargetsDataObj.h"

@implementation TargetsDataObj

+(TargetsDataObj *) targetsWithDictionary:(NSDictionary *)dataDictionary{
    return [[[self alloc] initWithDictionary:dataDictionary] autorelease];
}

-(id) initWithDictionary:(NSDictionary *)dataDictionary{
    self=[super init];
    if (self) {
        self.logID=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_logID]];                   //[NSString stringWithFormat:@"%@",]
        self.tarAffectUser=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarAffectUser]];
        self.tarContent=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarContent]];
        self.tarCorper=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarCorper]];
        self.tarCostTime=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarCostTime]];   //server是 nsnumber 型的
        self.tarFinishState=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarFinishState]];
        self.tarID=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarID]];
        self.tarMayCostTime=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarMayCostTime]];
        self.tarProgress=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarProgress]];
        self.tarType=[NSString stringWithFormat:@"%@",[dataDictionary objectForKey:KEY_tarType]];
    }
    return self;
}

-(NSDictionary *) jsonDictionary{
    //NSMutableDictionary *jsonDic=[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    NSMutableDictionary *jsonDic=[NSMutableDictionary dictionaryWithCapacity:0];
    _logID          ? [jsonDic setValue:_logID forKey:KEY_logID]:nil;
    _tarAffectUser  ? [jsonDic setValue:_tarAffectUser forKey:KEY_tarAffectUser]:nil;
    _tarContent     ? [jsonDic setValue:_tarContent forKey:KEY_tarContent]:nil;
    _tarCorper      ? [jsonDic setValue:_tarCorper forKey:KEY_tarCorper]:nil;
    _tarCostTime    ? [jsonDic setValue:_tarCostTime forKey:KEY_tarCostTime]:nil;
    _tarFinishState ? [jsonDic setValue:_tarFinishState forKey:KEY_tarFinishState]:nil;
    _tarID          ? [jsonDic setValue:_tarID forKey:KEY_tarID]:nil;
    _tarMayCostTime ? [jsonDic setValue:_tarMayCostTime forKey:KEY_tarMayCostTime]:nil;
    _tarProgress    ? [jsonDic setValue:_tarProgress forKey:KEY_tarProgress]:nil;
    _tarType        ? [jsonDic setValue:_tarType forKey:KEY_tarType]:nil;
    return jsonDic;
}

-(NSString *) workTypeName{
    return [self translateWorkTypeWithInt:self.tarType.integerValue];
}

//转换显示工作类型
-(NSString *)translateWorkTypeWithInt:(NSInteger) type{
    NSString *typeString=nil;
    switch (type) {
        case 1:
            typeString=@"常规工作:";
            break;
        case 2:
            typeString=@"微创新工作:";
            break;
        case 3:
            typeString=@"临时工作:";
            break;
        case 4:
            typeString=@"常规工作:";
            break;
        case 5:
            typeString=@"微创新工作:";
            break;
        default:
            break;
    }
    return typeString;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_logID forKey:KEY_logID];
    [aCoder encodeObject:_tarAffectUser forKey:KEY_tarAffectUser];
    [aCoder encodeObject:_tarContent forKey:KEY_tarContent];
    [aCoder encodeObject:_tarCorper forKey:KEY_tarCorper];
    [aCoder encodeObject:_tarCostTime forKey:KEY_tarCostTime];
    [aCoder encodeObject:_tarFinishState forKey:KEY_tarFinishState];
    [aCoder encodeObject:_tarID forKey:KEY_tarID];
    [aCoder encodeObject:_tarMayCostTime forKey:KEY_tarMayCostTime];
    [aCoder encodeObject:_tarProgress forKey:KEY_tarProgress];
    [aCoder encodeObject:_tarType forKey:KEY_tarType];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.logID=[aDecoder decodeObjectForKey:KEY_logID];             
        self.tarAffectUser=[aDecoder decodeObjectForKey:KEY_tarAffectUser];
        self.tarContent=[aDecoder decodeObjectForKey:KEY_tarContent]; 
        self.tarCorper=[aDecoder decodeObjectForKey:KEY_tarCorper];  
        self.tarCostTime=[aDecoder decodeObjectForKey:KEY_tarCostTime];   
        self.tarFinishState=[aDecoder decodeObjectForKey:KEY_tarFinishState];     
        self.tarID=[aDecoder decodeObjectForKey:KEY_tarID];    
        self.tarMayCostTime=[aDecoder decodeObjectForKey:KEY_tarMayCostTime];    
        self.tarProgress=[aDecoder decodeObjectForKey:KEY_tarProgress];  
        self.tarType=[aDecoder decodeObjectForKey:KEY_tarType];
    }
    return self;
}



-(void) dealloc{
    self.logID=nil;
    self.tarAffectUser=nil;
    self.tarContent=nil;
    self.tarCorper=nil;
    self.tarCostTime=nil;
    self.tarFinishState=nil;
    self.tarID=nil;
    self.tarMayCostTime=nil;
    self.tarProgress=nil;
    self.tarType=nil;
    [super dealloc];
}

@end