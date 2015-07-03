//
//  ACImageBrowserConstants.h
//

#ifndef ACImageBrowserConstants_h
#define ACImageBrowserConstants_h


//-- Custom ----------------------------------------------------------------------------------------
#pragma mark - Custom

#define k_ACIB_isNotFullscreen_BGColor                                              \
[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1.0]

#define k_ACIB_isFullscreen_BGColor                                                 \
[UIColor colorWithRed:  0 / 255.0 green:  0 / 255.f blue:  0 / 255.0 alpha:1.0]


/** Gap between image */
static CGFloat const ACIB_PageGap                                                   = 40.0;

/** ZoomableImageScrollView can zoom to how much bigger than original image */
static CGFloat const ACZISV_zoom_bigger                                             = 1.618;


//------------------------------------------------------------------------------------------------//





//-- DO NOT CHANGE THESE ---------------------------------------------------------------------------
#define k_ACIB_PortraitPhoneSize                                                                    \
(                                                                                                   \
  ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)?                                    \
  (CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)):  \
  (                                                                                                 \
    (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?    \
    (CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)):\
    (CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)) \
  )                                                                                                 \
)


#define k_ACIBU_OSVersion                                   ([[[UIDevice currentDevice] systemVersion] floatValue])


static CGFloat const ACIBU_BGColor_AnimationDuration        = 0.28;

static NSString * const ACIBU_FullscreenNotificationName    = @"ACIBU_FullscreenNotificationName";
static NSString * const ACIBU_WantFullscreenYES             = @"ACIBU_WantFullscreenYES";
static NSString * const ACIBU_WantFullscreenNO              = @"ACIBU_WantFullscreenNO";

static NSString * const ACIB_PathHead_FileString            = @"file";
static NSString * const ACIB_PathHead_HTTPString            = @"http";
//------------------------------------------------------------------------------------------------//


#endif
