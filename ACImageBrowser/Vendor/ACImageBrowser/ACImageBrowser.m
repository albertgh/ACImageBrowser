//
//  ACImageBrowser.m
//
//  Created by Albert Chu on 14/8/11.
//

#import "ACImageBrowser.h"
#import "ACImageBrowserLayout.h"
#import "ACImageBrowserCell.h"
#import "ACZoomableImageScrollView.h"

#import "UIImageView+WebCache.h"

#import "AssetsLibrary/AssetsLibrary.h"

@interface ACImageBrowser () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) ACImageBrowserLayout              *browserLayout;

@property (nonatomic, retain) UICollectionView                  *collectionView;
@property (nonatomic, retain) NSMutableArray                    *imagesURLArray;

@end


static NSString *ACImageBrowserCellItemIdentifier               = @"ACImageBrowserCellItemIdentifier";


@implementation ACImageBrowser

#pragma mark - Init

- (id)initWithImagesURLArray:(NSMutableArray *)imagesURLArray {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"";
        
        self.imagesURLArray = imagesURLArray;
        _currentPage = 0;
        
        self.fullscreenEnable = YES;
        _isFullscreen = NO;
    }
    return self;
}

#pragma mark - Public

- (void)setPageIndex:(NSUInteger)index {
    // validate
    NSUInteger photoCount = self.imagesURLArray.count;
    if (photoCount == 0) {
        index = 0;
    }
    else {
        if (index >= photoCount) {
            index = self.imagesURLArray.count - 1;
        }
    }
    _currentPage = index;
}

- (void)willAnimateToFullscreenMode {
    dispatch_async(dispatch_get_main_queue(), ^{
        _isFullscreen = YES;
        [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
        }];
    });
}

- (void)willAnimateToNormalMode {
    dispatch_async(dispatch_get_main_queue(), ^{
        _isFullscreen = NO;
        [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
        }];
    });
}

#pragma mark - Delete And Save

- (void)deletePhotoAtCurrentIndex:(void (^)(void))deletingBlock
                          success:(void (^)(BOOL finished))finishedBlock {
    [self.collectionView
     performBatchUpdates:^{
         // deleting data
         [self.imagesURLArray removeObjectAtIndex:self.currentPage];
         
         // deleting Cell
         NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
         [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:self.currentPage
                                                           inSection:0]];
         
         [self.collectionView deleteItemsAtIndexPaths:arrayWithIndexPaths];
         
         if (deletingBlock) {
             deletingBlock();
         }
     }
     completion:^(BOOL finished) {
         if (self.imagesURLArray.count == 0) {
             [self dismissViewControllerAnimated:YES completion:^{
             }];
         }
         else if ((self.imagesURLArray.count - 1) < self.currentPage) {
             [self setPageIndex:(self.imagesURLArray.count - 1)];
             [self updateTitleText];
         }
         else {
             [self updateTitleText];
         }
         
         if (finishedBlock) {
             finishedBlock(finished);
         }
     }];
}

- (void)savePhotoToCameraRollProgress:(void (^)(CGFloat percent))progressBlock
                              success:(void (^)(BOOL success))successBlock {
    [[SDWebImageManager sharedManager]
     downloadImageWithURL:self.imagesURLArray[self.currentPage]
     options:SDWebImageRetryFailed
     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
         if (progressBlock) {
             progressBlock( ((float)receivedSize / expectedSize) );
         }
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
         if (finished && !error && image) {
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             // Request to save the image to camera roll
             [library
              writeImageToSavedPhotosAlbum:[image CGImage]
              orientation:(ALAssetOrientation)image.imageOrientation
              completionBlock:^(NSURL *assetURL, NSError *error){
                 if (!error) {
                     if (successBlock) {
                         successBlock(YES);
                     }
                 }
                 else {
                     if (successBlock) {
                         successBlock(NO);
                     }
                 }
             }];
         }
         else {
             if (successBlock) {
                 successBlock(NO);
             }
         }
     }];
}

#pragma mark - Action 

