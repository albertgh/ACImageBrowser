//
//  RootViewController.m
//  ACImageBrowser
//
//  Created by Albert Chu on 14/8/23.
//  Copyright (c) 2014年 AC. All rights reserved.
//

#import "RootViewController.h"

#import "ACImageBrowser.h"

@interface RootViewController () <ACImageBrowserDelegate>

@end


@implementation RootViewController

- (void)buttonTapped:(UIButton *)sender
{
    // fake data
    NSMutableArray *photosURL = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"hTtP://img3.douban.com/view/photo/large/public/p2190945201.jpg"];
    [photosURL addObject:url];
    
    NSArray *urlStringArray = @[
                                @"http://img3.douban.com/view/photo/large/public/p2190945223.jpg",
                                @"http://ww3.sinaimg.cn/large/bef016betw1egpuchlis1g20ku0dwdp2.gif",
                                @"http://img3.douban.com/view/photo/large/public/p2190971820.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2190945210.jpg",
                                @"http://img5.douban.com/view/photo/large/public/p2190945058.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2190945063.jpg",
                                @"http://img3.douban.com/view/photo/large/public/p2192132792.jpg"
                                ];
    
    for (NSString *str in urlStringArray)
    {
        NSURL *url = [NSURL URLWithString:str];
        [photosURL addObject:url];
    }
    
    ACImageBrowser *browser = [[ACImageBrowser alloc] initWithImagesURLArray:photosURL];
    browser.delegate = self;
    //browser.fullscreenEnable = NO;
    [browser setPageIndex:2];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - ACImageBrowserDelegate

- (void)dismissAtIndex:(NSInteger)index
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Dismiss at index: %lu", (unsigned long)index);
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sample";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    // button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(70.0, 200.0, 180.0, 40.0);
    [button setTitle:@"show" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *borderColor = [UIColor colorWithRed:0 green:0.3 blue:0.6 alpha:1];
    
    button.backgroundColor = [UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:1.0];
    [button setTitleColor:borderColor forState:UIControlStateNormal];
    
    // border
    button.layer.cornerRadius = 6;
    button.layer.borderWidth = 1;
    button.layer.borderColor = borderColor.CGColor;
    
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
