//
//  CMLogManager.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/1.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMLogModel.h"

@interface CMLogManager : NSObject

+ (nonnull instancetype)sharedInstance;

- (void)setup;

- (void)removeAllLogs;

- (NSArray <CMLogModel *>*)allLogs;

@end
