//
//  FeedTableViewCell.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "FeedTableViewCell.h"

static NSString * const kCellIdentifier = @"cell";
const UIEdgeInsets kInsets = {15, 16, 15, 16};
const CGFloat kAvatarSize = 30;
const CGFloat kAvatarMarginRight = 12;
const CGFloat kAvatarMarginBottom = 6;
const CGFloat kContentMarginBotom = 10;

@implementation FeedTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    
    UIImage *avatarImage = [UIImage qmui_imageWithStrokeColor:UIColorTheme1 size:CGSizeMake(kAvatarSize, kAvatarSize) lineWidth:3 cornerRadius:6];
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
    self.gridView.rowHeight = 60;
    self.gridView.separatorWidth = PixelOne;
    self.gridView.separatorColor = UIColorSeparator;
    self.gridView.separatorDashed = NO;
    [self.view addSubview:self.gridView];
}

- (void)renderWithNameText:(NSString *)nameText contentText:(NSString *)contentText {
    
    self.nameLabel.text = nameText;
    self.contentLabel.attributedText = [self attributeStringWithString:contentText lineHeight:26];
    self.timeLabel.text = @"昨天 18:24";
    self.contentLabel.textAlignment = NSTextAlignmentJustified;
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
    if (self.timeLabel.text.length > 0) {
        CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        self.timeLabel.frame = CGRectFlatMake(CGRectGetMinX(self.contentLabel.frame), CGRectGetMaxY(self.contentLabel.frame) + kContentMarginBotom, contentLabelWidth, timeSize.height);
    }
}

@end
