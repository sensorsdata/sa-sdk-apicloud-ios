//
//  SensorsAnalyticsAPICloudSDK.m
//  SensorsAnalyticsAPICloudSDK
//
//  Created by 肖彦敏 on 2016/12/1.
//  Copyright © 2015－2018 Sensors Data Inc. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SensorsAnalyticsAPICloudSDK.h"
#import "UZAppDelegate.h"
#import "NSDictionaryUtils.h"
#import "SensorsAnalyticsSDK.h"

static NSString * const kSAAPICloudPluginVersion = @"apicloud:2.2.0";
static NSString * const kSAAPICloudPluginVersionKey = @"$lib_plugin_version";
static NSString * const kSAAPICloudAppInstall = @"AppInstall";

static NSString * const kSAAPICloudSDK = @"sensorsAnalyticsAPICloudSDK";
static NSString * const kSAAPICloudConfigServerURL = @"server_url";
static NSString * const kSAAPICloudConfigEnableLog = @"enable_log";
static NSString * const kSAAPICloudConfigEnableAutoTrack = @"auto_track";
static NSString * const kSAAPICloudConfigFlushInterval = @"flush_interval";
static NSString * const kSAAPICloudConfigFlushBulkSize = @"flush_bulkSize";
static NSString * const kSAAPICloudConfigEnableEncrypt = @"encrypt";

@implementation SensorsAnalyticsAPICloudSDK

+ (void)performSelectorWithImplementation:(void(^)(void))implementation {
    @try {
        implementation();
    } @catch (NSException *exception) {
        NSLog(@"\n ❌ [SensorsAnalyticsAPICloudSDK Exception] \n [Exception Message]: %@ \n [CallStackSymbols]: %@ ", exception, [exception callStackSymbols]);
    }
}

- (void)performSelectorWithImplementation:(void(^)(void))implementation {
    [self.class performSelectorWithImplementation:implementation];
}

/**
 * @abstract
 * 通过插件触发的事件, 添加 $lib_plugin_version 属性
 * 1. 在应用程序生命周期中, 第一次通过插件 track 事件时, 需要添加 $lib_plugin_version 属性, 后续事件无需添加该属性
 * 2. 当用户的属性中包含 $lib_plugin_version 时, 插件不进行覆盖
 * @param properties 事件属性
 */
- (NSDictionary *)appendPluginVersion:(NSDictionary *)properties {
    if (properties[kSAAPICloudPluginVersionKey]) {
        return properties;
    }
    __block NSMutableDictionary *newProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
        newProperties[kSAAPICloudPluginVersionKey] = @[kSAAPICloudPluginVersion];
    });
    return newProperties ?: properties;
}

+ (void)onAppLaunch:(NSDictionary *)launchOptions {
}

JS_METHOD(initSDK:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:@"" launchOptions:nil];
        NSDictionary *config = context.param;
        if (![config isKindOfClass:[NSDictionary class]] || config.allKeys.count == 0) {
            [SensorsAnalyticsSDK startWithConfigOptions:options];
            return;
        }
        NSString *serverUrl = [config stringValueForKey:kSAAPICloudConfigServerURL defaultValue:@""];
        options = [[SAConfigOptions alloc] initWithServerURL:serverUrl launchOptions:nil];
        BOOL enableLog = [config boolValueForKey:kSAAPICloudConfigEnableLog defaultValue:NO];
        options.enableLog = enableLog;
        BOOL autoTrack = [config boolValueForKey:kSAAPICloudConfigEnableAutoTrack defaultValue:NO];
        if (autoTrack) {
            options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd;
        }
        options.flushInterval = [config integerValueForKey:kSAAPICloudConfigFlushInterval defaultValue:15 * 1000];
        options.flushBulkSize = [config integerValueForKey:kSAAPICloudConfigFlushBulkSize defaultValue:100];
        options.enableEncrypt = [config boolValueForKey:kSAAPICloudConfigEnableEncrypt defaultValue:NO];
        [SensorsAnalyticsSDK startWithConfigOptions:options];
    }];
}

