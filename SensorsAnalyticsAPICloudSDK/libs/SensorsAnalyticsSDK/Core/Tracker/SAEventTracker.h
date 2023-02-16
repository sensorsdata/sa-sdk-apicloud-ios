//
// SAEventTracker.h
// SensorsAnalyticsSDK
//
// Created by 张敏超🍎 on 2020/6/18.
// Copyright © 2015-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import <Foundation/Foundation.h>
#import "SAEventRecord.h"
#import "SAHTTPSession.h"
#import "SAEventStore.h"

NS_ASSUME_NONNULL_BEGIN

extern NSUInteger const SAEventFlushRecordSize;

@interface SAEventTracker : NSObject

@property (nonatomic, strong, readonly) SAEventStore *eventStore;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (void)trackEvent:(NSDictionary *)event;
- (void)trackEvent:(NSDictionary *)event isSignUp:(BOOL)isSignUp;

- (void)flushAllEventRecords;
- (void)flushAllEventRecordsWithCompletion:(void(^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