- (void)closeButtonTapped:(UIButton *)sender {
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }

    if ([self.delegate respondsToSelector:@selector(dismissAtIndex:)]) {
        [self.delegate dismissAtIndex:self.currentPage];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)updateTitleText {
    self.title = [NSString stringWithFormat:@"%@ / %@",
                  @(self.currentPage + 1),
                  @(self.imagesURLArray.count)];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    CGFloat contentOffset_x = index * (self.view.bounds.size.width + ACIB_PageGap);
    CGPoint point = CGPointMake(contentOffset_x, 0.0);
    [self.collectionView setContentOffset:point animated:animated];
}

- (void)addCloseButton {
    if (self.navigationController.viewControllers[0] == self) {
        //NSLog(@"present");
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Close", nil)
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(closeButtonTapped:)];
    }
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    
    [self createSubviews];
    [self addCloseButton];
    [self addFullscreenModeNotificationObserver];
}

- (void)createSubviews {
    CGRect collectionViewFrame = CGRectMake(0.0,
                                            0.0,
                                            self.view.bounds.size.width + ACIB_PageGap,
                                            self.view.bounds.size.height);
    self.browserLayout = [[ACImageBrowserLayout alloc] initWithItemSize:self.view.bounds.size];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame
                                             collectionViewLayout:self.browserLayout];
    self.collectionView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    
    [self.collectionView registerClass:[ACImageBrowserCell class]
            forCellWithReuseIdentifier:ACImageBrowserCellItemIdentifier];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.pagingEnabled = YES;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    
    [self.view addSubview:self.collectionView];
    
    self.collectionView.alpha = 1.0;
    self.collectionView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateTitleText];
    
    [self scrollToIndex:self.currentPage animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSLog(@"%@", NSStringFromCGSize(self.collectionView.contentSize));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //clear memory cache
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isRoating) {
        // Calculate current page
        CGRect visibleBounds = scrollView.bounds;
        NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
        if (index < 0) {
            index = 0;
        }
        if (index > self.imagesURLArray.count - 1) {
            index = self.imagesURLArray.count - 1;
        }
        _currentPage = index;
        [self updateTitleText];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.imagesURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACImageBrowserCell *cell =
    (ACImageBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ACImageBrowserCellItemIdentifier
                                                                    forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.imageBrowser = self;
        
        [cell configCellImageByURL:self.imagesURLArray[indexPath.item]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"tap item at index=%ld", (long)indexPath.row);
//}

#pragma mark - Rotate

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    _isRoating = YES;

//    [UIView animateWithDuration:0.01 animations:^{
//        self.collectionView.alpha = 0.0f;
//    }];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } else {
        if (!self.isFullscreen) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.browserLayout = nil;
    self.browserLayout = [[ACImageBrowserLayout alloc] initWithItemSize:self.view.bounds.size];
    [self.collectionView setCollectionViewLayout:self.browserLayout animated:NO];

    // rotation animation
    [UIView animateWithDuration:duration animations:^{
        self.collectionView.frame = CGRectMake(0,
                                               0,
                                               self.view.bounds.size.width + ACIB_PageGap,
                                               self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [self scrollToIndex:self.currentPage animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _isRoating = NO;
    
//    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentPage inSection:0];
//    [self.collectionView reloadItemsAtIndexPaths:@[currentIndexPath]];
    
//    [UIView animateWithDuration:0.01f animations:^{
//        self.collectionView.alpha = 1.0f;
//    }];
}

#pragma mark - FullscreenMode NSNotification

- (void)fullscreenMode:(NSNotification*)notification {
    NSString *notificationObject = notification.object;
    
    BOOL wantFullscreen = NO;
    
    if ([notificationObject isEqualToString:ACIBU_WantFullscreenYES]) {
        wantFullscreen = YES;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:wantFullscreen withAnimation:UIStatusBarAnimationSlide];
    }
    
    [self.navigationController setNavigationBarHidden:wantFullscreen animated:YES];
    
    if (wantFullscreen) {
        [self willAnimateToFullscreenMode];
    } else {
        [self willAnimateToNormalMode];
    }
}


- (void)addFullscreenModeNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fullscreenMode:)
                                                 name:ACIBU_FullscreenNotificationName
                                               object:nil];
}

- (void)removeFullscreenModeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - dealloc

-(void)dealloc {
    // clear memory
    [[SDImageCache sharedImageCache] clearMemory];
    [self removeFullscreenModeNotificationObserver];
}

@end
