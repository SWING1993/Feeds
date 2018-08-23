//
//  FeedTableViewCell.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "FeedTableViewCell.h"

static NSString * const kCellIdentifier = @"cell";
const UIEdgeInsets kInsets = {15, 15, 15, 15};
const CGFloat kAvatarSize = 40;
const CGFloat kAvatarMarginRight = 12;
const CGFloat kAvatarMarginBottom = 6;
const CGFloat kContentMarginBotom = 10;
const CGFloat kImageMarginSpace = 10;

@implementation FeedTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    
    [super didInitializeWithStyle:style];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *avatarImage = [UIImage qmui_imageWithStrokeColor:UIColorTheme1 size:CGSizeMake(kAvatarSize, kAvatarSize) lineWidth:CGFLOAT_MIN cornerRadius:CGFLOAT_MIN];
    _avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    [self.contentView addSubview:self.avatarImageView];
    
    _nameLabel = [[UILabel alloc] qmui_initWithFont:UIFontBoldMake(14) textColor:UIColorGray2];
    [self.contentView addSubview:self.nameLabel];
    
    _contentLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray1];
    self.contentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.contentLabel];
    
    _timeLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(11) textColor:UIColorGray];
    [self.contentView addSubview:self.timeLabel];
    
    self.gridView = [[QMUIGridView alloc] init];
    self.gridView.columnCount = 3;
    self.gridView.separatorWidth = kImageMarginSpace;
    self.gridView.separatorColor = [UIColor clearColor];
    self.gridView.separatorDashed = NO;
    CGFloat contentLabelWidth = CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(kInsets);
    self.gridView.rowHeight = (contentLabelWidth - (2*kImageMarginSpace))/3;
    [self.contentView addSubview:self.gridView];
    
}

- (void)renderWithFeed:(Feed *)feed {
    self.feed = feed;
    if (!kStringIsEmpty(feed.avatar)) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feed.avatar]];
    }
    self.nameLabel.text = feed.author;
    self.contentLabel.attributedText = [self attributeStringWithString:feed.content lineHeight:26];
    self.timeLabel.text = feed.created;
    self.contentLabel.textAlignment = NSTextAlignmentJustified;
    
    NSArray *imageArr = [self imageUrlArrayWithStr:feed.imageUrls];
    self.imageNum = imageArr.count;
    
    [self.gridView.subviews bk_each:^(UIView *view) {
        [view removeFromSuperview];
    }];
    
    for (NSInteger i = 0; i < self.imageNum; i ++) {
        NSString *urlStr = imageArr[i];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i + 1;
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        imageView.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/256.f
                                               green:(arc4random()%256)/256.f
                                                blue:(arc4random()%256)/256.f
                                               alpha:0.8f];
        [self.gridView addSubview:imageView];
        
        [imageView bk_whenTapped:^{
            NSLog(@"W:%f-----H:%f",imageView.qmui_width,imageView.qmui_height);
        }];
    }
}

- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight {
    if (textString.qmui_trim.length <= 0) return nil;
    NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentJustified]}];
    return attriString;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeMake(size.width, 0);
    CGFloat contentLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(kInsets);
    CGFloat resultHeight = UIEdgeInsetsGetHorizontalValue(kInsets) + CGRectGetHeight(self.avatarImageView.bounds) + kAvatarMarginBottom;
    if (self.contentLabel.text.length > 0) {
        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        resultHeight += (contentSize.height + kContentMarginBotom);
    }
    if (self.timeLabel.text.length > 0) {
        CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        resultHeight += timeSize.height;
    }
    if (self.imageNum > 0) {
        resultHeight += [self gridViewHeightWithNum:self.imageNum];
    }
    resultSize.height = resultHeight;
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentLabelWidth = CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(kInsets);
    self.avatarImageView.frame = CGRectSetXY(self.avatarImageView.frame, kInsets.left, kInsets.top);
    if (self.nameLabel.text.length > 0) {
        CGFloat nameLabelWidth = contentLabelWidth - CGRectGetWidth(self.avatarImageView.bounds) - kAvatarMarginRight;
        CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(nameLabelWidth, CGFLOAT_MAX)];
        self.nameLabel.frame = CGRectFlatMake(CGRectGetMaxX(self.avatarImageView.frame) + kAvatarMarginRight, CGRectGetMinY(self.avatarImageView.frame) + (CGRectGetHeight(self.avatarImageView.bounds) - nameSize.height) / 2, nameLabelWidth, nameSize.height);
    }
    if (self.contentLabel.text.length > 0) {
        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        self.contentLabel.frame = CGRectFlatMake(kInsets.left, CGRectGetMaxY(self.avatarImageView.frame) + kAvatarMarginBottom, contentLabelWidth, contentSize.height);
    }
    
    self.gridView.frame = CGRectFlatMake(kInsets.left, CGRectGetMaxY(self.contentLabel.frame) + kContentMarginBotom, contentLabelWidth, [self gridViewHeightWithNum:self.imageNum]);

    if (self.timeLabel.text.length > 0) {
        CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        self.timeLabel.frame = CGRectFlatMake(CGRectGetMinX(self.contentLabel.frame), CGRectGetMaxY(self.gridView.frame) + kContentMarginBotom, contentLabelWidth, timeSize.height);
    }
}

- (CGFloat)gridViewHeightWithNum:(NSInteger)num {
    if (num == 0) {
        return CGFLOAT_MIN;
    }
    NSInteger x = ceil(num/3.0);
    CGFloat height = (self.gridView.rowHeight * x + kImageMarginSpace * ( x - 1 ));
    return height;
}

- (NSArray *)imageUrlArrayWithStr:(NSString *)str {
    return [[str componentsSeparatedByString:@","] bk_select:^BOOL(NSString *url) {
        return [url hasPrefix:@"http"];
    }];
}

@end
