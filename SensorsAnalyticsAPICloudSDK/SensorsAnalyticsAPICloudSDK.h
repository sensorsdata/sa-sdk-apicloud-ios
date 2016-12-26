//
//  SensorsAnalyticsAPICloudSDK.h
//  SensorsAnalyticsAPICloudSDK
//
//  Created by 肖彦敏 on 2016/12/1.
//  Copyright © 2016年 肖彦敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UZModule.h"

@interface SensorsAnalyticsAPICloudSDK : UZModule

/**
 * @abstract
 * 根据传入的配置，初始化并返回一个<code>SensorsAnalyticsSDK</code>的单例
 *
 * @discussion
 * 该方法会根据 <code>configureURL</code> 参数的 Url Path，自动计算可视化埋点配置系统的 Url。例如，若传入的 <code>configureURL</code> 为:
 *     http://sa_host:8007/api/vtrack/config/iOS.conf
 * 则会自动生成可视化埋点配置系统的 Url:
 *     ws://sa_host:8007/api/ws
 * 若用户私有环境中部署了 Sensors Analytics 系统，并修改了 Nginx 配置，则需要使用 SensorsAnalyticsSDK#sharedInstanceWithServerURL:andConfigureURL:andDebugMode 进行初始化。
 
 * @param paramsDict 中需要包含三个参数 分别为serverURL、configureURL、debugMode 其中
 *   serverURL 收集事件的 URL (NSString类型)
 *   configureURL 获取配置信息的 URL (NSString类型)
 *   debugMode Sensors Analytics 的 Debug 模式，(NSString类型)
 *   debugMode模式有三种选项:
 *      debugOff - 关闭DEBUG模式
 *      debugOnly - 打开DEBUG模式，但该模式下发送的数据仅用于调试，不进行数据导入
 *      debugAndTrack - 打开DEBUG模式，并将数据导入到SensorsAnalytics中
 * 例如：
 * var paramsDict = {
 *     serverURL:收集事件的 URL
 *     configureURL: 获取配置信息的 URL
 *     debugMode:'debugAndTrack'
 * }
 */
-(void)sharedInstance:(NSDictionary *)paramsDict;
/**
 * @abstract
 * 登录，设置当前用户的loginId
 *
 * @param paramsDict 中包含loginId (NSString类型)
 *
 * 例如：
 * var paramsDict = {
 *     loginId:'123456'
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
 *     properties{
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

@end
