//
//  PostFeedImageCell.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/17.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "PostFeedImageCell.h"
#define kSpacing 9.0f
#define kSizeThumbnail (kScreenW-12-5*kSpacing)/4
#define kCellEdgeInsets UIEdgeInsetsMake(4, 4, 4, 4)
#define HKRGBAColor(r, g, b ,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

static NSString *const Identifier = @"CollectionCellIdentifier";

@interface PhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *addPhotoBtn;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation PhotoCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_imageView) {
            _imageView = [[UIImageView alloc]init];
            _imageView.userInteractionEnabled = YES;
            _imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            [self addSubview:_imageView];
            
            _deleteBtn = [[UIButton alloc]init];
            _deleteBtn.frame = CGRectMake(_imageView.frame.size.width-25, 0, 25, 25);
            [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"image_delete"] forState:UIControlStateNormal];
            [_imageView addSubview:_deleteBtn];
        }
        
        if (!_addPhotoBtn) {
            _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_addPhotoBtn setImage:[UIImage imageNamed:@"image_add"] forState:UIControlStateNormal];
            _addPhotoBtn.backgroundColor = [UIColor whiteColor];
            _addPhotoBtn.layer.borderColor = HKRGBAColor(204, 204, 204, 0.7).CGColor;
            _addPhotoBtn.layer.borderWidth = 1.f;
            _addPhotoBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            _addPhotoBtn.enabled = NO;
            [self addSubview:_addPhotoBtn];
        }
    }
    return self;
}

@end

@interface PostFeedImageCell()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView *collectionView;

@end

@implementation PostFeedImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)setImages:(NSArray<UIImage *> *)images {
    _images = images;
    [self.collectionView reloadData];
}

+ (CGFloat)cellHeightWithImageCount:(NSUInteger)count {
    CGFloat height;
    if (count <= 3) {
        height = kSizeThumbnail + 2*kSpacing;
    } else if (4 <= count && count <= 7) {
        height = 2 * (kSizeThumbnail + kSpacing) + kSpacing;
    } else {
        height = 3 * (kSizeThumbnail + kSpacing) + kSpacing;
    }
    return height;
}

#pragma mark - UICollectionView
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kSpacing;
        layout.minimumInteritemSpacing = kSpacing;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 0, kScreenW - 20, kScreenW) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:Identifier];
    }
    return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kSizeThumbnail, kSizeThumbnail);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return kCellEdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(9, self.images.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    if (indexPath.row == self.images.count) {
        if (self.images.count < 9) {
            cell.addPhotoBtn.hidden = NO;
            cell.imageView.hidden = YES;
        } else {
            cell.addPhotoBtn.hidden = YES;
            cell.imageView.hidden = NO;
        }
    } else {
        cell.addPhotoBtn.hidden = YES;
        cell.imageView.hidden = NO;
        cell.imageView.image = self.images[indexPath.row];
        cell.deleteBtn.tag = indexPath.row;
        [cell.deleteBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.images.count) {
        if (self.addPicturesBlock) {
            self.addPicturesBlock();
        }
    }
}

- (void)deletePhoto:(id)sender {
    UIButton *btn = sender;
    NSInteger index = btn.tag;
    if (self.deleteImageBlock) {
        self.deleteImageBlock(index);
    }
}

@end
