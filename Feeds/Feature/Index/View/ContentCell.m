//
//  ContentCell.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/23.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "ContentCell.h"

@interface ContentCell()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ContentCell

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _contentLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray1];
    self.contentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat left = 8.0;
    CGRect bounds = self.contentView.bounds;
    self.contentLabel.frame = CGRectMake(left, 0, bounds.size.width - left * 2.0, bounds.size.height);
}

- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight {
    if (textString.qmui_trim.length <= 0) return nil;
    NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentJustified]}];
    return attriString;
}

- (void)setContent:(NSString *)content {
    _content = [content copy];
    self.contentLabel.attributedText = [self attributeStringWithString:_content lineHeight:20];
}


@end
