//
//  CMLogItem.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/3.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMLogModel : NSObject

@property(nonatomic,strong)QMUILogItem *logItem;
@property(nonatomic,copy)NSString *file;
@property(nonatomic,copy)NSString *func;
@property(nonatomic,copy)NSString *line;
@property(nonatomic,copy)NSString *createTime;

@end
