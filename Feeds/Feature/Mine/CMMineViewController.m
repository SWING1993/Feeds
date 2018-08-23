//
//  CMMineViewController.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/31.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMMineViewController.h"

@interface CMMineViewController ()

@property(nonatomic, strong) UIImageView *avatarView;

@end

@implementation CMMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/user/getById" requestMethod:YTKRequestMethodGET requestArgument:@{@"id":@"1"}];
    @weakify(self)
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        if ([request.responseObject[@"success"] boolValue]) {
            NSDictionary *result = request.responseObject[@"result"];
            if (!kStringIsEmpty(result[@"avatar"])) {
                [self.avatarView sd_setImageWithURL:[NSURL URLWithString:result[@"avatar"]]];
            }
        } else {
            [QMUITips showInfo:@"请求失败"];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [QMUITips showInfo:@"请求失败"];
    }];
}

- (void)initSubviews {
    [super initSubviews];
    [self setTitle:@"我的"];
   
    
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.backgroundColor = UIColorTheme2;
    self.avatarView.userInteractionEnabled = YES;
    [self.view addSubview:self.avatarView];

    @weakify(self)

    [self.avatarView bk_whenTapped:^{
        @strongify(self)
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePickerController animated:YES completion:nil];
        imagePickerController.bk_didCancelBlock = ^(UIImagePickerController *picker) {
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
        @weakify(self)
        imagePickerController.bk_didFinishPickingMediaBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            @strongify(self)
            UIImage *aImage = info[UIImagePickerControllerOriginalImage];
            OssService *service = [[OssService alloc] init];
            [service asyncPutImage:aImage success:^(NSString *result) {
                kDISPATCH_MAIN_THREAD(^{
                    self.avatarView.image = aImage;
                })
                
                CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/user/updateAvatar" requestMethod:YTKRequestMethodPOST requestArgument:@{@"id":@"1",@"avatar":result}];
                [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
                    if ([request.responseObject[@"success"] boolValue]) {
                        [QMUITips showSucceed:@"上传成功"];
                    } else {
                        [QMUITips showInfo:@"请求失败"];
                    }
                } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                    [QMUITips showInfo:@"请求失败"];
                }];
                
            } failed:^(NSError *error) {
                kDISPATCH_MAIN_THREAD(^{
                    [QMUITips showSucceed:@"上传失败"];
                })
            }];
        };
        
    }];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.avatarView.frame = CGRectMake(100, 100, 150, 150);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
}

@end
