//
//  FeedsViewController.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/23.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "FeedsViewController.h"
#import <IGListKit/IGListKit.h>
#import "FeedsSectionController.h"
#import "PostFeedViewController.h"
#import "Feed.h"

@interface FeedsViewController ()<IGListAdapterDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) NSArray<Feed *> *dataSource;

@end

@implementation FeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupRequest];
}

- (void)initSubviews {
    [super initSubviews];
    self.view.backgroundColor = UIColorWhite;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.backgroundColor = UIColorWhite;
    [self.view addSubview:self.collectionView];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init]
                                           viewController:self];
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    @weakify(self)
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:UIImageMake(@"feeds_post") style:UIBarButtonItemStyleDone handler:^(id sender) {
        @strongify(self)
        CMBaseNavigationController *postNav = [[CMBaseNavigationController alloc] initWithRootViewController:[[PostFeedViewController alloc] init]];
        @weakify(self)
        [self presentViewController:postNav animated:YES completion:^{
            @strongify(self)
            [self setupRequest];
        }];
    }];;
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.dataSource;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [FeedsSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

- (void)setupRequest {
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
            self.dataSource = [feeds copy];
            [self.adapter reloadDataWithCompletion:^(BOOL finished) {
                
            }];
            [self.collectionView reloadData];
        } else {
            [QMUITips showInfo:@"请求失败"];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [QMUITips showInfo:@"请求失败"];
    }];
}

@end
