//
//  SensorsAnalyticsAPICloudSDK.m
//  SensorsAnalyticsAPICloudSDK
//
//  Created by 肖彦敏 on 2016/12/1.
//  Copyright © 2015－2018 Sensors Data Inc. All rights reserved.
//

#import "SensorsAnalyticsAPICloudSDK.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"
#import "SensorsAnalyticsSDK.h"

@interface SensorsAnalyticsAPICloudSDK (){
    NSInteger _cbId;
}
@end

@implementation SensorsAnalyticsAPICloudSDK

+ (void)launch{
    @try {
        NSDictionary *feature = [UZAppDelegate.appDelegate getFeatureByName:@"SensorsAnalyticsAPICloudSDK"];
        NSString *serverURL = [feature stringValueForKey:@"serverURL" defaultValue:nil];
        NSString *debugMode = [feature stringValueForKey:@"debugMode" defaultValue:nil];
        BOOL enableLog = [feature boolValueForKey:@"enableLog" defaultValue:NO];
        BOOL enableAutoTrack = [feature boolValueForKey:@"enableAutoTrack" defaultValue:NO];
        NSString *downloadChannel = [feature stringValueForKey:@"downloadChannel" defaultValue:nil];
        //校验debugMode
        SensorsAnalyticsDebugMode mode;
        if (debugMode.length > 0) {
           
                if ([debugMode isEqualToString:@"debugOnly"]) {
                    mode = SensorsAnalyticsDebugOnly;
                }else if ([debugMode isEqualToString:@"debugAndTrack"]){
                    mode = SensorsAnalyticsDebugAndTrack;
                }else  if ([debugMode isEqualToString:@"debugOff"]) {
                    mode = SensorsAnalyticsDebugOff;
                }else{
                    [SensorsAnalyticsAPICloudSDK showErrorMessage:@"您传入的debugMode有误"];
                    return;
                }
        }else{
            NSLog(@"debugMode模式传入错误，取值只能为：debugOff、debugOnly、debugAndTrack，请检查传入的模式");
            return;
        }
        //校验serverURL
        if (serverURL.length > 0) {
            [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL andDebugMode:mode];
            if (downloadChannel.length > 0) {
                [SensorsAnalyticsSDK.sharedInstance trackInstallation:@"AppInstall" withProperties:@{@"downloadChannel":downloadChannel}];
            }
            [SensorsAnalyticsSDK.sharedInstance enableLog:enableLog];
            if (enableAutoTrack) {
                [SensorsAnalyticsSDK.sharedInstance enableAutoTrack:SensorsAnalyticsEventTypeAppStart|SensorsAnalyticsEventTypeAppEnd];
            }
        }else {
            if (![debugMode isEqualToString:@"debugOff"]) {
                [SensorsAnalyticsAPICloudSDK showErrorMessage:@"serverURL(收集事件的服务地址)为空,请检查传入值"];
            }else{
                NSLog(@"serverURL(收集事件的服务地址)为空,请检查传入值");
            }
            return;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}
- (id)initWithUZWebView:(id)webView{
    if (self = [super initWithUZWebView:webView]) {
        
    }
    return self;
}
- (void)dispose{
    //do clean
}

-(void)login:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *loginId = [paramsDict stringValueForKey:@"loginId" defaultValue:nil];
        if (loginId.length > 0){
            
            [SensorsAnalyticsSDK.sharedInstance login:loginId];
        }else{
            NSLog(@"loginId（登录ID)为空");
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
-(void)track:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *event = [paramsDict stringValueForKey:@"event" defaultValue:nil];
        NSDictionary *properties = [paramsDict dictValueForKey:@"properties" defaultValue:nil];

        if (event.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance track:event withProperties:properties];
        }else{
            NSLog(@"event(事件名)为空，请检查传入值");
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
-(void)flush:(NSDictionary *)paramsDict{
    @try {
        [SensorsAnalyticsSDK.sharedInstance flush];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
    }
}

-(void)trackInstallation:(NSDictionary *)paramsDict {
    
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *event = @"AppInstall";
        NSDictionary *properties = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        if (event.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance trackInstallation:event withProperties:properties];
        }else{
            NSLog(@"event(事件名)为空，请检查传入值");
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

-(void)trackTimerStart:(NSDictionary *)paramsDict {
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *event = [paramsDict stringValueForKey:@"event" defaultValue:nil];
        if (event.length) {
            [SensorsAnalyticsSDK.sharedInstance trackTimerStart:event];
        }
    } @catch (NSException *exception) {
    }
}
-(void)trackTimerEnd:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];

    @try {
        NSString *event = [paramsDict stringValueForKey:@"event" defaultValue:nil];
        NSDictionary *properties = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        if (event.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance trackTimerEnd:event withProperties:properties];
        }
    } @catch (NSException *exception) {
    }
}
-(void)clearTrackTimer:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        [SensorsAnalyticsSDK.sharedInstance clearTrackTimer];
    } @catch (NSException *exception) {
        
    }
}

