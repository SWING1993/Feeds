//
//  AppDelegate.m
//  Feeds
//
//  Created by 宋国华 on 2018/8/8.
//  Copyright © 2018年 swing. All rights reserved.
//

#import "AppDelegate.h"
#import "CMIndexViewController.h"
#import "CMMineViewController.h"
#import "CMLogManager.h"
#import "CMLogManagerViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 开启日志收集
    [[CMLogManager sharedInstance] setup];
    
    [self configNetworkSetting];
    
    // app配置表
    [AppConfigurationTemplate applyConfigurationTemplate];
    
    [self createTabBarController];
    
    return YES;
}

- (void)createTabBarController {
    CMBaseTabBarViewController *tabBarViewController = [[CMBaseTabBarViewController alloc] init];
    
    // index
    CMBaseNavigationController *indexNavController = ({
        CMIndexViewController *viewController = [[CMIndexViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = NO;
        CMBaseNavigationController *navController = [[CMBaseNavigationController alloc] initWithRootViewController:viewController];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Index" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
        tabBarItem.selectedImage = UIImageMake(@"icon_tabbar_lab_selected");
        navController.tabBarItem = tabBarItem;
        navController;
    });
    
    // mine
    CMBaseNavigationController *mineNavController = ({
        CMMineViewController *viewController = [[CMMineViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = NO;
        CMBaseNavigationController *navController = [[CMBaseNavigationController alloc] initWithRootViewController:viewController];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
        tabBarItem.selectedImage = UIImageMake(@"icon_tabbar_lab_selected");
        navController.tabBarItem = tabBarItem;
        navController;
    });
    
    
    // DEBUG AdHoc 环境添加一个LogController 查看日志
    if (kShouldPrint) {
        // log
        CMBaseNavigationController *logNavController = ({
            CMLogManagerViewController *viewController = [[CMLogManagerViewController alloc] init];
            viewController.hidesBottomBarWhenPushed = NO;
            CMBaseNavigationController *navController = [[CMBaseNavigationController alloc] initWithRootViewController:viewController];
            UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"日志" image:[UIImageMake(@"icon_tabbar_lab") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
            tabBarItem.selectedImage = UIImageMake(@"icon_tabbar_lab_selected");
            navController.tabBarItem = tabBarItem;
            navController;
        });
        tabBarViewController.viewControllers = @[indexNavController,mineNavController,logNavController];
    } else {
        tabBarViewController.viewControllers = @[indexNavController,mineNavController];
    }
    
    // window root controller
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}


- (void)configNetworkSetting {
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    config.baseUrl = kBaseUrl;
    config.securityPolicy.allowInvalidCertificates = YES;
    config.securityPolicy.validatesDomainName = NO;
}


#pragma mark - Action

+ (UIViewController *)presentingVC {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (void)presentVC:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    CMBaseNavigationController *nav = [[CMBaseNavigationController alloc] initWithRootViewController:viewController];
    if (!viewController.navigationItem.leftBarButtonItem) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:QMUICMI.navBarCloseButtonImage style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalViewControllerAnimated:)];
    }
    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
}

+ (void)pushVC:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    viewController.hidesBottomBarWhenPushed = YES;
    [[[self presentingVC] navigationController] pushViewController:viewController animated:YES];
}


@end
