//
//  PostFeedImageCell.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/17.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "QMUITableViewCell.h"

@interface PostFeedImageCell : QMUITableViewCell

@property (nonatomic, copy) NSArray <UIImage*> *images;
@property (copy, nonatomic) void (^addPicturesBlock)(void);
@property (copy, nonatomic) void (^deleteImageBlock)(NSInteger index);

+ (CGFloat)cellHeightWithImageCount:(NSUInteger)count;

@end
