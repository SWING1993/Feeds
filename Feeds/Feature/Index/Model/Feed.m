//
//  Feed.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "Feed.h"

@implementation Feed

- (void)setCreated:(NSString *)created {
    NSTimeInterval tempMilli = [created longLongValue];
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    _created = [createdDate timeDetail];
}

@end
