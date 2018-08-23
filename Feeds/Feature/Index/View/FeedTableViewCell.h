//
//  FeedTableViewCell.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "QMUITableViewCell.h"
#import "Feed.h"

@interface FeedTableViewCell : QMUITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) QMUIGridView *gridView;
@property (nonatomic, assign) NSInteger imageNum;

@property (nonatomic, strong) Feed *feed;

- (void)renderWithFeed:(Feed *)feed;

@end
