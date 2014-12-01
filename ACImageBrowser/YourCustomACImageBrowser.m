//
//  YourCustomACImageBrowser.m
//  ACImageBrowser
//
//  Created by Albert Chu on 14/11/29.
//  Copyright (c) 2014年 AC. All rights reserved.
//

#import "YourCustomACImageBrowser.h"

#define C_ActionText_Color                                                      \
[UIColor colorWithRed: 0 / 255.f green: 122 / 255.f blue:255 / 255.f alpha:1.f]


@interface YourCustomACImageBrowser ()

@property (nonatomic, retain) UIToolbar     *bottomBar;

@end

static CGFloat const YourCustomACIB_BottomBar_Height            = 49.0f;


@implementation YourCustomACImageBrowser

#pragma mark - Action

- (void)navBarRightButtonTappd:(UIBarButtonItem *)sender {
    [self
     deletePhotoAtCurrentIndex:^{
         NSLog(@"delete your own stuff, like the UI before you goes into ACImageBrowser");
     }
     success:^(BOOL finished) {
         NSLog(@"deleted");
     }];
}

- (void)leftBottomButtonTapped:(UIButton *)sender {
    NSLog(@"your own action");
    
}

- (void)rightBottomButtonTapped:(UIButton *)sender {
    NSLog(@"begin your Saving animation stuff");
    [self
     savePhotoToCameraRollProgress:^(CGFloat percent) {
         NSLog(@"update your Saving animation stuff %f", percent);
     }
     success:^(BOOL success) {
         if (success) {
             NSLog(@"succ and dismiss your Saving animation stuff");
         }
         else {
             NSLog(@"fail and dismiss your Saving animation stuff");
         }
     }];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Delete"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(navBarRightButtonTappd:)];
    
    [self createBottomBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createBottomBar {
    self.bottomBar = [[UIToolbar alloc] init];
    self.bottomBar.frame = CGRectMake(0.0f,
                                      self.view.bounds.size.height - YourCustomACIB_BottomBar_Height,
                                      self.view.bounds.size.width,
                                      YourCustomACIB_BottomBar_Height);
    
    [self.view addSubview:self.bottomBar];

    
    UIButton *leftButton = [[UIButton alloc] init];
    leftButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  self.view.bounds.size.width / 2,
                                  YourCustomACIB_BottomBar_Height);
    
    [leftButton setTitleColor:C_ActionText_Color forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [leftButton setTitle:@"Custom Action" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.bottomBar addSubview:leftButton];
    
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.frame = CGRectMake(self.view.bounds.size.width / 2,
                                   0.0f,
                                   self.view.bounds.size.width / 2,
                                   YourCustomACIB_BottomBar_Height);
    
    [rightButton setTitleColor:C_ActionText_Color forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [rightButton setTitle:@"Save Photo" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar addSubview:rightButton];
}

#pragma mark - Fullscreen Animation

- (void)willAnimateToFullscreenMode {
    [super willAnimateToFullscreenMode];
    
    [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
        self.bottomBar.transform = CGAffineTransformMakeTranslation(0, YourCustomACIB_BottomBar_Height);
    } completion:^(BOOL finished) {
        self.bottomBar.hidden = YES;
    }];
}

- (void)willAnimateToNormalMode {
    [super willAnimateToNormalMode];
    
    self.bottomBar.hidden = NO;
    [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
        self.bottomBar.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

@end
