//
//  BaseTableViewController.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/25.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

/*
 对应系统的 UITableViewController，作为项目里的列表界面的基类来使用。主要特性包括：
 继承 QMUICommonViewController，具备父类的 titleView、emptyView 等功能。
 搭配 QMUITableView，具备比 UITableView 更强大的功能。
 支持默认情况下自动隐藏 headerView。
 自带搜索框（按需加载），方便地使用搜索功能。
 支持指定自定义的 contentInset，而不使用系统默认的 automaticallyAdjustsScrollViewInsets 特性。

 */

@interface CMBaseTableViewController : QMUICommonTableViewController

@end
