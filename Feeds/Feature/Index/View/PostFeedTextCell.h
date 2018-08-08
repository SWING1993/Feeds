//
//  PostFeedTextCell.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "QMUITableViewCell.h"
#define kCellIdentifier_PostEssayTextCell @"PostEssayTextCell"

@interface PostFeedTextCell : QMUITableViewCell<QMUITextViewDelegate>

@property (strong, nonatomic) QMUITextView *myTextView;
@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);

+ (CGFloat)cellHeight;

@end
