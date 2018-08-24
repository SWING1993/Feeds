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

#import "InteractiveCell.h"

@interface InteractiveCell ()
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) CALayer *separator;
@end

@implementation InteractiveCell

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
    self.likeButton = [[UIButton alloc] init];
    [self.likeButton setImage:UIImageMake(@"feed_like") forState:UIControlStateNormal];
    [self.likeButton setImage:UIImageMake(@"feed_liked") forState:UIControlStateSelected];
    [self.likeButton sizeToFit];
    [self.likeButton addTarget:self action:@selector(clickLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    self.commentButton = [[UIButton alloc] init];
    [self.commentButton setImage:UIImageMake(@"feed_comment") forState:UIControlStateNormal];
    [self.commentButton sizeToFit];
    [self.commentButton addTarget:self action:@selector(clickCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.commentButton];
    
    self.separator = [[CALayer alloc] init];
    self.separator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1].CGColor;
    [self.contentView.layer addSublayer:self.separator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat avatarViewWidth = 20;
    CGFloat leftPadding = 8.0;
    CGFloat avatarTopSpace = (CGRectGetHeight(bounds) - avatarViewWidth) / 2.0;

    self.likeButton.frame = CGRectMake(leftPadding, avatarTopSpace, avatarViewWidth, avatarViewWidth);
    
    self.commentButton.frame = CGRectMake(leftPadding*2 + CGRectGetMaxX(self.likeButton.frame), avatarTopSpace, avatarViewWidth, avatarViewWidth);
    
    CGFloat height = 0.5;
    self.separator.frame = CGRectMake(leftPadding, bounds.size.height - height, bounds.size.width - leftPadding, height);
}

- (void)clickLikeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)clickCommentAction:(UIButton *)sender {
    if (self.clickMenuBlock) {
        self.clickMenuBlock();
    }
}

@end
