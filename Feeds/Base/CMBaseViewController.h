//
//  BaseViewController.h
//  MpmPackStone
//
//  Created by 宋国华 on 2018/7/25.
//  Copyright © 2018年 7cm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

/*
 对应系统的 UIViewController，建议作为项目里的所有界面的基类来使用。主要特性包括：
 自带顶部标题控件 QMUINavigationTitleView，支持loading、副标题、下拉菜单，设置标题依然使用系统的 setTitle: 方法。
 自带空界面控件 QMUIEmptyView，支持显示loading、空文案、操作按钮。
 统一约定的常用接口，例如初始化 subviews、设置顶部 navigationItem、底部 toolbarItem、响应系统的动态字体大小变化等，从而保证相同类型的代码集中到同一个方法内，避免多人交叉维护时代码分散难以查找。
 通过 supportedOrientationMask 属性修改界面支持的设备方向，可直接对实例操作，无需重写系统的方法。
 支持点击空白区域降下键盘。
 */

@interface CMBaseViewController : QMUICommonViewController

@end
