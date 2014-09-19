//
//  ACZoomableImageScrollView.m
//
//  Created by Albert Chu on 14/7/24.
//

#import "ACZoomableImageScrollView.h"

#import "ACImageBrowserConstants.h"
#import "ACImageBrowser.h"

#import "UIImageView+WebCache.h"


@interface ACZoomableImageScrollView ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end


@implementation ACZoomableImageScrollView


#pragma mark - Config Image

- (void)configImageByURL:(NSURL *)url
                  atItem:(NSInteger)item
{
    //NSURL *test = [[NSBundle mainBundle] URLForResource:@"test_long" withExtension:@"gif"];
    
    //DLog(@"%@", url);
    
    // check local or network
    NSString *pathHead = [[url absoluteString] substringToIndex:4];
    if ([pathHead isEqualToString:k_ACIB_PathHead_FileString])
    {
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
        if (image)
        {
            [self fitImageViewFrameByImageSize:image.size centerPoint:centerPoint];
            self.imageView.image = image;
        }
        else
        {
            UIImage *errorImage =
            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                              pathForResource:@"error_x" ofType:@"png"]];
            
            [self fitImageViewFrameByImageSize:errorImage.size centerPoint:centerPoint];
            self.imageView.image = errorImage;
        }
    }
    else if ([[pathHead lowercaseString] isEqualToString:k_ACIB_PathHead_HTTPString])
    {
        CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
        
        self.progressView.alpha = 1.0f;
        self.progressView.hidden = NO;
        
        self.progressView.center = centerPoint;
        
        __weak UIImageView *weakImageView = self.imageView;
        
        __weak UIProgressView *weakProgressView = self.progressView;
        
        __weak id <SDWebImageOperation> weakOperation = self.webImageOperation;
        weakOperation =
        [[SDWebImageManager sharedManager]
         downloadImageWithURL:url
         options:SDWebImageRetryFailed | SDWebImageContinueInBackground
         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
             
             if (ABS(item - self.imageBrowser.currentPage) == 1
                 || (item - self.imageBrowser.currentPage) == 0)
             {
                 weakProgressView.progress = ((float)receivedSize / expectedSize);
             }
             
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             
             //DLog(@"%lu === %lu", item, [ACImageBrowserUtils sharedInstance].currentPage);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 // download image request maybe calls by current cell
                 // or next or prev by scrolling
                 if (ABS(item - self.imageBrowser.currentPage) == 1
                     || (item - self.imageBrowser.currentPage) == 0)
                 {
                     //DLog(@"should finish");
                     weakProgressView.alpha = 0.0f;
                     weakProgressView.hidden = YES;
                     
                     if (!error && finished)
                     {
                         weakImageView.image = image;
                         
                         [self fitImageViewFrameByImageSize:image.size centerPoint:centerPoint];
                     }
                     else
                     {
                         //NSLog(@"erro");
                         UIImage *errorImage =
                         [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                           pathForResource:@"error_x" ofType:@"png"]];
                         CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
                         [self fitImageViewFrameByImageSize:errorImage.size centerPoint:centerPoint];
                         weakImageView.image = errorImage;
                     }
                     
                     self.isLoaded = YES;
                     
                 }
             });
             
         }];
                
    }
    
}


#pragma mark - Calculate ImageView frame

- (void)fitImageViewFrameByImageSize:(CGSize)size centerPoint:(CGPoint)center
{
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    
    // 缩回小图
    if (self.zoomScale != 1.0f)
    {
        [self zoomBackWithCenterPoint:center animated:NO];
    }
    
    CGFloat scale_max = 1.0f * k_ACZISV_zoom_bigger;
    CGFloat scale_mini = 1.0f;
    
    self.maximumZoomScale = 1.0 * k_ACZISV_zoom_bigger;
    self.minimumZoomScale = 1.0;
    
    BOOL overWidth = imageWidth > self.bounds.size.width;
    BOOL overHeight = imageHeight > self.bounds.size.height;
    
    
    CGSize fitSize = CGSizeMake(imageWidth, imageHeight);
    
    
    if (overWidth && overHeight)
    {
        // fit by image width first if (height / times) still
        // bigger than self.bound.size.width
        // Then fit by height instead
        CGFloat timesThanScreenWidth = (imageWidth / self.bounds.size.width);
        
        if (!((imageHeight / timesThanScreenWidth) > self.bounds.size.height))
        {
            scale_max =  timesThanScreenWidth * k_ACZISV_zoom_bigger;
            fitSize.width = self.bounds.size.width;
            fitSize.height = imageHeight / timesThanScreenWidth;
        }
        else
        {
            CGFloat timesThanScreenHeight = (imageHeight / self.bounds.size.height);
            scale_max =  timesThanScreenHeight * k_ACZISV_zoom_bigger;
            fitSize.width = imageWidth / timesThanScreenHeight;
            fitSize.height = self.bounds.size.height;
        }
    }
    else if (overWidth && !overHeight)
    {
        CGFloat timesThanFrameWidth = (imageWidth / self.bounds.size.width);
        scale_max =  timesThanFrameWidth * k_ACZISV_zoom_bigger;
        fitSize.width = self.bounds.size.width;
        fitSize.height = imageHeight / timesThanFrameWidth;
    }
    else if (overHeight && !overWidth)
    {
        fitSize.height = self.bounds.size.height;
    }
    
    self.imageView.bounds = CGRectMake(0, 0, fitSize.width, fitSize.height);
    self.imageView.center = center;
    self.contentSize = CGSizeMake(fitSize.width, fitSize.height);
    
    self.maximumZoomScale = scale_max;
    self.minimumZoomScale = scale_mini;
}