/**
 * @abstract
 * 登录，设置当前用户的 loginId
 *
 * @param context 中包含 loginId (NSString 类型)
 *
 * 例如：
 * var param = {
 *     loginId:'123456'
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(login:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *loginId = [param stringValueForKey:@"loginId" defaultValue:nil];
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance login:loginId withProperties:[self appendPluginVersion:properties]];
    }];
}

/**
 * @abstract
 * 调用 track 接口，追踪一个带有属性的 event
 *
 * @param context 中包含两个参数，event 和 properties
 *        event  事件名称(NSString 类型)
 *        properties 事件属性（NSDictionary 类型）
 * 其中的 key 是 Property 的名称，必须是 <code>NSString</code>
 * value 则是 Property 的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSDate</code> 这些类型
 * 特别的，<code>NSSet</code> 类型的 value 中目前只支持其中的元素是 <code>NSString</code>
 *
 * 例如：
 * var param = {
 *     event:事件名称
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(track:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *event = [param stringValueForKey:@"event" defaultValue:nil];
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance track:event withProperties:[self appendPluginVersion:properties]];
    }];
}

/**
 * @abstract
 * 强制试图把数据传到对应的 SensorsAnalytics 服务器上
 *
 * @discussion
 * 主动调用 flush 接口，则不论 flushInterval 和网络类型的限制条件是否满足，都尝试向服务器上传一次数据
 *
 * @param context 无参数
 */
JS_METHOD(flush:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance flush];
    }];
}

/**
 * @abstract
 * 调用trackInstallation接口，App 首次启动时追踪渠道来源
 *
 * 例如：
 * var param = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(trackInstallation:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackInstallation:kSAAPICloudAppInstall withProperties:properties];
    }];
}

/**
 * @abstract
 * 初始化事件的计时器。
 *
 * @discussion
 * 若需要统计某个事件的持续时间，先在事件开始时调用 trackTimerStart:"Event" 记录事件开始时间，该方法并不会真正发
 * 送事件；随后在事件结束时，调用 trackTimerEnd:"Event" withProperties:properties，SDK 会追踪 "Event" 事件，并自动将事件持续时
 * 间记录在事件属性 "event_duration" 中。
 *
 * 时间单位为秒，若需要以其他时间单位统计时长
 *
 * 多次调用 trackTimerStart:"Event" 时，事件 "Event" 的开始时间以最后一次调用时为准。
 *
 * @param context 参考 -(void)track:(UZModuleMethodContext *)context;
 *
 * 例如：
 * var startParam = {
 *     event:'eventName'
 * }
 * var endParam = {
 *     event:'eventName'
 *     properties{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD_SYNC(trackTimerStart:(UZModuleMethodContext *)context) {
    __block NSString *eventId = nil;
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *event = [param stringValueForKey:@"event" defaultValue:nil];
        eventId = [SensorsAnalyticsSDK.sharedInstance trackTimerStart:event];
    }];
    return eventId;
}

JS_METHOD(trackTimerPause:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *event = [param stringValueForKey:@"event" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackTimerPause:event];
    }];
}

JS_METHOD(trackTimerResume:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *event = [param stringValueForKey:@"event" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackTimerResume:event];
    }];
}

JS_METHOD(trackTimerEnd:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *event = [param stringValueForKey:@"event" defaultValue:nil];
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackTimerEnd:event withProperties:[self appendPluginVersion:properties]];
    }];
}

/**
 * @abstract
 * 清除所有事件计时器
 * @param context 无参数
 */
JS_METHOD(clearTrackTimer:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance clearTrackTimer];
    }];
}

/**
 * @abstract
 * 注销，清空当前用户的 loginId
 * @param context 无参数
 */
JS_METHOD(logout:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance logout];
    }];
}

