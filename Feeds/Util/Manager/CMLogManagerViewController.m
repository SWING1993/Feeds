//
//  CMLogManagerViewController.m
//  MpmPackStone
//
//  Created by 宋国华 on 2018/8/1.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "CMLogManagerViewController.h"
#import "CMLogManager.h"

static NSString * const kCellIdentifier = @"cell";
const UIEdgeInsets kInsets = {15, 16, 15, 16};
const CGFloat kAvatarSize = 20;
const CGFloat kAvatarMarginRight = 12;
const CGFloat kAvatarMarginBottom = 6;
const CGFloat kContentMarginBotom = 10;

@interface CMLogManagerTableViewCell : QMUITableViewCell

@property(nonatomic, strong) UIImageView *logLevelImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *contentLabel;

- (void)configCellWithModel:(CMLogModel *)logModel keyword:(NSString *)keyword;

@end

@interface CMRecentSearchView : UIView

@property(nonatomic, strong) QMUILabel *titleLabel;
@property(nonatomic, strong) QMUIFloatLayoutView *floatLayoutView;
@property(nonatomic, strong) RACSubject *suggestionSubject;
@property(nonatomic, strong) NSArray *suggestions;

- (instancetype)initWithSuggestions:(NSArray <NSString *>*)suggestions;

@end

@implementation CMRecentSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorWhite;
        
        self.titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorGray2];
        self.titleLabel.text = @"最近搜索";
        self.titleLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
        [self.titleLabel sizeToFit];
        self.titleLabel.qmui_borderPosition = QMUIViewBorderPositionBottom;
        [self addSubview:self.titleLabel];
        
        self.floatLayoutView = [[QMUIFloatLayoutView alloc] init];
        self.floatLayoutView.padding = UIEdgeInsetsZero;
        self.floatLayoutView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
        self.floatLayoutView.minimumItemSize = CGSizeMake(69, 29);
        [self addSubview:self.floatLayoutView];
    
    }
    return self;
}

- (instancetype)initWithSuggestions:(NSArray <NSString *>*)suggestions {
    self = [super init];
    if (self) {
        self.suggestions = suggestions;
        for (NSInteger i = 0; i < suggestions.count; i++) {
            QMUIGhostButton *button = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorGray];
            [button setTitle:suggestions[i] forState:UIControlStateNormal];
            button.titleLabel.font = UIFontMake(14);
            button.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 6, 20);
            button.tag = i;
            [self.floatLayoutView addSubview:button];
            [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)clickBtn:(UIButton *)sender {
    if (self.suggestionSubject) {
        [self.suggestionSubject sendNext:self.suggestions[sender.tag]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets padding = UIEdgeInsetsConcat(UIEdgeInsetsMake(26, 26, 26, 26), self.qmui_safeAreaInsets);
    CGFloat titleLabelMarginTop = 20;
    self.titleLabel.frame = CGRectMake(padding.left, padding.top, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(padding), CGRectGetHeight(self.titleLabel.frame));
    
    CGFloat minY = CGRectGetMaxY(self.titleLabel.frame) + titleLabelMarginTop;
    self.floatLayoutView.frame = CGRectMake(padding.left, minY, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(padding), CGRectGetHeight(self.bounds) - minY);
}

@end

@interface CMLogManagerViewController ()

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) NSMutableArray *searchResults;
@property(nonatomic, strong) QMUISearchController *mySearchController;

@end

@implementation CMLogManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResults = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *allLogs = [[CMLogManager sharedInstance] allLogs];
    self.dataSource = [self handleFilterDataWithArray:allLogs];
    [self.tableView reloadData];
    
}

- (void)initSubviews {
    [super initSubviews];
    [self setTitle:@"日志"];
    
    NSArray<NSString *> *suggestions = @[@"Helps", @"Maintain", @"Liver", @"Health", @"Function", @"Supports", @"Healthy", @"Fat"];
    CMRecentSearchView *launchView =  [[CMRecentSearchView alloc] initWithSuggestions:suggestions];
    launchView.suggestionSubject = [RACSubject subject];
    @weakify(self)
    [launchView.suggestionSubject subscribeNext:^(NSString * x) {
        @strongify(self)
        self.mySearchController.searchBar.text = x;
    }];
    
    self.mySearchController = [[QMUISearchController alloc] initWithContentsViewController:self];
    self.mySearchController.searchResultsDelegate = self;
    self.mySearchController.launchView = launchView;// launchView 会自动布局，无需处理 frame
    self.mySearchController.searchBar.qmui_usedAsTableHeaderView = YES;// 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
    self.mySearchController.tableView.estimatedRowHeight = 300;
    self.mySearchController.tableView.qmui_cacheCellHeightByKeyAutomatically = YES;
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
}

- (void)initTableView {
    [super initTableView];
    // 如果需要自动缓存 cell 高度的计算结果，则打开这个属性，然后实现 - [QMUITableViewDelegate qmui_tableView:cacheKeyForRowAtIndexPath:] 方法即可
    // 只要打开这个属性，cell 的 self-sizing 特性也会被开启，所以请保证你的 cell 正确重写了 sizeThatFits: 方法（Auto-Layout 的忽略这句话）
    self.tableView.estimatedRowHeight = 300;// 注意，QMUI 通过配置表的开关 TableViewEstimatedHeightEnabled，默认在所有 iOS 版本打开 estimatedRowHeight（系统是在 iOS 11 之后默认打开），所以图方便的话这一句也可以不用写。
    self.tableView.qmui_cacheCellHeightByKeyAutomatically = YES;
}


- (void)setupNavigationItems {
    [super setupNavigationItems];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllLogEvent)];
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"开关" style:UIBarButtonItemStylePlain target:self action:@selector(handleMenuEvent)];
    self.navigationItem.rightBarButtonItems = @[clearItem,editItem];
}

