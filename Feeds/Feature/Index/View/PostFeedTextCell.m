//
//  PostFeedTextCell.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "PostFeedTextCell.h"

@implementation PostFeedTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        if (_myTextView == nil) {
            _myTextView = [[QMUITextView alloc] init];
            _myTextView.placeholder = @"这一刻的想法...";
            _myTextView.font = UIFontMake(13);
            _myTextView.textColor = [UIColor blackColor];
            _myTextView.delegate = self;
            [self.contentView addSubview:_myTextView];
            [_myTextView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(7);
                make.bottom.mas_equalTo(-20);
                make.left.mas_equalTo(10);
                make.right.mas_equalTo(-10);
            }];
        }
    }
    return self;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [self.myTextView becomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    [self.myTextView resignFirstResponder];
    return YES;
}

+ (CGFloat)cellHeight {
    return 95.0f;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

@end