/**
 * @abstract
 * 直接设置用户的一个或者几个 Profiles
 *
 * @discussion
 * 这些 Profile 的内容用一个 <code>NSDictionary</code> 来存储
 * 其中的 key 是 Profile 的名称，必须是 <code>NSString</code>
 * Value 则是 Profile 的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSArray</code>,
 *                              <code>NSDate</code> 这些类型
 * 特别的，<code>NSSet</code> 或者 <code>NSArray</code> 类型的 value 中目前只支持其中的元素是 <code>NSString</code>
 * 如果某个 Profile 之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 *
 * @param context 要替换的那些 Profile 的内容
 *
 * 例如：
 * var param = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(profileSet:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *profile = [param dictValueForKey:@"properties" defaultValue:nil];
        if (profile.count) {
            [SensorsAnalyticsSDK.sharedInstance set:profile];
        }
    }];
}

/**
 * @abstract
 * 首次设置用户的一个或者几个 Profiles
 *
 * @discussion
 * 与 set 接口不同的是，如果该用户的某个 Profile 之前已经存在了，会被忽略；不存在，则会创建
 *
 * @param context 要替换的那些Profile的内容
 */
JS_METHOD(profileSetOnce:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *profile = [param dictValueForKey:@"properties" defaultValue:nil];
        if (profile.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance setOnce:profile];
        }
    }];
}

/**
 * @abstract
 * 删除某个 Profile 的全部内容
 *
 * @discussion
 * 如果这个 Profile 之前不存在，则直接忽略
 *
 * @param context Profile的名称
 *
 * 例如：
 * var param = {
 *     property:profileKey
 * }
 */
JS_METHOD(profileUnset:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *unsetProfileKey = [param stringValueForKey:@"property" defaultValue:nil];
        if (unsetProfileKey.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance unset:unsetProfileKey];
        }
    }];
}

/**
 * @abstract
 * 给多个数值类型的Profile增加数值
 *
 * @discussion
 * profileDict中，key 是 <code>NSString</code>，value 是 <code>NSNumber</code>
 * 只能对 <code>NSNumber</code> 类型的 Profile 调用这个接口，否则会被忽略
 * 如果这个 Profile 之前不存在，则初始值当做 0 来处理
 *  profile  待增加数值的Profile的名称
 *  amount   要增加的数值
 *
 * @param context 多个待增加数值的 profile:amount 组合
 *
 * 例如：
 * var param = {
 *     properties:{
 *         profile:amount,
 *         profile1:amount1
 *     }
 * }
 */
JS_METHOD(profileIncrement:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *increment = [param dictValueForKey:@"properties" defaultValue:nil];
        if (increment.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance increment:increment];
        }
    }];
}

/**
 * @abstract
 * 向一个 <code>NSSet</code> 或者 <code>NSArray</code> 类型的 value 添加一些值
 *
 * @discussion
 * 如前面所述，这个< code>NSSet</code> 或者 <code>NSArray</code> 的元素必须是 <code>NSString</code>，否则，会忽略
 * 同时，如果要 append 的 Profile 之前不存在，会初始化一个空的 <code>NSSet</code> 或者 <code>NSArray</code>
 *
 *  profile profileName NSString 类型
 *  content description NSArray 类型
 * @param context 多个待增加数值的 profile:amount 组合
 *
 * 例如：
 * var param = {
 *         property:"profileName",
 *         value:["desc1","desc2"]
 * }

 */
JS_METHOD(profileAppend:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *profile = [param stringValueForKey:@"property" defaultValue:nil];
        NSArray *content = [param arrayValueForKey:@"value" defaultValue:nil];
        if (profile.length > 0 && content.count > 0) {
            [SensorsAnalyticsSDK.sharedInstance append:profile  by:content];
        }
    }];
}

/**
 * @abstract
 * 删除当前这个用户的所有记录
 * @param context 无参数
 */
JS_METHOD(profileDelete:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance deleteUser];
    }];
}

/**
 * @abstract
 * 用来设置每个事件都带有的一些公共属性
 *
 * @discussion
 * 当 track 的 Properties，superProperties 和 SDK 自动生成的 automaticProperties 有相同的 key 时，遵循如下的优先级：
 *    track.properties > superProperties > automaticProperties
 * 另外，当这个接口被多次调用时，是用新传入的数据去 merge 先前的数据，并在必要时进行 merger
 * 例如，在调用接口前，dict 是 @{@"a":1, @"b": "bbb"}，传入的 dict 是 @{@"b": 123, @"c": @"asd"}，则 merge 后的结果是
 * @{"a":1, @"b": 123, @"c": @"asd"}，同时，SDK 会自动将 superProperties 保存到文件中，下次启动时也会从中读取
 *
 * @param context 传入merge到公共属性的dict
 *
 * 例如：
 * var param = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(registerSuperProperties:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *superProperties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance registerSuperProperties:superProperties];
    }];
}

/**
 * @abstract
 * 从 superProperty 中删除某个 property
 *
 * @param context 待删除的 property 的名称
 *
 * 例如：
 * var param = {
 *     property:key
 * }
 */
