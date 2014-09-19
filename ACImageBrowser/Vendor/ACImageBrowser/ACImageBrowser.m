//
//  ACImageBrowser.m
//
//  Created by Albert Chu on 14/8/11.
//

#import "ACImageBrowser.h"
#import "ACImageBrowserConstants.h"
#import "ACImageBrowserPortraitLayout.h"
#import "ACImageBrowserLandscapeLayout.h"
#import "ACImageBrowserCell.h"
#import "ACZoomableImageScrollView.h"

#import "UIImageView+WebCache.h"


@interface ACImageBrowser ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, retain) UICollectionView                  *collectionView;
@property (nonatomic, retain) ACImageBrowserPortraitLayout      *portraitLayout;
@property (nonatomic, retain) ACImageBrowserLandscapeLayout     *landscapeLayout;

@property (nonatomic, retain) NSArray                           *imagesURLArray;

@property (nonatomic, assign) BOOL                              isRoating;

@property (nonatomic, assign) NSInteger                         statusBarHiddenInteger;

@property (nonatomic, retain) UIImageView                       *uglyMaskIV;
@property (nonatomic, retain) UIProgressView                    *uglyMaskPV;

@end


static NSString *ACImageBrowserCellItemIdentifier               = @"ACImageBrowserCellItemIdentifier";


@implementation ACImageBrowser

#pragma mark - Public

- (void)setPageIndex:(NSUInteger)index
{
    // validate
    NSUInteger photoCount = self.imagesURLArray.count;
    if (photoCount == 0)
    {
        index = 0;
    }
    else
    {
        if (index >= photoCount)
            index = self.imagesURLArray.count - 1;
    }
    self.currentPage = index;
}

#pragma mark - Action 

- (void)closeButtonTapped:(UIButton *)sender
{
    if (self.statusBarHiddenInteger == 0)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }

    if ([self.delegate respondsToSelector:@selector(dismissAtIndex:)])
    {
        [self.delegate dismissAtIndex:self.currentPage];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)checkPushOrPresent
{
    if (self.navigationController.viewControllers[0] == self)
    {
        //DLog(@"present");
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc]initWithTitle:ACIB_DISMISS_BUTTON_String
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(closeButtonTapped:)];
    }
}

- (void)updateTitleText
{
    self.title = [NSString stringWithFormat:@"%lu / %lu",
                  (unsigned long)(self.currentPage + 1),
                  (unsigned long)(self.imagesURLArray.count)];
}

- (void)scrollToCurrentIndexByCurrentSize:(CGSize)size animated:(BOOL)animated
{
    CGFloat contentOffset_x = self.currentPage * (size.width + k_ACIB_PageGap);
    CGPoint point = CGPointMake(contentOffset_x, 0);
    
    [self.collectionView setContentOffset:point animated:animated];
}

- (void)scrollToCurrentIndexAnimated:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}


#pragma mark -

- (id)initWithImagesURLArray:(NSArray *)imagesURLArray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
        self.title = @" ";
        self.currentPage = 0;
        self.fullscreenEnable = YES;
        self.isFullscreen = NO;
        self.imagesURLArray = imagesURLArray;
        
        if ([UIApplication sharedApplication].statusBarHidden)
        {
            self.statusBarHiddenInteger = 1;
        }
        else
        {
            self.statusBarHiddenInteger = 0;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    
    [self createSubviews];
    
    [self checkPushOrPresent];
    
    [self addFullscreenModeNotificationObserver];
}

