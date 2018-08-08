//
//  CMMineViewController.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/31.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMMineViewController.h"

@interface CMMineViewController ()

@property(nonatomic, strong) QMUIGridView *gridView;

@end

@implementation CMMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    [super initSubviews];
    [self setTitle:@"我的"];
    
    
    self.gridView = [[QMUIGridView alloc] init];
    self.gridView.columnCount = 3;
    self.gridView.rowHeight = 180;
    self.gridView.separatorWidth = PixelOne;
    self.gridView.separatorColor = UIColorSeparator;
    self.gridView.separatorDashed = NO;
    [self.view addSubview:self.gridView];      
    
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    NSArray<UIColor *> *themeColors = @[UIColorTheme1, UIColorTheme2, UIColorTheme3, UIColorTheme4, UIColorTheme5, UIColorTheme6, UIColorTheme7, UIColorTheme8];
    for (NSInteger i = 0; i < themeColors.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = themeColors[i];
        [self.gridView addSubview:view];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsMake(24 + self.qmui_navigationBarMaxYInViewCoordinator, 24, 24, 24);
    CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(padding);
    self.gridView.frame = CGRectMake(padding.left, padding.top, contentWidth, QMUIViewSelfSizingHeight);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
}

@end