JS_METHOD(unregisterSuperProperty:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *unRegisterKey = [param stringValueForKey:@"property" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance unregisterSuperProperty:unRegisterKey];
    }];
}

JS_METHOD_SYNC(getSuperProperties:(UZModuleMethodContext *)context) {
    __block NSDictionary *properties = nil;
    [self performSelectorWithImplementation:^{
        properties = [SensorsAnalyticsSDK.sharedInstance currentSuperProperties];
    }];
    return properties;
}

/**
 * @abstract
 * 设置当前用户的distinctId
 *
 * @discussion
 * 一般情况下，如果是一个注册用户，则应该使用注册系统内的 user_id
 * 如果是个未注册用户，则可以选择一个不会重复的匿名 ID，如设备 ID 等
 * 如果客户没有设置 indentify，则使用SDK自动生成的匿名 ID
 * SDK会自动将设置的 distinctId 保存到文件中，下次启动时会从中读取
 *
 * @param context 当前用户的identify
 *
 * 例如：
 * var param = {
 *     anonymousId:identify
 * }
 */
JS_METHOD(identify:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *identify = [param stringValueForKey:@"anonymousId" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance identify:identify];
    }];
}

/**
 * @abstract
 * 开启/关闭 log
 *
 * @discussion
 * 如果这个 Profile 之前不存在，则直接忽略
 *
 * @param context 是否开启 log
 *
 * 例如：
 * var param = {
 *     enableLog:true
 * }
 */
JS_METHOD(enableLog:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        BOOL enableLog = [param boolValueForKey:@"enableLog" defaultValue:NO];
        [SensorsAnalyticsSDK.sharedInstance enableLog:enableLog];
    }];
}

/**
 * @abstract
 * 页面浏览事件
 *
 * @param context 中包含两个参数，url 和 properties
 *        url  页面 url 标示
 *        properties 事件属性（NSDictionary 类型）
 * 其中的 key 是 Property 的名称，必须是 <code>NSString</code>
 * value 则是 Property 的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSDate</code> 这些类型
 * 特别的，<code>NSSet</code> 类型的 value 中目前只支持其中的元素是 <code>NSString</code>
 *
 * 例如：
 * var param = {
 *     url:事件名称
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(trackViewScreen:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *urlString = [param stringValueForKey:@"url" defaultValue:nil];
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [SensorsAnalyticsSDK.sharedInstance trackViewScreen:urlString withProperties:properties];
#pragma clang diagnostic pop
    }];
}

/**
 * @abstract
 * 获取当前的 distinctId
 * @param context 无参数
 */
JS_METHOD_SYNC(getDistinctId:(UZModuleMethodContext *)context) {
    __block NSString *distinctId = nil;
    [self performSelectorWithImplementation:^{
        distinctId = [SensorsAnalyticsSDK.sharedInstance distinctId];
    }];
    return distinctId;
}

/**
 * @abstract
 * 删除本地所有的事件
 * @param context 无参数
 */
JS_METHOD(deleteAll:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance deleteAll];
    }];
}

/**
 * @abstract
 * 设置serverUrl
 *
 * @param context serverUrl
 *
 * 例如：
 * var param = {
 *     serverUrl: serverUrl,
 *     requestRemoteConfig: true
 * }
 */
JS_METHOD(setServerUrl:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *serverUrl = [param stringValueForKey:@"serverUrl" defaultValue:nil];
        BOOL isRequestRemoteConfig = [param boolValueForKey:@"requestRemoteConfig" defaultValue:false];
        if (serverUrl.length > 0) {
            [SensorsAnalyticsSDK.sharedInstance setServerUrl:serverUrl isRequestRemoteConfig:isRequestRemoteConfig];
        }
    }];
}

