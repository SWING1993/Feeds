//
//  AppFeedsViewController.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "AppFeedsViewController.h"
#import "FeedTableViewCell.h"
#import "CMBaseRequest.h"
#import "Feed.h"
#import "PostFeedViewController.h"

static NSString * const kCellIdentifier = @"cell";

@interface AppFeedsViewController ()

@property(nonatomic, strong) NSMutableArray <Feed*>*dataSource;

@end

@implementation AppFeedsViewController

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray array];
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/getAll" requestMethod:YTKRequestMethodGET requestArgument:nil];
    @weakify(self)
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        if ([request.responseObject[@"success"] boolValue]) {
            NSArray *data = request.responseObject[@"result"];
            NSArray *feeds = [[[data rac_sequence] map:^id _Nullable(NSString *json) {
                Feed *feed = [Feed mj_objectWithKeyValues:json];
                return feed;
            }] array];
            self.dataSource = [feeds mutableCopy];
            [self.tableView reloadData];
        } else {
            [QMUITips showInfo:@"请求失败"];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"error:%@",request.error);
        [QMUITips showInfo:@"请求失败"];
    }];
}


- (void)setupNavigationItems {
    [super setupNavigationItems];
    @weakify(self)
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:UIImageMake(@"feeds_post") style:UIBarButtonItemStyleDone handler:^(id sender) {
        @strongify(self)
        CMBaseNavigationController *postNav = [[CMBaseNavigationController alloc] initWithRootViewController:[[PostFeedViewController alloc] init]];
        [self presentViewController:postNav animated:YES completion:NULL];
    }];;
}

- (void)initTableView {
    [super initTableView];
    self.tableView.estimatedRowHeight = 300;
    self.tableView.qmui_cacheCellHeightByKeyAutomatically = YES;
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>

- (id<NSCopying>)qmui_tableView:(UITableView *)tableView cacheKeyForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = self.dataSource[indexPath.section];
    return feed.content.qmui_md5;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[FeedTableViewCell alloc] initForTableView:tableView withReuseIdentifier:kCellIdentifier];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    Feed *feed = self.dataSource[indexPath.section];
    [cell updateCellAppearanceWithIndexPath:indexPath];
    [cell renderWithNameText:feed.author contentText:feed.content];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView qmui_clearsSelection];
}

@end
