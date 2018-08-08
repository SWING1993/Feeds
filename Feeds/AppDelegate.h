//
//  AppDelegate.h
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Present viewController
+ (void)presentVC:(UIViewController *)viewController;
// Push viewController
+ (void)pushVC:(UIViewController *)viewController;
+ (UIViewController *)presentingVC;

@end