- (void)createSubviews
{
    self.portraitLayout = [[ACImageBrowserPortraitLayout alloc] init];
    self.landscapeLayout = [[ACImageBrowserLandscapeLayout alloc] init];
    
    UICollectionViewFlowLayout *currentLayout = self.portraitLayout;
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height);
    

    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        currentLayout = self.landscapeLayout;
        if (k_ACIBU_OSVersion < 8.0f)
        {
            size = CGSizeMake([UIScreen mainScreen].bounds.size.height,
                              [UIScreen mainScreen].bounds.size.width);
        }
    }
    
    
    CGRect rect = CGRectMake(0,
                             0,
                             size.width + k_ACIB_PageGap,
                             size.height);
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect
                                             collectionViewLayout:currentLayout];
    
    [self.collectionView registerClass:[ACImageBrowserCell class]
            forCellWithReuseIdentifier:ACImageBrowserCellItemIdentifier];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.pagingEnabled = YES;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    
    [self.view addSubview:self.collectionView];
    self.collectionView.alpha = 1.0f;
    self.collectionView.hidden = NO;
    
    
    //-- dirty solution to fix ugly rotate animation ----------------------------------------------------
    // image view
    self.uglyMaskIV = [[UIImageView alloc] init];
    self.uglyMaskIV.frame = self.view.bounds;
    self.uglyMaskIV.contentMode = UIViewContentModeScaleAspectFit;
    self.uglyMaskIV.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    self.uglyMaskIV.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    [self.view addSubview:self.uglyMaskIV];
    self.uglyMaskIV.alpha = 0.0f;
    self.uglyMaskIV.hidden = YES;
    
    // progress view
    CGFloat progressView_h = 2.0f;
    CGFloat progressView_x = (self.view.bounds.size.width - k_ACZISV_progress_width) / 2.0f;
    CGFloat progressView_y = (self.view.bounds.size.height - progressView_h) / 2.0f;
    self.uglyMaskPV = [[UIProgressView alloc] initWithFrame:CGRectMake(progressView_x,
                                                                       progressView_y,
                                                                       k_ACZISV_progress_width,
                                                                       progressView_h)];
    self.uglyMaskPV.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    self.uglyMaskPV.progress = 0.0f;
    self.uglyMaskPV.userInteractionEnabled = NO;
    [self.view addSubview:self.uglyMaskPV];
    self.uglyMaskPV.alpha = 0.0f;
    self.uglyMaskPV.hidden = YES;
    //------------------------------------------------------------------------------------------------//
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTitleText];
    
    [self scrollToCurrentIndexAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //NSLog(@"%@", NSStringFromCGSize(self.collectionView.contentSize));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //clear memory cache
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isRoating)
    {
        // Calculate current page
        CGRect visibleBounds = scrollView.bounds;
        NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
        if (index < 0)
        {
            index = 0;
        }
        if (index > self.imagesURLArray.count - 1)
        {
            index = self.imagesURLArray.count - 1;
        }
        self.currentPage = index;
        [self updateTitleText];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesURLArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ACImageBrowserCell *cell =
    (ACImageBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ACImageBrowserCellItemIdentifier
                                                                    forIndexPath:indexPath];

    if (indexPath.section == 0)
    {
        cell.imageBrowser = self;

        [cell configCellImageByURL:self.imagesURLArray[indexPath.item]
                            atItem:indexPath.item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"tap item at index=%ld", (long)indexPath.row);
    
}

#pragma mark - Rotate

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
//    [UIView animateWithDuration:0.01 animations:^{
//        self.collectionView.alpha = 0.0f;
//    }];
    self.isRoating = YES;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
    //-- dirty solution to fix ugly rotate animation ----------------------------------------------------
    self.collectionView.alpha = 0.0f;
    self.collectionView.hidden = YES;
    //------------------------------------------------------------------------------------------------//
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    //-- dirty solution to fix ugly rotate animation ----------------------------------------------------
    ACImageBrowserCell *cell =
    (ACImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    ACZoomableImageScrollView *zoomableImageScrollView = cell.zoomableImageScrollView;
    if (zoomableImageScrollView.isLoaded)
    {
        UIImage *image = zoomableImageScrollView.imageView.image;
        
        CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height);
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if (k_ACIBU_OSVersion < 8.0f)
            {
                size = CGSizeMake([UIScreen mainScreen].bounds.size.height,
                                  [UIScreen mainScreen].bounds.size.width);
            }
        }
        
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        BOOL overWidth = imageWidth > size.width;
        BOOL overHeight = imageHeight > size.height;
        
        CGSize fitSize = CGSizeMake(imageWidth, imageHeight);
        if (overWidth && overHeight)
        {
            CGFloat timesThanScreenWidth = (imageWidth / size.width);
            if (!((imageHeight / timesThanScreenWidth) > size.height))
            {
                fitSize.width = size.width;
                fitSize.height = imageHeight / timesThanScreenWidth;
            }
            else
            {
                CGFloat timesThanScreenHeight = (imageHeight / size.height);
                fitSize.width = imageWidth / timesThanScreenHeight;
                fitSize.height = size.height;
            }
        }
        else if (overWidth && !overHeight)
        {
            CGFloat timesThanFrameWidth = (imageWidth / size.width);
            fitSize.width = size.width;
            fitSize.height = imageHeight / timesThanFrameWidth;
        }
        else if (overHeight && !overWidth)
        {
            fitSize.height = size.height;
        }
        
        self.uglyMaskIV.alpha = 1.0f;
        self.uglyMaskIV.hidden = NO;
        
        // rotation animation
        [UIView animateWithDuration:duration animations:^{
            self.uglyMaskIV.bounds = CGRectMake(0, 0, fitSize.width, fitSize.height);
        } completion:^(BOOL finished) {
            
        }];
        
        self.uglyMaskIV.image = image;
    }
    else
    {
        self.uglyMaskPV.progress = zoomableImageScrollView.progressView.progress;
        self.uglyMaskPV.alpha = 1.0f;
        self.uglyMaskPV.hidden = NO;
    }
    //------------------------------------------------------------------------------------------------//
    
    // pack up info
    NSMutableDictionary *notificationObject = [[NSMutableDictionary alloc] initWithCapacity:1];
    id interfaceOrientation = [NSNumber numberWithInteger:toInterfaceOrientation];
    id durationTime = [NSNumber numberWithDouble:duration];
    notificationObject[k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey] = interfaceOrientation;
    notificationObject[k_ACIBU_WillRotateNotificationInfoDurationTimekey] = durationTime;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height);
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        if (k_ACIBU_OSVersion < 8.0f)
        {
            size = CGSizeMake([UIScreen mainScreen].bounds.size.height,
                              [UIScreen mainScreen].bounds.size.width);
        }
        [self.collectionView setCollectionViewLayout:self.landscapeLayout animated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:k_ACIBU_WillRotateNotificationName
                                                            object:notificationObject];
    }
    else
    {
        [self.collectionView setCollectionViewLayout:self.portraitLayout animated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:k_ACIBU_WillRotateNotificationName
                                                            object:notificationObject];
    }
    
    // rotation animation
    [UIView animateWithDuration:duration animations:^{
        self.collectionView.frame = CGRectMake(0,
                                               0,
                                               size.width + k_ACIB_PageGap,
                                               size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    //[self scrollToCurrentIndexAnimated:NO];
    [self scrollToCurrentIndexByCurrentSize:size animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [UIView animateWithDuration:0.01f animations:^{
//        self.collectionView.alpha = 1.0f;
//    }];
    self.isRoating = NO;
    
    //-- dirty solution to fix ugly rotate animation ----------------------------------------------------
    self.uglyMaskIV.alpha = 0.0f;
    self.uglyMaskIV.hidden = YES;
    self.uglyMaskPV.alpha = 0.0f;
    self.uglyMaskPV.hidden = YES;
    
    self.collectionView.alpha = 1.0f;
    self.collectionView.hidden = NO;
    //------------------------------------------------------------------------------------------------//
}


#pragma mark - FullscreenMode NSNotification

- (void)fullscreenMode:(NSNotification*)notification
{
    NSString *notificationObject = notification.object;
    
    BOOL wantFullscreen = NO;
    
    if ([notificationObject isEqualToString:k_ACIBU_WantFullscreenYES])
    {
        wantFullscreen = YES;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:wantFullscreen withAnimation:UIStatusBarAnimationSlide];
    }
    
    [self.navigationController setNavigationBarHidden:wantFullscreen animated:YES];
    
    if (wantFullscreen)
    {
        [UIView animateWithDuration:k_ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
            self.uglyMaskIV.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
            self.isFullscreen = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:k_ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
            self.uglyMaskIV.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
            self.isFullscreen = NO;
        }];
    }
}

- (void)addFullscreenModeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fullscreenMode:)
                                                 name:k_ACIBU_FullscreenNotificationName
                                               object:nil];
}

- (void)removeFullscreenModeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - dealloc

-(void)dealloc
{
    // clear memory
    [[SDImageCache sharedImageCache] clearMemory];
    [self removeFullscreenModeNotificationObserver];
}

@end
