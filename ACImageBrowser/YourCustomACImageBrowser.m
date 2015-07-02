//
//  YourCustomACImageBrowser.m
//  ACImageBrowser
//
//  Created by Albert Chu on 14/11/29.
//  Copyright (c) 2014年 AC. All rights reserved.
//

#import "YourCustomACImageBrowser.h"

#define C_ActionText_Color                                                      \
[UIColor colorWithRed: 0 / 255.0 green: 122 / 255.0 blue:255 / 255.0 alpha:1.0]


@interface YourCustomACImageBrowser ()

@property (nonatomic, retain) UIToolbar     *bottomBar;

@end

static CGFloat const YourCustomACIB_BottomBar_Height            = 49.0;


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
    self.bottomBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bottomBar];
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
//                                                          attribute:NSLayoutAttributeTop
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeBottom
//                                                         multiplier:1.0
//                                                           constant:-YourCustomACIB_BottomBar_Height]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:YourCustomACIB_BottomBar_Height]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];

    // left button
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [leftButton setTitleColor:C_ActionText_Color forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [leftButton setTitle:@"Custom Action" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.bottomBar addSubview:leftButton];
    leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:leftButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:YourCustomACIB_BottomBar_Height]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:leftButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:leftButton
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:leftButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.5
                                                                constant:0.0]];
    
    // right button
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [rightButton setTitleColor:C_ActionText_Color forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [rightButton setTitle:@"Save Photo" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBar addSubview:rightButton];
    rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:YourCustomACIB_BottomBar_Height]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomBar
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.5
                                                                constant:0.0]];
}

#pragma mark - Fullscreen Animation

- (void)willAnimateToFullscreenMode {
    [super willAnimateToFullscreenMode];
    
    [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
        self.bottomBar.transform = CGAffineTransformMakeTranslation(0.0, YourCustomACIB_BottomBar_Height);
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