#pragma mark - Orientation func

- (void)orientationChange:(NSNotification*)notification
{
    NSDictionary *notificationObject = notification.object;
    
    UIInterfaceOrientation toInterfaceOrientation =
    (UIInterfaceOrientation)[notificationObject[k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey] integerValue];
    
    NSTimeInterval duration =
    (NSTimeInterval)[notificationObject[k_ACIBU_WillRotateNotificationInfoDurationTimekey] doubleValue];
    
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
    
    CGPoint centerPoint = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    
    // rotation animation
    [UIView animateWithDuration:duration animations:^{
        // rest imageView
        [self fitImageViewFrameByImageSize:self.imageView.image.size centerPoint:centerPoint];
        // rest progressView
        self.progressView.center = centerPoint;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - add orientation notification listener

- (void)addRotateNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange:)
                                                 name:k_ACIBU_WillRotateNotificationName
                                               object:nil];
}

- (void)removeRotateNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - dealloc

-(void)dealloc
{
    [self removeRotateNotificationObserver];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageBrowser.isFullscreen)
    {
        self.backgroundColor = k_ACIB_isFullscreen_BGColor;
        self.imageView.backgroundColor = k_ACIB_isFullscreen_BGColor;
    }
    else
    {
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        self.imageView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    }
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self addRotateNotificationObserver];
        
        self.delegate = self;
        self.bouncesZoom = YES;
        
        self.scrollEnabled = YES;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        //self.alwaysBounceVertical = YES;
        
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        
        self.zoomScale = 1.0f;
        
        self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        
        [self createSubview];
    }
    return self;
}

- (void)createSubview
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = self.bounds;
    
    self.imageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    
    self.imageView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    doubleTapGesture.numberOfTouchesRequired = 1;
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [self.imageView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    singleTapGesture.delegate= self;
    singleTapGesture.numberOfTouchesRequired = 1;
    singleTapGesture.numberOfTapsRequired = 1;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
    
    [self addSubview:self.imageView];
    
    self.isLoaded = NO;
    
    //-- center ring
    CGFloat progressView_h = 2.0f;
    CGFloat progressView_x = (self.bounds.size.width - k_ACZISV_progress_width) / 2.0f;
    CGFloat progressView_y = (self.bounds.size.height - progressView_h) / 2.0f;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(progressView_x,
                                                                         progressView_y,
                                                                         k_ACZISV_progress_width,
                                                                         progressView_h)];
    
    self.progressView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    self.progressView.userInteractionEnabled = NO;
    [self addSubview:self.progressView];
    self.progressView.alpha = 0.0f;
    self.progressView.hidden = YES;
}


#pragma mark - Scale

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0f);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0f);
    
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX =
    (self.bounds.size.width > self.contentSize.width) ?
    (self.bounds.size.width - self.contentSize.width) * 0.5f : 0.0f;
    
    CGFloat offsetY =
    (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5f : 0.0f;
    
    self.imageView.center = CGPointMake(self.contentSize.width * 0.5f + offsetX,
                                        self.contentSize.height * 0.5f + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"%f", scale);
}

#pragma mark - Zoom Action

- (void)zoomBackWithCenterPoint:(CGPoint)center animated:(BOOL)animated
{
    CGRect rect = [self zoomRectForScale:1.0f withCenter:center];
    [self zoomToRect:rect animated:animated];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.numberOfTapsRequired == 2)
    {
        // don't know why some photo just can not zoom to maximumZoomScale
        BOOL range_left = self.zoomScale > (self.maximumZoomScale * 0.9f);
        BOOL range_right = self.zoomScale <= self.maximumZoomScale;
        
        if (range_left && range_right)
        {
            CGRect rect = [self zoomRectForScale:self.minimumZoomScale
                                      withCenter:[tapGesture locationInView:tapGesture.view]];
            [self zoomToRect:rect animated:YES];
        }
        else
        {
            CGRect rect = [self zoomRectForScale:self.maximumZoomScale
                                      withCenter:[tapGesture locationInView:tapGesture.view]];
            [self zoomToRect:rect animated:YES];
        }
    }
    else if (tapGesture.numberOfTapsRequired == 1)
    {
        if (self.imageBrowser.fullscreenEnable)
        {
            if (self.imageBrowser.isFullscreen)
            {
                self.userInteractionEnabled = NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:k_ACIBU_FullscreenNotificationName
                                                                    object:k_ACIBU_WantFullscreenNO];
                
                [UIView animateWithDuration:k_ACIBU_BGColor_AnimationDuration animations:^{
                    self.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
                    self.imageView.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
            }
            else
            {
                self.userInteractionEnabled = NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:k_ACIBU_FullscreenNotificationName
                                                                    object:k_ACIBU_WantFullscreenYES];
                
                [UIView animateWithDuration:k_ACIBU_BGColor_AnimationDuration animations:^{
                    self.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
                    self.imageView.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
            }
        }
    }
}


@end
