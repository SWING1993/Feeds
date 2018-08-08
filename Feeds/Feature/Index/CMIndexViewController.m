//
//  CMIndexViewController.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/26.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMIndexViewController.h"
#import "CMBaseRequest.h"

@interface CMIndexViewController ()

@end

@implementation CMIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *argument = @{@"uid":@"88",@"content":@"哈哈哈",@"author":@"Superman"};
    
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/add" requestMethod:YTKRequestMethodPOST requestArgument:argument];

    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        DLog(@"response:%@",request.responseString);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        DLog(@"error:%@",request.error.description);
    }];
    
    QMUILog(@"域名",@"baseurl:%@",kBaseUrl);
    QMUILog(@"app id",@"%@",[[NSBundle mainBundle]bundleIdentifier]);
}

- (void)initSubviews {
    [super initSubviews];
    [self setTitle:@"index"];    
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
}

@end
