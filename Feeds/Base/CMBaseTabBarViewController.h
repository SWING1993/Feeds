//
//  BaseTabBarViewController.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/25.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import "QMUITabBarViewController.h"
#import <QMUIKit/QMUIKit.h>

/*
 对应系统的 UITabBarController，优化对横竖屏逻辑，横竖屏的方向由 tabBarController 当前正在显示的 controller 来决定。
 */

@interface CMBaseTabBarViewController : QMUITabBarViewController

@end
