/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UserInfoCell.h"

@interface UserInfoCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *createdLabel;
@property (nonatomic, strong) UIButton *menuBtn;

@end

@implementation UserInfoCell

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
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.backgroundColor = [UIColor colorWithRed:210/255.0 green:65/255.0 blue:64/255.0 alpha:1.0];
    [self.contentView addSubview:self.avatarView];
    
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = UIFontMake(13);
    self.authorLabel.textColor = UIColorBlack;
    self.authorLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.authorLabel];
    
    self.createdLabel = [[UILabel alloc] init];
    self.createdLabel.font = UIFontLightMake(10);
    self.createdLabel.textColor = UIColorMake(98, 98, 98);
    self.createdLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.createdLabel];
    
    self.menuBtn = [[UIButton alloc] init];
    [self.menuBtn setImage:[UIImageMake(@"feed_menu") qmui_imageWithOrientation:UIImageOrientationLeft] forState:UIControlStateNormal];
    [self.menuBtn sizeToFit];
    [self.menuBtn addTarget:self action:@selector(clickMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.menuBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    CGFloat avatarViewWidth = 35.0;
    CGFloat avatarTopSpace = (CGRectGetHeight(bounds) - avatarViewWidth) / 2.0;
    CGFloat avatarLeftSpace = 8.0;
    self.avatarView.frame = CGRectMake(avatarLeftSpace, avatarTopSpace, avatarViewWidth, avatarViewWidth);
    self.avatarView.layer.cornerRadius = MIN(CGRectGetHeight(self.avatarView.frame), CGRectGetWidth(self.avatarView.frame)) / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    
    self.authorLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 8.0,
                                        CGRectGetMinY(self.avatarView.frame),
                                        CGRectGetWidth(bounds) - CGRectGetMaxX(self.avatarView.frame) - 8.0 * 2,
                                        CGRectGetHeight(self.avatarView.frame) / 2);
    
    self.createdLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 8.0,
                                         CGRectGetMaxY(self.authorLabel.frame),
                                         CGRectGetWidth(bounds) - CGRectGetMaxX(self.avatarView.frame) - 8.0 * 2,
                                         CGRectGetHeight(self.avatarView.frame) / 2);
    
    
    CGFloat menuBtnWidth = 20.0;
    CGFloat menuBtnX = CGRectGetWidth(bounds) - menuBtnWidth - 8;
    CGFloat mentTopSpace = (CGRectGetHeight(bounds) - menuBtnWidth) / 2.0;
    self.menuBtn.frame = CGRectMake(menuBtnX, mentTopSpace, menuBtnWidth, menuBtnWidth);
}

- (void)setAuthor:(NSString *)author {
    _author = [author copy];
    self.authorLabel.text = _author;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = [avatar copy];
    if (!kStringIsEmpty(_avatar)) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_avatar]];
    }
}

- (void)setCreated:(NSString *)created {
    _created = [created copy];
    self.createdLabel.text = _created;
}

- (void)clickMenuAction:(UIButton *)sender {
    
}

@end
