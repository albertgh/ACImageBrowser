//
//  ACZoomableImageScrollView.m
//
//  Created by Albert Chu on 14/7/24.
//

#import "ACZoomableImageScrollView.h"

#import "ACImageBrowserConstants.h"
#import "ACImageBrowser.h"
#import "ACImageBrowserCell.h"

#import "UIImageView+WebCache.h"


@interface ACZoomableImageScrollView ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end


@implementation ACZoomableImageScrollView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self addRotateNotificationObserver];
        
        self.zoomScale = 1.0;
        self.bouncesZoom = YES;
        
        self.delegate = self;
        
        self.scrollEnabled = YES;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        //self.alwaysBounceVertical = YES;
        
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        
        self.isLoaded = NO;
        
        [self createSubview];
    }
    return self;
}

#pragma mark - dealloc

-(void)dealloc {
    [self removeRotateNotificationObserver];
}

#pragma mark - Config Image

- (void)configImageByURL:(NSURL *)url {
    //NSLog(@"%@", url);
    
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    // check local or network
    NSString *pathHead = [[url absoluteString] substringToIndex:4];
    if ([pathHead isEqualToString:ACIB_PathHead_FileString]) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.imageView.image = image;
        }
        else {
            UIImage *errorImage =
            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                              pathForResource:@"error_x" ofType:@"png"]];
            self.imageView.image = errorImage;
        }
        [self fitImageViewFrameByImageSize:self.imageView.image.size centerPoint:centerPoint];
        
    }
    else if ([[pathHead lowercaseString] isEqualToString:ACIB_PathHead_HTTPString]) {
        NSString *beginDownloadImageURLString = [url.absoluteString copy];
        
        __weak __typeof(self)weakSelf = self;
        self.webImageOperation =
        [[SDWebImageManager sharedManager]
         downloadImageWithURL:url
         options:SDWebImageRetryFailed | SDWebImageContinueInBackground
         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             strongSelf.progressView.alpha = 1.0;
             strongSelf.progressView.hidden = NO;
             strongSelf.progressView.progress = 0.0;
             if (strongSelf.imageURLString && [beginDownloadImageURLString isEqualToString:strongSelf.imageURLString]) {
                 strongSelf.progressView.progress = ((float)receivedSize / expectedSize);
             }
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (strongSelf.imageURLString && [beginDownloadImageURLString isEqualToString:strongSelf.imageURLString]) {
                     strongSelf.progressView.alpha = 0.0;
                     strongSelf.progressView.hidden = YES;
                     if (image && !error && finished) {
                         strongSelf.imageView.image = image;
                     } else {
                         UIImage *errorImage =
                         [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                           pathForResource:@"error_x" ofType:@"png"]];
                         strongSelf.imageView.image = errorImage;
                     }
                     [strongSelf fitImageViewFrameByImageSize:weakSelf.imageView.image.size centerPoint:centerPoint];
                     strongSelf.isLoaded = YES;
                 }
             });
         }];
    }
}

#pragma mark - Calculate ImageView frame

- (void)fitImageViewFrameByImageSize:(CGSize)size centerPoint:(CGPoint)center {
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    // zoom back first
    if (self.zoomScale != 1.0) {
        [self zoomBackWithCenterPoint:center animated:NO];
    }
    
    CGFloat scale_max = 1.0 * ACZISV_zoom_bigger;
    CGFloat scale_mini = 1.0;
    
    self.maximumZoomScale = 1.0 * ACZISV_zoom_bigger;
    self.minimumZoomScale = 1.0;
    
    BOOL overWidth = imageWidth > self.bounds.size.width;
    BOOL overHeight = imageHeight > self.bounds.size.height;
    
    CGSize fitSize = CGSizeMake(imageWidth, imageHeight);
    
    if (overWidth && overHeight) {
        // fit by image width first if (height / times) still
        // bigger than self.bound.size.width
        // Then fit by height instead
        CGFloat timesThanScreenWidth = (imageWidth / self.bounds.size.width);
        
        if (!((imageHeight / timesThanScreenWidth) > self.bounds.size.height)) {
            scale_max =  timesThanScreenWidth * ACZISV_zoom_bigger;
            fitSize.width = self.bounds.size.width;
            fitSize.height = imageHeight / timesThanScreenWidth;
        }
        else {
            CGFloat timesThanScreenHeight = (imageHeight / self.bounds.size.height);
            scale_max =  timesThanScreenHeight * ACZISV_zoom_bigger;
            fitSize.width = imageWidth / timesThanScreenHeight;
            fitSize.height = self.bounds.size.height;
        }
    }
    else if (overWidth && !overHeight) {
        CGFloat timesThanFrameWidth = (imageWidth / self.bounds.size.width);
        scale_max =  timesThanFrameWidth * ACZISV_zoom_bigger;
        fitSize.width = self.bounds.size.width;
        fitSize.height = imageHeight / timesThanFrameWidth;
    }
    else if (overHeight && !overWidth) {
        fitSize.height = self.bounds.size.height;
    }
    
    self.imageView.frame = CGRectMake((center.x - fitSize.width / 2),
                                      (center.y - fitSize.height / 2),
                                      fitSize.width,
                                      fitSize.height);
    
    self.contentSize = CGSizeMake(fitSize.width, fitSize.height);
    
    self.maximumZoomScale = scale_max;
    self.minimumZoomScale = scale_mini;
}

