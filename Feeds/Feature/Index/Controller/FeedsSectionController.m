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

#import "FeedsSectionController.h"

#import "Feed.h"
#import "ContentCell.h"
#import "PhotoCell.h"
#import "InteractiveCell.h"
#import "CommentCell.h"
#import "UserInfoCell.h"

static NSInteger cellsBeforeComments = 4;

@implementation FeedsSectionController {
    Feed *_feed;
}

#pragma mark - IGListSectionController Overrides

- (NSInteger)numberOfItems {
    return cellsBeforeComments + _feed.comments.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    const CGFloat width = self.collectionContext.containerSize.width;
    CGFloat height;
    if (index == 0) {
        height = 45.0;
    } else if (index == 1) {
        QMUILabel *label = [[QMUILabel alloc] init];
        label.numberOfLines = 0;
        label.font = UIFontMake(13);
        label.attributedText = [self attributeStringWithString:_feed.content lineHeight:20];
        CGFloat left = 8.0;
        height = [label sizeThatFits:CGSizeMake(self.collectionContext.containerSize.width - 2*left, CGFLOAT_MAX)].height + 15;
        label = nil;
    } else if (index == 2) {
        height = kStringIsEmpty(_feed.imageUrls) ? CGFLOAT_MIN : width;
    } else if (index == 3) {
        height = 30.0;
    } else {
        height = 25.0;
    }
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    if (index == 0) {
        UserInfoCell *cell = [self.collectionContext dequeueReusableCellOfClass:[UserInfoCell class] forSectionController:self atIndex:index];
        [cell setAvatar:_feed.avatar];
        [cell setAuthor:_feed.author];
        [cell setCreated:_feed.created];
        return cell;
    } else if (index == 1) {
        ContentCell *cell = [self.collectionContext dequeueReusableCellOfClass:[ContentCell class] forSectionController:self atIndex:index];
        [cell setContent:_feed.content];
        return cell;
    } else if (index == 2) {
        if (kStringIsEmpty(_feed.imageUrls)) {
            return [self.collectionContext dequeueReusableCellOfClass:[UICollectionViewCell class] forSectionController:self atIndex:index];
        } else {
            PhotoCell *cell = [self.collectionContext dequeueReusableCellOfClass:[PhotoCell class] forSectionController:self atIndex:index];
            [cell setImageUrls:_feed.imageUrls];
            return cell;
        }
    } else if (index == 3) {
        InteractiveCell *cell = [self.collectionContext dequeueReusableCellOfClass:[InteractiveCell class] forSectionController:self atIndex:index];
        return cell;
    } else {
        CommentCell *cell = [self.collectionContext dequeueReusableCellOfClass:[CommentCell class] forSectionController:self atIndex:index];
        [cell setComment:_feed.comments[index - cellsBeforeComments]];
        return cell;
    }
}

- (void)didUpdateToObject:(id)object {
    _feed = object;
}

- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight {
    if (textString.qmui_trim.length <= 0) return nil;
    NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentJustified]}];
    return attriString;
}

@end
