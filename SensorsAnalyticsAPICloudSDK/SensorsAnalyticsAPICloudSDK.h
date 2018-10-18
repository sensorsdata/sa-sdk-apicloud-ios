//
//  SensorsAnalyticsAPICloudSDK.h
//  SensorsAnalyticsAPICloudSDK
//
//  Created by 肖彦敏 on 2016/12/1.
//  Copyright © 2015－2018 Sensors Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UZModule.h"

@interface SensorsAnalyticsAPICloudSDK : UZModule
/**
 * @abstract
 * 用来设置每个事件都带有的一些公共属性
 *
 * @discussion
 * 当track的Properties，superProperties和SDK自动生成的automaticProperties有相同的key时，遵循如下的优先级：
 *    track.properties > superProperties > automaticProperties
 * 另外，当这个接口被多次调用时，是用新传入的数据去merge先前的数据，并在必要时进行merger
 * 例如，在调用接口前，dict是@{@"a":1, @"b": "bbb"}，传入的dict是@{@"b": 123, @"c": @"asd"}，则merge后的结果是
 * @{"a":1, @"b": 123, @"c": @"asd"}，同时，SDK会自动将superProperties保存到文件中，下次启动时也会从中读取
 *
 * @param paramsDict 传入merge到公共属性的dict
 *
 * 例如：
 * var paramsDict = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)registerSuperProperties:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 从superProperty中删除某个property
 *
 * @param paramsDict 待删除的property的名称
 *
 * 例如：
 * var paramsDict = {
 *     proprerty:key
 * }
 */
-(void)unregisterSuperProperty:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 设置当前用户的distinctId
 *
 * @discussion
 * 一般情况下，如果是一个注册用户，则应该使用注册系统内的user_id
 * 如果是个未注册用户，则可以选择一个不会重复的匿名ID，如设备ID等
 * 如果客户没有设置indentify，则使用SDK自动生成的匿名ID
 * SDK会自动将设置的distinctId保存到文件中，下次启动时会从中读取
 *
 * @param paramsDict 当前用户的identify
 *
 * 例如：
 * var paramsDict = {
 *     anonymousId:identify
 * }
 */
-(void)identify:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 登录，设置当前用户的loginId
 *
 * @param paramsDict 中包含loginId (NSString类型)
 *
 * 例如：
 * var paramsDict = {
 *     loginId:'123456'
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)login:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 调用track接口，追踪一个带有属性的event
 *
 * @param paramsDict 中包含两个参数，event和properties
 *        event  事件名称(NSString类型)
 *        properties 事件属性（NSDictionary类型）
 * 其中的key是Property的名称，必须是<code>NSString</code>
 * value则是Property的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSDate</code>这些类型
 * 特别的，<code>NSSet</code>类型的value中目前只支持其中的元素是<code>NSString</code>
 *
 * 例如：
 * var paramsDict = {
 *     event:事件名称
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)track:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 强制试图把数据传到对应的SensorsAnalytics服务器上
 *
 * @discussion
 * 主动调用flush接口，则不论flushInterval和网络类型的限制条件是否满足，都尝试向服务器上传一次数据
 *
 * @param paramsDict 无参数
 */
