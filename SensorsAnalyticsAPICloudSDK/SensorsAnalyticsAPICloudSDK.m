//
//  SensorsAnalyticsAPICloudSDK.m
//  SensorsAnalyticsAPICloudSDK
//
//  Created by 肖彦敏 on 2016/12/1.
//  Copyright © 2016年 肖彦敏. All rights reserved.
//

#import "SensorsAnalyticsAPICloudSDK.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"
#import "SensorsAnalyticsSDK.h"
#import "HLWZSutil.h"

@interface SensorsAnalyticsAPICloudSDK ()
{
    NSInteger _cbId;
    SensorsAnalyticsDebugMode mode;
}
@end

@implementation SensorsAnalyticsAPICloudSDK

+ (void)launch
{
    
}
- (id)initWithUZWebView:(id)webView
{
    if (self = [super initWithUZWebView:webView]) {
        
    }
    return self;
}
- (void)dispose
{
    //do clean
}

-(void)sharedInstance:(NSDictionary *)paramsDict
{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *serverURL = [HLWZSutil getText:paramsDict[@"serverURL"]];
        NSString *configureURL = [HLWZSutil getText:paramsDict[@"configureURL"]];
        NSString *debugMode = [HLWZSutil getText:paramsDict[@"debugMode"]];
        
        //校验debugMode
        if (![debugMode isEqualToString:@""]) {
            if (![debugMode isEqualToString:@"debugOff"]) {
                if ([debugMode isEqualToString:@"debugOnly"]) {
                    mode = SensorsAnalyticsDebugOnly;
                }
                else if ([debugMode isEqualToString:@"debugAndTrack"])
                {
                    mode = SensorsAnalyticsDebugAndTrack;
                }
                else
                {
                    [self showAlert:@"提醒" WithMessage:@"您传入的debugMode有误"];
                    return;
                }
            }
            else
            {
                mode = SensorsAnalyticsDebugOff;
            }
        }
        else
        {
            NSLog(@"debugMode模式传入错误，取值只能为：debugOff、debugOnly、debugAndTrack，请检查传入的模式");
            return;
        }
        //校验serverURL
        if ([serverURL isEqualToString:@""]) {
            if (![debugMode isEqualToString:@"debugOff"]) {
                [self showAlert:@"提醒" WithMessage:@"serverURL(收集事件的服务地址)为空,请检查传入值"];
            }
            else
            {
                NSLog(@"serverURL(收集事件的服务地址)为空,请检查传入值");
            }
            return;
        }
        //校验configureURL
        if ([configureURL isEqualToString:@""]) {
            if ([debugMode isEqualToString:@"debugOff"]) {
                [self showAlert:@"提醒" WithMessage:@"configureURL(获取SDK配置的服务地址)为空,请检查传入值"];
            }
            else
            {
                NSLog(@"configureURL(获取SDK配置的服务地址)为空,请检查传入值");
            }
            return;
        }
        [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL andConfigureURL:configureURL andDebugMode:mode];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
-(void)login:(NSDictionary *)paramsDict
{
    @try {
        _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
        
        NSString *loginId = [HLWZSutil getText:paramsDict[@"loginId"]];
        if (![loginId isEqualToString:@""]) {
            
            [[SensorsAnalyticsSDK sharedInstance] login:loginId];
        }
        else
        {
            NSLog(@"loginId（登录ID)为空");
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
-(void)track:(NSDictionary *)paramsDict
{
    _cbId = [paramsDict intValueForKey:@"cbId" defaultValue:-1];
    @try {
        NSString *event = [HLWZSutil getText:paramsDict[@"event"]];
        if (![event isEqualToString:@""]) {
            if (paramsDict[@"properties"]) {
                
                [[SensorsAnalyticsSDK sharedInstance] track:event withProperties:paramsDict[@"properties"]];
            }
            else
            {
                [[SensorsAnalyticsSDK sharedInstance] track:event];
            }
        }
        else
        {
            NSLog(@"event(事件名)为空，请检查传入值");
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
    }
}
-(void)flush:(NSDictionary *)paramsDict
{
    @try {
        [[SensorsAnalyticsSDK sharedInstance] flush];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
    }
}
- (void)showAlert:(NSString *)alertTitle WithMessage:(NSString *)alertMessage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController *connectAlert = [UIAlertController
                                           alertControllerWithTitle:alertTitle
                                           message:alertMessage
                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [connectAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        UIWindow   *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        [alertWindow.rootViewController presentViewController:connectAlert animated:YES completion:nil];
    } else {
        UIAlertView *connectAlert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [connectAlert show];
    }
    
}

@end
