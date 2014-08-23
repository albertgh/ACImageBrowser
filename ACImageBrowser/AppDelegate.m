//
//  AppDelegate.m
//  ACImageBrowser
//
//  Created by Albert Chu on 14/8/23.
//  Copyright (c) 2014年 AC. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"

#import "UIImageView+WebCache.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // clear all for test progress
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[RootViewController new]];

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