-(void)flush:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 调用trackInstallation接口，App 首次启动时追踪渠道来源
 *
 * @param paramsDict 中包含两个参数，event和properties
 *        event  事件名称(NSString类型)
 *        properties 事件属性（NSDictionary类型）
 * 其中的key是Property的名称，必须是<code>NSString</code>
 * value则是Property的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSDate</code>这些类型
 * 特别的，<code>NSSet</code>类型的value中目前只支持其中的元素是<code>NSString</code>
 * 默认 event:'AppInstall'
 *
 * 例如：
 * var paramsDict = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)trackInstallation:(NSDictionary *)paramsDict;

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
 * @param paramsDict 参考 -(void)track:(NSDictionary *)paramsDict;
 *
 * 例如：
 * var startParamsDict = {
 *     event:'eventName'
 * }
 * var endParamsDict = {
 *     event:'eventName'
 *     properties{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)trackTimerStart:(NSDictionary *)paramsDict;
-(void)trackTimerEnd:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 清除所有事件计时器
 * @param paramsDict 无参数
 */
-(void)clearTrackTimer:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 注销，清空当前用户的loginId
 * @param paramsDict 无参数
 */
-(void)logout:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 直接设置用户的一个或者几个Profiles
 *
 * @discussion
 * 这些Profile的内容用一个<code>NSDictionary</code>来存储
 * 其中的key是Profile的名称，必须是<code>NSString</code>
 * Value则是Profile的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSArray</code>,
 *                              <code>NSDate</code>这些类型
 * 特别的，<code>NSSet</code>或者<code>NSArray</code>类型的value中目前只支持其中的元素是<code>NSString</code>
 * 如果某个Profile之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 *
 * @param paramsDict 要替换的那些Profile的内容
 *
 * 例如：
 * var paramsDict = {
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)profileSet:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 首次设置用户的一个或者几个Profiles
 *
 * @discussion
 * 与set接口不同的是，如果该用户的某个Profile之前已经存在了，会被忽略；不存在，则会创建
 *
 * @param paramsDict 要替换的那些Profile的内容
 */
-(void)profileSetOnce:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 删除某个Profile的全部内容
 *
 * @discussion
 * 如果这个Profile之前不存在，则直接忽略
 *
 * @param paramsDict Profile的名称
 *
 * 例如：
 * var paramsDict = {
 *     property:profileKey
 * }
 */
-(void)profileUnset:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 给多个数值类型的Profile增加数值
 *
 * @discussion
 * profileDict中，key是<code>NSString</code>，value是<code>NSNumber</code>
 * 只能对<code>NSNumber</code>类型的Profile调用这个接口，否则会被忽略
 * 如果这个Profile之前不存在，则初始值当做0来处理
 *  profile  待增加数值的Profile的名称
 *  amount   要增加的数值
 *
 * @param paramsDict 多个待增加数值的 profile:amount 组合
 *
 * 例如：
 * var paramsDict = {
 *     properties:{
 *         profile:amount,
 *         profile1:amount1
 *     }
 * }
 */
-(void)profileIncrement:(NSDictionary *)paramsDict;
/**
 * @abstract
 * 向一个<code>NSSet</code>或者<code>NSArray</code>类型的value添加一些值
 *
 * @discussion
 * 如前面所述，这个<code>NSSet</code>或者<code>NSArray</code>的元素必须是<code>NSString</code>，否则，会忽略
 * 同时，如果要append的Profile之前不存在，会初始化一个空的<code>NSSet</code>或者<code>NSArray</code>
 *
 *  profile profileName NSString 类型
 *  content description NSArray 类型
 * @param paramsDict 多个待增加数值的 profile:amount 组合
 *
 * 例如：
 * var paramsDict = {
 *         property:"profileName",
 *         value:["desc1","desc2"]
 * }
 
 */
-(void)profileAppend:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 删除当前这个用户的所有记录
 * @param paramsDict 无参数
 */
-(void)profileDelete:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 开启/关闭 log
 *
 * @discussion
 * 如果这个Profile之前不存在，则直接忽略
 *
 * @param paramsDict 是否开启 log
 *
 * 例如：
 * var paramsDict = {
 *     enableLog:true
 * }
 */
-(void)enableLog:(NSDictionary *)paramsDict;


/**
 * @abstract
 * 页面浏览事件
 *
 * @param paramsDict 中包含两个参数，url和properties
 *        url  页面 url 标示
 *        properties 事件属性（NSDictionary类型）
 * 其中的key是Property的名称，必须是<code>NSString</code>
 * value则是Property的内容，只支持 <code>NSString</code>,<code>NSNumber</code>,<code>NSSet</code>,<code>NSDate</code>这些类型
 * 特别的，<code>NSSet</code>类型的value中目前只支持其中的元素是<code>NSString</code>
 *
 * 例如：
 * var paramsDict = {
 *     url:事件名称
 *     properties:{
 *       key1:value1,
 *       key2:value2
 *     }
 * }
 */
-(void)trackViewScreen:(NSDictionary *)paramsDict;
/**
 * @abstract
 * 获取当前的 distinctId
 * @param paramsDict 无参数
 */
-(NSString *)getDistinctId:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 删除本地所有的事件
 * @param paramsDict 无参数
 */
-(void)deleteAll:(NSDictionary *)paramsDict;

/**
 * @abstract
 * 设置serverUrl
 *
 * @param paramsDict serverUrl
 *
 * 例如：
 * var paramsDict = {
 *     serverUrl:serverUrl
 * }
 */
-(void)setServerUrl:(NSDictionary *)paramsDict;
@end
