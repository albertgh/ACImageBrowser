//
//  ACImageBrowser.m
//
//  Created by Albert Chu on 14/8/11.
//

#import "ACImageBrowser.h"
#import "ACImageBrowserLayout.h"
#import "ACImageBrowserCell.h"
#import "ACZoomableImageScrollView.h"
#import "ACImageBrowserConstants.h"

#import "UIImageView+WebCache.h"


@interface ACImageBrowser ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, retain) ACImageBrowserLayout          *browserLayout;

@end


static NSString *ACImageBrowserCellItemIdentifier           = @"ACImageBrowserCellItemIdentifier";


@implementation ACImageBrowser

#pragma mark - Public

- (void)setPageIndex:(NSUInteger)index {
    // validate
    NSUInteger photoCount = self.imagesURLArray.count;
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = self.imagesURLArray.count - 1;
    }
    _currentPage = index;
}

- (void)updateTitleText {
    self.title = [NSString stringWithFormat:@"%lu / %lu",
                  (unsigned long)(self.currentPage + 1),
                  (unsigned long)(self.imagesURLArray.count)];
}

#pragma mark - Action 

- (void)closeButtonTapped:(UIButton *)sender {
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }

    if ([self.delegate respondsToSelector:@selector(dismissAtIndex:)]) {
        [self.delegate dismissAtIndex:self.currentPage];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)checkPushOrPresent {
    if (self.navigationController.viewControllers[0] == self) {
        //DLog(@"present");
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Close", nil)
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(closeButtonTapped:)];
    }
}

- (void)scrollToCurrentIndexByCurrentSize:(CGSize)size animated:(BOOL)animated {
    CGFloat contentOffset_x = self.currentPage * (size.width + ACIB_PageGap);
    CGPoint point = CGPointMake(contentOffset_x, 0);
    
    [self.collectionView setContentOffset:point animated:animated];
}

- (void)scrollToCurrentIndexAnimated:(BOOL)animated {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}


#pragma mark -

- (id)initWithImagesURLArray:(NSMutableArray *)imagesURLArray {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"";
        _currentPage = 0;
        self.fullscreenEnable = YES;
        _isFullscreen = NO;
        self.imagesURLArray = imagesURLArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    
    [self createSubviews];
    
    [self checkPushOrPresent];
    
    [self addFullscreenModeNotificationObserver];
}

- (void)createSubviews {
    CGSize size = self.view.bounds.size;
    
    CGRect rect = CGRectMake(0,
                             0,
                             size.width + ACIB_PageGap,
                             size.height);
    
    self.browserLayout = [[ACImageBrowserLayout alloc] initWithItemSize:size];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect
                                             collectionViewLayout:self.browserLayout];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateTitleText];
    
    [self scrollToCurrentIndexAnimated:NO];
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

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    for (UICollectionViewCell *cell in [self.collectionView visibleCells])
//    {
//        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return self.imagesURLArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACImageBrowserCell *cell =
    (ACImageBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ACImageBrowserCellItemIdentifier
                                                                    forIndexPath:indexPath];

    if (indexPath.section == 0) {
        cell.imageBrowser = self;

        [cell configCellImageByURL:self.imagesURLArray[indexPath.item]
                  inCollectionView:collectionView
                       atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"tap item at index=%ld", (long)indexPath.row);
    
}

#pragma mark - Rotate

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
//    [UIView animateWithDuration:0.01 animations:^{
//        self.collectionView.alpha = 0.0f;
//    }];
    _isRoating = YES;
    
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
    // pack up info
    NSMutableDictionary *notificationObject = [[NSMutableDictionary alloc] initWithCapacity:1];
    id interfaceOrientation = [NSNumber numberWithInteger:toInterfaceOrientation];
    id durationTime = [NSNumber numberWithDouble:duration];
    notificationObject[ACIBU_WillRotateNotificationInfoInterfaceOrientationKey] = interfaceOrientation;
    notificationObject[ACIBU_WillRotateNotificationInfoDurationTimekey] = durationTime;
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height);
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (k_ACIBU_OSVersion < 8.0f) {
            size = CGSizeMake([UIScreen mainScreen].bounds.size.height,
                              [UIScreen mainScreen].bounds.size.width);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ACIBU_WillRotateNotificationName
                                                            object:notificationObject];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ACIBU_WillRotateNotificationName
                                                            object:notificationObject];
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.browserLayout.itemSize = size;
    [self.collectionView setCollectionViewLayout:self.browserLayout animated:NO];
    
    // rotation animation
    [UIView animateWithDuration:duration animations:^{
        self.collectionView.frame = CGRectMake(0,
                                               0,
                                               size.width + ACIB_PageGap,
                                               size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [self scrollToCurrentIndexAnimated:NO];
    //[self scrollToCurrentIndexByCurrentSize:size animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [UIView animateWithDuration:0.01f animations:^{
//        self.collectionView.alpha = 1.0f;
//    }];
    _isRoating = NO;
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
        [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
            _isFullscreen = YES;
        }];
    } else {
        [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
            self.view.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
            self.collectionView.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
        } completion:^(BOOL finished) {
            _isFullscreen = NO;
        }];
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