-(void)logout:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        [SensorsAnalyticsSDK.sharedInstance logout];
    } @catch (NSException *exception) {
        
    }
}

-(void)profileSet:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSDictionary *profile = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        if (profile.count) {
            [SensorsAnalyticsSDK.sharedInstance set:profile];
        }
    } @catch (NSException *exception) {

    }
}

-(void)profileSetOnce:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSDictionary *profile = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        if (profile.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance setOnce:profile];
        }
    } @catch (NSException *exception) {
        
    }
}
-(void)profileUnset:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *unsetProfileKey = [paramsDict stringValueForKey:@"property" defaultValue:nil];
        if (unsetProfileKey.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance unset:unsetProfileKey];
        }
    } @catch (NSException *exception) {
        
    }
}
-(void)profileIncrement:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSDictionary *increment = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        if (increment.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance increment:increment];
        }
    } @catch (NSException *exception) {
        
    }
}
-(void)profileAppend:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *profile = [paramsDict stringValueForKey:@"property" defaultValue:nil];
        NSArray *content = [paramsDict arrayValueForKey:@"value" defaultValue:nil];
        if (profile.length > 0 && content.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance append:profile  by:content];
        }
    } @catch (NSException *exception) {
        
    }
}

-(void)profileDelete:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        [SensorsAnalyticsSDK.sharedInstance deleteUser];
    } @catch (NSException *exception) {
        
    }
}

-(void)registerSuperProperties:(NSDictionary *)paramsDict {
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSDictionary *superProperties = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance registerSuperProperties:superProperties];
    } @catch (NSException *exception) {
    }
}
-(void)unregisterSuperProperty:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *unRegisterKey = [paramsDict stringValueForKey:@"proprerty" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance unregisterSuperProperty:unRegisterKey];
    } @catch (NSException *exception) {
    }
}
-(void)identify:(NSDictionary *)paramsDict{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *identify = [paramsDict stringValueForKey:@"anonymousId" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance identify:identify];
    } @catch (NSException *exception) {
        
    }
}
    
-(void)enableLog:(NSDictionary *)paramsDict {
    @try {
        BOOL enableLog = [paramsDict boolValueForKey:@"enableLog" defaultValue:NO];
        [SensorsAnalyticsSDK.sharedInstance enableLog:enableLog];
    } @catch (NSException *exception) {
        
    }
}

-(void)trackViewScreen:(NSDictionary *)paramsDict{
    @try {
        NSString *urlString = [paramsDict stringValueForKey:@"url" defaultValue:nil];
        NSDictionary *properties = [paramsDict dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackViewScreen:urlString withProperties:properties];
    } @catch (NSException *exception) {
        
    }
}

-(NSString *)getDistinctId:(NSDictionary *)paramsDict {
    NSString *distinctId = nil;
    @try {
        distinctId = [SensorsAnalyticsSDK.sharedInstance distinctId];
    } @catch (NSException *exception) {
        distinctId = nil;
    } @finally {
        return distinctId;
    }
}

-(void)deleteAll:(NSDictionary *)paramsDict{
    @try {
        [SensorsAnalyticsSDK.sharedInstance deleteAll];
    } @catch (NSException *exception) {
    }
}

-(void)setServerUrl:(NSDictionary *)paramsDict {
    @try {
        NSString *serverUrl = [paramsDict stringValueForKey:@"serverUrl" defaultValue:nil];
        if (serverUrl.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance setServerUrl:serverUrl];
        }
    } @catch (NSException *exception) {
        
    }
}
@end