#pragma mark -
/**
 * @abstract
 * 记录 $AppInstall 事件，用于在 App 首次启动时追踪渠道来源，并设置追踪渠道事件的属性。
 * 这是 Sensors Analytics 进阶功能，请参考文档 https://sensorsdata.cn/manual/track_installation.html
 *
 * @param context : object
 *
 * 例如：
 * var param = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
JS_METHOD(trackAppInstall:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance trackAppInstallWithProperties:properties];
    }];
}

/**
 * @abstract
 * 删除所有事件公共属性
 * @param context 无参数
 */
JS_METHOD(clearSuperProperties:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [[SensorsAnalyticsSDK sharedInstance] clearSuperProperties];
    }];
}

/**
 * @abstract
 * 设置 flush 时网络发送策略，默认 3G、4G、WI-FI 环境下都会尝试 flush
 * TYPE_NONE = 0;//NULL
 * TYPE_2G = 1;//2G
 * TYPE_3G = 1 << 1;//3G 2
 * TYPE_4G = 1 << 2;//4G 4
 * TYPE_WIFI = 1 << 3;//WIFI 8
 * TYPE_5G = 1 << 4;//5G 16
 * TYPE_ALL = 0xFF;//ALL 255
 * 例：若需要开启 4G 5G 发送数据，则需要设置 4 + 16 = 20
 *
 * @param flushNetworkPolicy int 网络类型
 *
 * 例如：
 * var param = {
 *     networkPolicy:31
 * }
 */
JS_METHOD(setFlushNetworkPolicy:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        SensorsAnalyticsNetworkType defaultValue = SensorsAnalyticsNetworkType3G |
            SensorsAnalyticsNetworkType4G |
#ifdef __IPHONE_14_1
            SensorsAnalyticsNetworkType5G |
#endif
            SensorsAnalyticsNetworkTypeWIFI;
        NSInteger policy = [param integerValueForKey:@"networkPolicy" defaultValue:defaultValue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[SensorsAnalyticsSDK sharedInstance] setFlushNetworkPolicy:policy];
#pragma clang diagnostic pop
    }];
}

/**
 * @abstract
 * 设置两次数据发送的最小时间间隔
 *
 * @param flushInterval 时间间隔，单位毫秒 : number
 *
 * 例如：
 * var param = {
 *     flushInterval:30000
 * }
 */
JS_METHOD(setFlushInterval:(UZModuleMethodContext *)context) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSInteger flushInterval = [param integerValueForKey:@"flushInterval" defaultValue:0];
        [[SensorsAnalyticsSDK sharedInstance] setFlushInterval:flushInterval];
    }];
#pragma clang diagnostic pop
}

/**
 * @abstract
 * 设置本地缓存日志的最大条目数，最小 50 条
 *
 * @param flushBulkSize 缓存数目 : number
 *
 * 例如：
 * var param = {
 *     flushBulkSize:200
 * }
 */
JS_METHOD(setFlushBulkSize:(UZModuleMethodContext *)context) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSInteger flushBulkSize = [param integerValueForKey:@"flushBulkSize" defaultValue:0];
        [[SensorsAnalyticsSDK sharedInstance] setFlushBulkSize:flushBulkSize];
    }];
#pragma clang diagnostic pop
}

/**
 * @abstract
 * 获取两次数据发送的最小时间间隔
 * 默认值 15 * 1000 毫秒
 *
 * @param context 无参数
 * @return 返回时间间隔，单位毫秒
 */
JS_METHOD_SYNC(getFlushInterval:(UZModuleMethodContext *)context) {
    __block UInt64 flushInterval = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        flushInterval = [[SensorsAnalyticsSDK sharedInstance] flushInterval];
    }];
#pragma clang diagnostic pop
    return @(flushInterval);
}

/**
 * @abstract
 * 本地缓存的最大事件数目，当累积日志量达到阈值时发送数据
 * 默认值为 100 条
 *
 * @param context 无参数
 * @return 本地缓存的最大事件数目
 */
JS_METHOD_SYNC(getFlushBulkSize:(UZModuleMethodContext *)context) {
    __block UInt64 flushBulkSize = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self performSelectorWithImplementation:^{
        flushBulkSize = [[SensorsAnalyticsSDK sharedInstance] flushBulkSize];
    }];
