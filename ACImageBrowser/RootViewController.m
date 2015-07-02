//
//  RootViewController.m
//  ACImageBrowser
//
//  Created by Albert Chu on 14/8/23.
//  Copyright (c) 2014年 AC. All rights reserved.
//

#import "RootViewController.h"

#import "YourCustomACImageBrowser.h"

#import "UIImageView+WebCache.h"

@interface RootViewController () <ACImageBrowserDelegate>

@end


@implementation RootViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sample";
    }
    return self;
}

#pragma mark - Action

- (void)clearCacheButtonTapped:(UIButton *)sender {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
}

- (void)buttonTapped:(UIButton *)sender {
    // fake data
    NSMutableArray *photosURLMArray = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"hTtP://img3.douban.com/view/photo/large/public/p2190945201.jpg"];
    [photosURLMArray addObject:url];
    
    NSArray *urlStringArray = @[
                                @"http://img3.douban.com/view/photo/large/public/p2190945223.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2213168614.jpg",
                                @"http://ww3.sinaimg.cn/large/bef016betw1egpuchlis1g20ku0dwdp2.gif",
                                @"http://img3.douban.com/view/photo/large/public/p2190971820.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2200781280.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2190945210.jpg",
                                @"http://img5.douban.com/view/photo/large/public/p2190945058.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2190945063.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2192132792.jpg"
                                ];
    
    for (NSString *str in urlStringArray) {
        NSURL *url = [NSURL URLWithString:str];
        [photosURLMArray addObject:url];
    }
    
    YourCustomACImageBrowser *browser = [[YourCustomACImageBrowser alloc] initWithImagesURLArray:photosURLMArray];
    browser.delegate = self;
    //browser.fullscreenEnable = NO;
    [browser setPageIndex:3];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - ACImageBrowserDelegate

- (void)dismissAtIndex:(NSInteger)index {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Dismiss at index: %lu", (unsigned long)index);
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Clear Cache", nil)
                                    style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(clearCacheButtonTapped:)];
    
    
    // button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake((self.view.bounds.size.width - 160.0) / 2, 200.0, 160.0, 40.0);
    [button setTitle:@"show" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *borderColor = [UIColor colorWithRed:0 green:0.3 blue:0.6 alpha:1];
    
    button.backgroundColor = [UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:1.0];
    [button setTitleColor:borderColor forState:UIControlStateNormal];
    
    // border
    button.layer.cornerRadius = 6;
    button.layer.borderWidth = 1;
    button.layer.borderColor = borderColor.CGColor;
    
    button.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
