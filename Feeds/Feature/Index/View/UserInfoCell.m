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
    self.authorLabel.font = [UIFont boldSystemFontOfSize:15];
    self.authorLabel.textColor = [UIColor darkTextColor];
    self.authorLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.authorLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    CGFloat avatarViewWidth = 25.0;
    CGFloat avatarTopSpace = (CGRectGetHeight(bounds) - avatarViewWidth) / 2.0;
    CGFloat avatarLeftSpace = 8.0;
    self.avatarView.frame = CGRectMake(avatarLeftSpace, avatarTopSpace, avatarViewWidth, avatarViewWidth);
    self.avatarView.layer.cornerRadius = MIN(CGRectGetHeight(self.avatarView.frame), CGRectGetWidth(self.avatarView.frame)) / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    
    self.authorLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 8.0, CGRectGetMinY(self.avatarView.frame), CGRectGetWidth(bounds) - CGRectGetMaxX(self.avatarView.frame) - 8.0 * 2, CGRectGetHeight(self.avatarView.frame));
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

@end