#pragma clang diagnostic pop
    return @(flushBulkSize);
}

/**
 * @abstract
 * 返回预置属性
 *
 * @param context 无参数
 * @return 预置属性
 */
JS_METHOD_SYNC(getPresetProperties:(UZModuleMethodContext *)context) {
    __block NSDictionary *preset = nil;
    [self performSelectorWithImplementation:^{
        preset = [[SensorsAnalyticsSDK sharedInstance] getPresetProperties];
    }];
    return preset;
}

/**
 * @abstract
 * 获取当前用户的 loginId
 * 若未设置过用户的 loginId，会返回 null
 *
 * @param context 无参数
 * @return 当前用户的 loginId
 */
JS_METHOD_SYNC(getLoginId:(UZModuleMethodContext *)context) {
    __block NSString *loginId;
    [self performSelectorWithImplementation:^{
        loginId = [[SensorsAnalyticsSDK sharedInstance] loginId];
    }];
    return loginId;
}

/**
 * 设置 item
 *
 * @param context : object
 *
 * 例如：
 * var param = {
 *      itemType:itemType,
 *      itemId:itemId,
 *      properties:properties
 * }
 */
JS_METHOD(itemSet:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *itemType = [param stringValueForKey:@"itemType" defaultValue:nil];
        NSString *itemId = [param stringValueForKey:@"itemId" defaultValue:nil];
        NSDictionary *properties = [param dictValueForKey:@"properties" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance itemSetWithType:itemType itemId:itemId properties:properties];
    }];
}

/**
 * @abstract
 * 删除 item
 *
 * @param context : object
 *
 * 例如：
 * var param = {
 *      itemType:itemType,
 *      itemId:itemId
 * }
 */
JS_METHOD(itemDelete:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *itemType = [param stringValueForKey:@"itemType" defaultValue:nil];
        NSString *itemId = [param stringValueForKey:@"itemId" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance itemDeleteWithType:itemType itemId:itemId];
    }];
}

/**
 * @abstract
 * 是否开启 AutoTrack
 *
 * @return YES: 开启 AutoTrack; NO: 关闭 AutoTrack
 */
JS_METHOD_SYNC(isAutoTrackEnabled:(UZModuleMethodContext *)context) {
    __block BOOL isAutoTrackEnabled = NO;
    [self performSelectorWithImplementation:^{
        isAutoTrackEnabled = [SensorsAnalyticsSDK.sharedInstance isAutoTrackEnabled];
    }];
    return @(isAutoTrackEnabled);
}

/**
 * @abstract
 * 直接设置用户的 pushId
 *
 * @param context : object
 *
 * 例如：
 * var param = {
 *      pushTypeKey:jgId,
 *      pushId:pushId
 * }
 */
JS_METHOD(profilePushId:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *pushTypeKey = [param stringValueForKey:@"pushTypeKey" defaultValue:nil];
        NSString *pushId = [param stringValueForKey:@"pushId" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance profilePushKey:pushTypeKey pushId:pushId];
    }];
}

/**
 * @abstract
 * 删除用户设置的 pushId
 *
 * @param pushTypeKey  pushId 的 key
 *
 * 例如：
 * var param = {
 *      pushTypeKey:jgId,
 * }
 */
JS_METHOD(profileUnsetPushId:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *pushTypeKey = [param stringValueForKey:@"pushTypeKey" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance profileUnsetPushKey:pushTypeKey];
    }];
}

#pragma mark - Android Only
JS_METHOD(enableNetWorkRequest:(UZModuleMethodContext *)context) {
}

JS_METHOD_SYNC(isNetworkRequestEnable:(UZModuleMethodContext *)context) {
    return @(YES);
}

JS_METHOD(setSessionIntervalTime:(UZModuleMethodContext *)context) {
}

JS_METHOD_SYNC(getSessionIntervalTime:(UZModuleMethodContext *)context) {
    return @(30 * 1000);
}

JS_METHOD(enableDataCollect:(UZModuleMethodContext *)context) {
}

/**
 * @abstract
 * 禁用 SDK。调用后，SDK 将不采集事件，不发送网络请求
 *
 * @param context 无参数
 */