#pragma mark - Orientation func

- (void)orientationChange:(NSNotification*)notification {
    CGSize size = self.bounds.size;
    CGPoint centerPoint = CGPointMake(size.width / 2, size.height / 2);
    [self fitImageViewFrameByImageSize:self.imageView.image.size centerPoint:centerPoint];
}

#pragma mark - add orientation notification listener

- (void)addRotateNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)removeRotateNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - subview

- (void)createSubview {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    self.imageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    self.imageView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer * doubleTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTapGesture:)];
    doubleTapGesture.numberOfTouchesRequired = 1;
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [self.imageView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer * singleTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTapGesture:)];
    singleTapGesture.delegate= self;
    singleTapGesture.numberOfTouchesRequired = 1;
    singleTapGesture.numberOfTapsRequired = 1;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
    
    [self addSubview:self.imageView];
    
    //-- progress view
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    
    self.progressView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    self.progressView.userInteractionEnabled = NO;
    [self addSubview:self.progressView];
    self.progressView.alpha = 0.0;
    self.progressView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // flag: image can't zoom by this
    //NSLog(@"layout size%@", NSStringFromCGSize(self.bounds.size));
    //CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    //[self fitImageViewFrameByImageSize:self.imageView.image.size centerPoint:centerPoint];
    
    CGFloat progressView_margin = 36.0;
    CGFloat progressView_w = self.bounds.size.width - progressView_margin * 2;
    CGFloat progressView_h = 2.0;
    CGFloat progressView_x = progressView_margin;
    CGFloat progressView_y = (self.bounds.size.height - progressView_h) / 2;
    self.progressView.frame = CGRectMake(progressView_x,
                                         progressView_y,
                                         progressView_w,
                                         progressView_h);
    
    
    if (self.imageBrowser.isFullscreen) {
        self.backgroundColor = k_ACIB_isFullscreen_BGColor;
        self.imageView.backgroundColor = k_ACIB_isFullscreen_BGColor;
    }
    else {
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        self.imageView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    }
}

#pragma mark - Scale

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2);
    
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX =
    (self.bounds.size.width > self.contentSize.width) ?
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY =
    (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
    
    self.imageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                        self.contentSize.height * 0.5 + offsetY);
}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    //NSLog(@"%f", scale);
//}

#pragma mark - Zoom Action

- (void)zoomBackWithCenterPoint:(CGPoint)center animated:(BOOL)animated {
    CGRect rect = [self zoomRectForScale:1.0 withCenter:center];
    [self zoomToRect:rect animated:animated];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.numberOfTapsRequired == 2) {
        // don't know why some photo just can not zoom to maximumZoomScale
        BOOL range_left = self.zoomScale > (self.maximumZoomScale * 0.9);
        BOOL range_right = self.zoomScale <= self.maximumZoomScale;
        
        if (range_left && range_right) {
            CGRect rect = [self zoomRectForScale:self.minimumZoomScale
                                      withCenter:[tapGesture locationInView:tapGesture.view]];
            [self zoomToRect:rect animated:YES];
        }
        else {
            CGRect rect = [self zoomRectForScale:self.maximumZoomScale
                                      withCenter:[tapGesture locationInView:tapGesture.view]];
            [self zoomToRect:rect animated:YES];
        }
    }
    else if (tapGesture.numberOfTapsRequired == 1) {
        //-- fullscreen mode switch ----------------------------------------------------------------
        if (!self.imageBrowser.isRoating) {
            if (self.imageBrowser.fullscreenEnable) {
                if (self.imageBrowser.isFullscreen) {
                    self.userInteractionEnabled = NO;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ACIBU_FullscreenNotificationName
                                                                        object:ACIBU_WantFullscreenNO];
                    
                    [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
                        self.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
                        self.imageView.layer.backgroundColor = k_ACIB_isNotFullscreen_BGColor.CGColor;
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                    }];
                }
                else {
                    self.userInteractionEnabled = NO;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ACIBU_FullscreenNotificationName
                                                                        object:ACIBU_WantFullscreenYES];
                    
                    [UIView animateWithDuration:ACIBU_BGColor_AnimationDuration animations:^{
                        self.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
                        self.imageView.layer.backgroundColor = k_ACIB_isFullscreen_BGColor.CGColor;
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                    }];
                }
            }
        }
        //----------------------------------------------------------------------------------------//
    }
}

@end
