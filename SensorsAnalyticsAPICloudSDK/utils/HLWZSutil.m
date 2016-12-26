//
//  HLWZSutil.m
//  NewLenFen
//
//  Created by BlueApp on 15-10-12.
//  Copyright (c) 2015年 Mch. All rights reserved.
//

#import "HLWZSutil.h"

@implementation HLWZSutil

+ (NSString *)getString:(id)object {
    if (object == [NSNull null] || object == nil) {
        return @"";
    } else {
        return object;
    }
}

+ (NSInteger)getInteger:(id)object {
    if (object == [NSNull null]) {
        return 0;
    } else {
        return [object integerValue];
    }
}

+(NSDictionary *)getdic:(id)object
{
    if (object == [NSNull null] || object == nil) {
        return [NSDictionary dictionary];
    }
    else
    {
        return object;
        
    }
}
+ (NSString *)get:(NSDictionary *)dic key:(NSString *)key {
    if (dic[key]) {
        return dic[key];
    }
    else
    {
        return nil;
    }
}

+ (NSString *)getText:(id)object
{
    if (object == [NSNull null] || object == nil) {
        return @"";
    }
    else
    {
        return object;
    }
}

@end
