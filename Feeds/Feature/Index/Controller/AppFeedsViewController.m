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
    
    CMBaseRequest *request = [[CMBaseRequest alloc] initWithRequestUrl:@"/feed/getAll" requestMethod:YTKRequestMethodPOST requestArgument:nil];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"request:%@",request.responseString);
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"error:%@",request.error);
    }];

}


- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleDone target:self action:@selector(handleRightBarButtonItem)];
}

- (void)initTableView {
    [super initTableView];
    self.tableView.estimatedRowHeight = 300;
    self.tableView.qmui_cacheCellHeightByKeyAutomatically = YES;
}

- (void)handleRightBarButtonItem {
    NSIndexPath *indexPathForSpecificRow = [NSIndexPath indexPathForRow:2 inSection:0];
    id<NSCopying> cacheKeyForSpecificRow = [self.tableView.delegate qmui_tableView:self.tableView cacheKeyForRowAtIndexPath:indexPathForSpecificRow];
    [self.tableView.qmui_currentCellHeightKeyCache invalidateHeightForKey:cacheKeyForSpecificRow];
    [self.tableView reloadRowsAtIndexPaths:@[indexPathForSpecificRow] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>

- (id<NSCopying>)qmui_tableView:(UITableView *)tableView cacheKeyForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = self.dataSource[indexPath.section];
    return feed.content.qmui_md5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
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
