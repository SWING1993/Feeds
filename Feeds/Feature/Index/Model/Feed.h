//
//  Feed.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property(nonatomic,assign)long id;
@property(nonatomic,assign)long uid;
@property(nonatomic,copy)NSString *author;
@property(nonatomic,copy)NSString *avatar;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *created;

@end
