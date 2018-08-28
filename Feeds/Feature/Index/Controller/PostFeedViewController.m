//
//  PostFeedViewController.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "PostFeedViewController.h"
#import "PostFeedTextCell.h"
#import "PostFeedImageCell.h"
#import <TZImagePickerController/TZImagePickerController.h>

#define kCellIdentifier_PostEssayImageCell @"PostEssayImageCell"

@interface PostFeedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, copy) NSString *feedContent;
@property (nonatomic, copy) NSArray <UIImage *> *feedImages;
@property (nonatomic, assign) BOOL compression;

@end

@implementation PostFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    [super initSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    UIBarButtonItem *dismissBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = dismissBtn;
    
    UIBarButtonItem *postBtn = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(postFeedAction)];
    postBtn.tintColor = UIColorTheme7;
    self.navigationItem.rightBarButtonItem = postBtn;
    
    
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, feedContent)] reduce:^id (NSString *mdStr){
        return @(!kStringIsEmpty(mdStr));
    }];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)postFeedAction {
    if (kStringIsEmpty(self.feedContent)) {
        return;
    }
    if (self.feedImages.count > 0) {
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:self.feedImages.count];
        for (UIImage *image in self.feedImages) {
            OssService *service = [[OssService alloc] init];
            @weakify(self)
            [service putImage:image compression:self.compression success:^(NSString *result) {
                [imageUrls addObject:result];
                if (imageUrls.count == self.feedImages.count) {
                    @strongify(self)
                    [self postActionWithContent:self.feedContent imageUrls:imageUrls];
                }
            } failed:^(NSError *error) {
                [service normalRequestCancel];
            }];
        }
    } else {
        [self postActionWithContent:self.feedContent imageUrls:nil];
    }
}

- (void)postActionWithContent:(NSString *)content imageUrls:(NSArray *)imageUrls {
    NSString *imageStr = @"";
    if (imageUrls.count > 0) {
        NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:[imageUrls firstObject]];
        for (NSInteger x = 1; x < imageUrls.count; x ++) {
            NSString *urlStr = imageUrls[x];
            [mutableStr appendString:[NSString stringWithFormat:@",%@",urlStr]];
        }
        imageStr = [mutableStr copy];
    }
    NSDictionary *argument = @{@"content":self.feedContent,@"imageUrls":imageStr,@"uid":@"1"};
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/add" requestMethod:YTKRequestMethodPOST requestArgument:argument];
    @weakify(self)
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        if ([request.responseObject[@"success"] boolValue]) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [QMUITips showInfo:@"请求失败"];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [QMUITips showInfo:@"请求失败"];
    }];
}

#pragma mark - Table view
- (TPKeyboardAvoidingTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:kScreenBounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PostFeedTextCell class] forCellReuseIdentifier:kCellIdentifier_PostEssayTextCell];
        [_tableView registerClass:[PostFeedImageCell class] forCellReuseIdentifier:kCellIdentifier_PostEssayImageCell];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [PostFeedTextCell cellHeight];
    } else {
        return [PostFeedImageCell cellHeightWithImageCount:self.feedImages.count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PostFeedTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PostEssayTextCell forIndexPath:indexPath];
        @weakify(self)
        cell.textValueChangedBlock = ^(NSString *valueStr){
            @strongify(self)
            self.feedContent = valueStr;
        };
        return cell;
    } else {
        PostFeedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_PostEssayImageCell forIndexPath:indexPath];
        cell.images = self.feedImages;
        @weakify(self)
        cell.addPicturesBlock = ^(){
            @strongify(self)
            [self addPictAction];
        };
        cell.deleteImageBlock = ^(NSInteger index) {
            @strongify(self)
            NSMutableArray *images = [NSMutableArray arrayWithArray:self.feedImages];
            [images removeObjectAtIndex:index];
            self.feedImages = [images copy];
            [self.tableView reloadData];
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)addPictAction {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
    @weakify(self)
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        @strongify(self)
        self.compression = !isSelectOriginalPhoto;
        self.feedImages = photos;
        [self.tableView reloadData];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


@end
