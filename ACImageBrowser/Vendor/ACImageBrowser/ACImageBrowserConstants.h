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



#endif