JS_METHOD(disableSDK:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK disableSDK];
    }];
}

/**
 * @abstract
 * 开启 SDK。如果之前 SDK 是禁止状态，调用后将恢复数据采集功能
 *
 * @param context 无参数
 */
JS_METHOD(enableSDK:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK enableSDK];
    }];
}

/**
 * @abstract
 * 获取当前数据接收地址
 *
 * @param context 无参数
 * @return 数据接收地址
 */
JS_METHOD_SYNC(getServerUrl:(UZModuleMethodContext *)context) {
    __block NSString *url = nil;
    [self performSelectorWithImplementation:^{
        url = [SensorsAnalyticsSDK.sharedInstance serverUrl];
    }];
    return url;
}

/**
 * @abstract
 * ID-Mapping 3.0 登录，设置当前用户的 loginIDKey 和 loginId

 * ⚠️ 此接口为 ID-Mapping 3.0 特殊场景下特定接口，请咨询确认后再使用

 * @param context key: 当前用户的登录 ID key; id: 当前用户的登录 ID
 *
 * 例如：
 * var param = {
 *      key: login_id,
 *      id: user123
 * }
 */
JS_METHOD(loginWithKey:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *loginKey = [param stringValueForKey:@"key" defaultValue:nil];
        NSString *loginId = [param stringValueForKey:@"id" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance loginWithKey:loginKey loginId:loginId];
    }];
}

/**
 * @abstract
 * ID-Mapping 3.0 功能下已绑定的业务 ID 列表
 *
 * @param context 无参数
 * @return 业务 ID 列表
 */
JS_METHOD_SYNC(getIdentities:(UZModuleMethodContext *)context) {
    __block NSDictionary *properties = nil;
    [self performSelectorWithImplementation:^{
        properties = [SensorsAnalyticsSDK.sharedInstance identities];
    }];
    return properties;
}

/**
 * @abstract
 * ID-Mapping 3.0 功能下绑定业务 ID 功能
 *
 * @param context key: 绑定业务 ID 的键名; vale: 绑定业务 ID 的键值
 *
 * 例如：
 * var param = {
 *      key: email,
 *      value: 123@abc.com
 * }
 */
JS_METHOD(bind:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *key = [param stringValueForKey:@"key" defaultValue:nil];
        NSString *value = [param stringValueForKey:@"value" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance bind:key value:value];
    }];
}

/**
 * @abstract
 * ID-Mapping 3.0 功能下解绑业务 ID 功能
 *
 * @param context key: 解绑业务 ID 的键名; vale: 解绑业务 ID 的键值
 *
 * 例如：
 * var param = {
 *      key: email,
 *      value: 123@abc.com
 * }
 */
JS_METHOD(unbind:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *key = [param stringValueForKey:@"key" defaultValue:nil];
        NSString *value = [param stringValueForKey:@"value" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance unbind:key value:value];
    }];
}

/**
 * @abstract
 * 获取匿名 id
 *
 * @param context 无参数
 * @return 匿名 id
 */
JS_METHOD_SYNC(getAnonymousId:(UZModuleMethodContext *)context) {
    __block NSString *anonymousId = nil;
    [self performSelectorWithImplementation:^{
        anonymousId = [SensorsAnalyticsSDK.sharedInstance anonymousId];
    }];
    return anonymousId;
}

/**
 * @abstract
 * 重置默认匿名 id
 *
 * @param context 无参数
 */
JS_METHOD(resetAnonymousId:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        [SensorsAnalyticsSDK.sharedInstance resetAnonymousId];
    }];
}

/**
 * @abstract
 * 删除事件计时
 *
 * @param context eventName: 事件名称或事件的 eventId
 *
 * 例如：
 * var param = {
 *      eventName: BuyProduct
 * }
 */
JS_METHOD(removeTimer:(UZModuleMethodContext *)context) {
    [self performSelectorWithImplementation:^{
        NSDictionary *param = context.param;
        NSString *eventName = [param stringValueForKey:@"event" defaultValue:nil];
        [SensorsAnalyticsSDK.sharedInstance removeTimer:eventName];
    }];
}

@end
