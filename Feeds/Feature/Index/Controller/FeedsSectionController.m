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
        
        Feed *feed = _feed;
        cell.clickMenuBlock = ^(void){
            QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            }];
            QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"删除" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
                
                CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/delete" requestMethod:YTKRequestMethodDELETE requestArgument:@{@"id":feed.id}];
                @weakify(self)
                [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
                    if ([request.responseObject[@"success"] boolValue]) {
                        @strongify(self)
                        if (self.deleteFeedBlock) {
                            self.deleteFeedBlock(feed);
                        }
                        [[[feed.imageUrls componentsSeparatedByString:@","] bk_select:^BOOL(NSString *url) {
                            return [url hasPrefix:@"http"];
                        }] bk_each:^(NSString *url) {
                            OssService *service = [[OssService alloc] init];
                            [service deleteImage:url success:^(NSString *result) {
                                NSLog(@"%@",result);
                            } failed:^(NSError *error) {
                                NSLog(@"删除失败");
                            }];
                        }];
                    } else {
                        [QMUITips showInfo:@"请求失败"];
                    }
                } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                    [QMUITips showInfo:@"请求失败"];
                }];
            }];

            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"确定删除？" message:@"删除后将无法恢复，请慎重考虑" preferredStyle:QMUIAlertControllerStyleActionSheet];
            [alertController addAction:action1];
            [alertController addAction:action2];
            [alertController showWithAnimated:YES];
        };
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
