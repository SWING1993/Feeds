//
//  BaseNavigationController.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/25.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

/*
 对应系统的 UINavigationController，建议作为项目里的所有 navigationController 的基类。通常搭配 QMUICommonViewController 来使用，提供的功能包括：
 方便地控制前后界面切换时的状态栏样式（例如前一个界面需要黑色，后一个界面需要白色）。
 控制导航栏的显隐、颜色、背景、分隔线等。
 当界面切换时，前后界面的导航栏样式不同，则允许提供一种更加美观的切换效果，以同时展示两条不同的导航栏。
 提供 willShow、didShow、willPop、didPop 等时机给 viewController 使用。
 */

@interface CMBaseNavigationController : QMUINavigationController

@end
