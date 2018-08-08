//
//  CMLogManager.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/1.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMLogManager.h"

@interface CMLogManager ()

//@property(nonatomic, strong)NSMutableArray <QMUILogItem *>*mutableAllLogs;
@property(nonatomic, strong)YTKKeyValueStore *store;
@property(nonatomic, copy)NSString *tableName;
@end

@implementation CMLogManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CMLogManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
       
    }
    return self;
}

- (void)setup {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        self.store = [[YTKKeyValueStore alloc] initDBWithName:@"applog.db"];
        self.tableName = @"log_table";
        [self.store createTableWithName:self.tableName];
        
        [[[QMUILogger sharedInstance] rac_signalForSelector:@selector(printLogWithFile:line:func:logItem:)] subscribeNext:^(RACTuple * _Nullable x) {
            QMUILogItem *logItem = x.fourth;
            // 禁用了某个 name 则直接退出
            if (!logItem.enabled) return;
            // 不同级别的 log 可通过配置表的开关来控制是否要输出
            if (logItem.level == QMUILogLevelDefault && !ShouldPrintDefaultLog) return;
            if (logItem.level == QMUILogLevelInfo && !ShouldPrintInfoLog) return;
            if (logItem.level == QMUILogLevelWarn && !ShouldPrintWarnLog) return;

            CMLogModel *model = [[CMLogModel alloc] init];
            model.logItem = logItem;
            model.createTime = [[NSDate date] stringByMessageDate];
            model.file = x.first;
            model.line = x.second;
            model.func = x.third;
            // 格式化一下logstring
            NSString *formatString = [NSString stringWithFormat:@"File:%@\nLine:%@\nFunc:%@\n%@", model.file, model.line,model.func,logItem.logString];
            model.logItem.logString = formatString;
            NSString *json = [model mj_JSONString];
            [self.store putString:json withId:logItem.logString.qmui_md5 intoTable:self.tableName];
            
        }];
    });
}

- (void)removeAllLogs {
    [self.store clearTable:self.tableName];
}

- (NSArray <CMLogModel *>*)allLogs {
    NSArray *allLogs = [self.store getAllItemsFromTable:self.tableName];
    return [[allLogs.rac_sequence map:^id _Nullable(YTKKeyValueItem *item) {
        NSString *json = [item.itemObject firstObject];
        return [CMLogModel mj_objectWithKeyValues:json];
    }] array];
}

@end
