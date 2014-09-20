//
//  ACImageBrowserConstants.h
//

#ifndef ACImageBrowserConstants_h
#define ACImageBrowserConstants_h


//-- Custom ----------------------------------------------------------------------------------
#pragma mark - Custom

static NSString * const ACIB_DISMISS_BUTTON_String                                  = @"Close";


#define k_ACIB_isNotFullscreen_BGColor                                              \
[UIColor colorWithRed:255 / 255.f green:255 / 255.f blue:255 / 255.f alpha:1.0f]

#define k_ACIB_isFullscreen_BGColor                                                 \
[UIColor colorWithRed:0   / 255.f green:0   / 255.f blue:0   / 255.f alpha:1.0f]


/** Gap between image */
#define k_ACIB_PageGap                                                              40.0f

/** ZoomableImageScrollView can zoom to how much bigger than original image */
#define k_ACZISV_zoom_bigger                                                        1.618f

#define k_ACZISV_progress_width                                                     240.0f
//-------------------------------------------------------------------------------------------//





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


#define k_ACIBU_BGColor_AnimationDuration                   0.28f


#define k_ACIBU_WillRotateNotificationName                  @"k_ACIBU_WillRotateNotificationName"
#define k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey \
@"k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey"
#define k_ACIBU_WillRotateNotificationInfoDurationTimekey \
@"k_ACIBU_WillRotateNotificationInfoDurationTimekey"


#define k_ACIBU_FullscreenNotificationName                  @"k_ACIBU_FullscreenNotificationName"
#define k_ACIBU_WantFullscreenYES                           @"k_ACIBU_FullscreenYES"
#define k_ACIBU_WantFullscreenNO                            @"k_ACIBU_FullscreenNO"

#define k_ACIB_PathHead_FileString                          @"file"
#define k_ACIB_PathHead_HTTPString                          @"http"
//-------------------------------------------------------------------------------------------//



#endif