- (void)clearAllLogEvent {
    self.dataSource = [NSArray array];
    [self.tableView reloadData];
    [[CMLogManager sharedInstance] removeAllLogs];
}

- (void)handleMenuEvent {
    QMUILogManagerViewController *logVc = [[QMUILogManagerViewController alloc] init];
    [self.navigationController pushViewController:logVc animated:YES];
}

- (NSArray *)handleFilterDataWithArray:(NSArray *)allDatas {
    NSArray *results = [[NSArray alloc] init];
    if (allDatas.count == 0) {
        return results;
    }
    [self hideEmptyView];
    NSMutableArray *enableNames = [NSMutableArray array];
    NSDictionary *allLogNameDict = [QMUILogger sharedInstance].logNameManager.allNames;
    for (NSString *name in allLogNameDict.allKeys) {
        BOOL enable = [allLogNameDict[name] boolValue];
        if (enable) {
            [enableNames addObject:name];
        }
    }
    
    NSArray *allLogs = allDatas;
    NSMutableArray *allNameSections = [NSMutableArray array];
    for (NSString *name in enableNames) {
        NSMutableArray *sections = [NSMutableArray array];
        for (CMLogModel*logModel in allLogs) {
            if ([logModel.logItem.name isEqualToString:name]) {
                [sections addObject:logModel];
            }
        }
        [allNameSections addObject:sections];
    }
    results = [allNameSections copy];
    if (results.count == 0) {
        [self showEmptyViewWithText:@"暂无产生日志" detailText:nil buttonTitle:nil buttonAction:NULL];
    } else {
        [self hideEmptyView];
    }
    return results;
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>

- (id<NSCopying>)qmui_tableView:(UITableView *)tableView cacheKeyForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMLogModel *logModel = self.dataSource[indexPath.section][indexPath.row];
    return @(logModel.logItem.logString.length);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.dataSource.count;
    }
    return self.searchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionLogs;
    if (tableView == self.tableView) {
        sectionLogs = self.dataSource[section];
    } else {
        sectionLogs = self.searchResults[section];
    }
    return sectionLogs.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CMLogModel *logModel;
    if (tableView == self.tableView) {
        logModel = [self.dataSource[section] firstObject];
    } else {
        logModel = [self.searchResults[section] firstObject];
    }
    return logModel.logItem.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMLogManagerTableViewCell *cell = (CMLogManagerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[CMLogManagerTableViewCell alloc] initForTableView:tableView withReuseIdentifier:kCellIdentifier];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    CMLogModel *logModel;
    if (tableView == self.tableView) {
        logModel = self.dataSource[indexPath.section][indexPath.row];
    } else {
        logModel = self.searchResults[indexPath.section][indexPath.row];
    }
    [cell configCellWithModel:logModel keyword:self.mySearchController.searchBar.text];
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView qmui_clearsSelection];
}

#pragma mark - <QMUISearchControllerDelegate>

- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    [self.searchResults removeAllObjects];
    
    NSMutableArray *filterArray = [NSMutableArray array];
    for (NSArray *sections in self.dataSource) {
        for (CMLogModel *logModel in sections) {
            if ([logModel.logItem.logString containsString:searchString]) {
                [filterArray addObject:logModel];
            }
        }
    }
    
    self.searchResults = [[self handleFilterDataWithArray:filterArray] mutableCopy];
    [searchController.tableView reloadData];
    
    if (self.searchResults.count == 0) {
        [searchController showEmptyViewWithText:@"没有匹配结果" detailText:nil buttonTitle:nil buttonAction:NULL];
    } else {
        [searchController hideEmptyView];
    }
}

- (void)willPresentSearchController:(QMUISearchController *)searchController {
    [QMUIHelper renderStatusBarStyleDark];
}

- (void)willDismissSearchController:(QMUISearchController *)searchController {
    BOOL oldStatusbarLight = NO;
    if ([self respondsToSelector:@selector(shouldSetStatusBarStyleLight)]) {
        oldStatusbarLight = [self shouldSetStatusBarStyleLight];
    }
    if (oldStatusbarLight) {
        [QMUIHelper renderStatusBarStyleLight];
    } else {
        [QMUIHelper renderStatusBarStyleDark];
    }
}

@end

@implementation CMLogManagerTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    
    UIImage *avatarImage = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:CGSizeMake(kAvatarSize, kAvatarSize) lineWidth:2 tintColor:UIColorTheme1];
    _logLevelImageView = [[UIImageView alloc] initWithImage:avatarImage];
    [self.contentView addSubview:self.logLevelImageView];
    
    _nameLabel = [[UILabel alloc] qmui_initWithFont:UIFontBoldMake(16) textColor:UIColorGray2];
    [self.contentView addSubview:self.nameLabel];
    
    _contentLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(17) textColor:UIColorGray1];
    self.contentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.contentLabel];
}

- (void)configCellWithModel:(CMLogModel *)logModel keyword:(NSString *)keyword {
    /*
     QMUILogLevelDefault,
     QMUILogLevelInfo,
     QMUILogLevelWarn
     */
    UIColor *cellTintColor;
    if (logModel.logItem.level == QMUILogLevelInfo) {
        cellTintColor = UIColorTheme1;
    } else if (logModel.logItem.level == QMUILogLevelWarn) {
        cellTintColor = UIColorTheme3;
    } else {
        cellTintColor = UIColorTheme7;
    }
    self.logLevelImageView.image = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:CGSizeMake(kAvatarSize, kAvatarSize) lineWidth:2 tintColor:cellTintColor];
    self.nameLabel.text = logModel.createTime;
    self.contentLabel.attributedText = [self attributeStringWithString:logModel.logItem.logString lineHeight:26 keyword:keyword];
    self.contentLabel.textAlignment = NSTextAlignmentJustified;
}


- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight keyword:(NSString *)keyword {
    if (textString.qmui_trim.length <= 0) return nil;
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]}];
    
    if (keyword.length > 0) {
        NSRange range = [attriString.string rangeOfString:keyword];
        if (range.location != NSNotFound) {
            [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorTheme1} range:range];
        }
    }
    return attriString;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeMake(size.width, 0);
    CGFloat contentLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(kInsets);
    CGFloat resultHeight = UIEdgeInsetsGetHorizontalValue(kInsets) + CGRectGetHeight(self.logLevelImageView.bounds) + kAvatarMarginBottom;
    if (self.contentLabel.text.length > 0) {
        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        resultHeight += (contentSize.height + kContentMarginBotom);
    }
    resultSize.height = resultHeight;
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentLabelWidth = CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(kInsets);
    self.logLevelImageView.frame = CGRectSetXY(self.logLevelImageView.frame, kInsets.left, kInsets.top);
    if (self.nameLabel.text.length > 0) {
        CGFloat nameLabelWidth = contentLabelWidth - CGRectGetWidth(self.logLevelImageView.bounds) - kAvatarMarginRight;
        CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(nameLabelWidth, CGFLOAT_MAX)];
        self.nameLabel.frame = CGRectFlatMake(CGRectGetMaxX(self.logLevelImageView.frame) + kAvatarMarginRight, CGRectGetMinY(self.logLevelImageView.frame) + (CGRectGetHeight(self.logLevelImageView.bounds) - nameSize.height) / 2, nameLabelWidth, nameSize.height);
    }
    if (self.contentLabel.text.length > 0) {
        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        self.contentLabel.frame = CGRectFlatMake(kInsets.left, CGRectGetMaxY(self.logLevelImageView.frame) + kAvatarMarginBottom, contentLabelWidth, contentSize.height);
    }
}

@end
