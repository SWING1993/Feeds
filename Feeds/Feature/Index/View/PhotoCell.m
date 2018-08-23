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

#import "PhotoCell.h"
#import <SDCycleScrollView/SDCycleScrollView.h>

@interface PhotoCell ()
@property (nonatomic, strong) SDCycleScrollView *scrollView;
@end

@implementation PhotoCell

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
    self.scrollView = [[SDCycleScrollView alloc] init];
    self.scrollView.infiniteLoop = NO;
    self.scrollView.autoScroll = NO;
    self.scrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    [self.contentView addSubview:self.scrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.frame;
}

- (void)setImageUrls:(NSString *)imageUrls {
    NSArray *urlStrs = [[imageUrls componentsSeparatedByString:@","] bk_select:^BOOL(NSString *url) {
        return [url hasPrefix:@"http"];
    }];
    self.scrollView.imageURLStringsGroup = urlStrs;
}

@end
