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

#define kCellIdentifier_PostEssayImageCell @"PostEssayImageCell"


@interface PostFeedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)TPKeyboardAvoidingTableView *tableView;
@property(nonatomic,copy)NSString *feedContent;
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
    NSDictionary *argument = @{@"content":self.feedContent,@"uid":@"88"};
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/add" requestMethod:YTKRequestMethodPOST requestArgument:argument];
    @weakify(self)
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        if ([request.responseObject[@"result"] boolValue]) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [QMUITips showInfo:@"请求失败"];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"error:%@",request.error);
        [QMUITips showInfo:@"请求失败"];
    }];
}

#pragma mark - Table view
- (TPKeyboardAvoidingTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:kScreenBounds style:UITableViewStyleGrouped];
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
        return 40;
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
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    [imagePickerController setDelegate:self];
//    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
//    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    imagePickerController.bk_didFinishPickingMediaBlock = ^(UIImagePickerController *pickerController, NSDictionary *info){
        [pickerController dismissViewControllerAnimated:YES completion:nil];
        UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (aImage) {
            OssService *service = [[OssService alloc] init];
            [service asyncPutImage:@"pic.png" image:aImage];
        }
    };
    
    imagePickerController.bk_didCancelBlock = ^(UIImagePickerController *pickerController) {
        [pickerController dismissViewControllerAnimated:YES completion:nil];
    };
    
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


@end
