//
//  ACImageBrowserUtils.h
//
//  Created by Albert Chu on 14/8/14.
//

#import <Foundation/Foundation.h>


#define k_ACIBU_OSVersion                           ([[[UIDevice currentDevice] systemVersion] floatValue])


#define k_ACIBU_BGColor_AnimationDuration           0.28f


#define k_ACIBU_WillRotateNotificationName          @"k_ACIBU_WillRotateNotificationName"
#define k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey \
@"k_ACIBU_WillRotateNotificationInfoInterfaceOrientationKey"
#define k_ACIBU_WillRotateNotificationInfoDurationTimekey \
@"k_ACIBU_WillRotateNotificationInfoDurationTimekey"


#define k_ACIBU_FullscreenNotificationName          @"k_ACIBU_FullscreenNotificationName"
#define k_ACIBU_WantFullscreenYES                   @"k_ACIBU_FullscreenYES"
#define k_ACIBU_WantFullscreenNO                    @"k_ACIBU_FullscreenNO"


#define k_ACIBU_ImageType_bmp                       @"ACImageType_bmp"
#define k_ACIBU_ImageType_jpg                       @"ACImageType_png"
#define k_ACIBU_ImageType_png                       @"ACImageType_jpg"
#define k_ACIBU_ImageType_gif                       @"ACImageType_gif"
#define k_ACIBU_ImageType_others                    @"ACImageType_others"

#define k_ACIB_PathHead_FileString                  @"file"
#define k_ACIB_PathHead_HTTPString                  @"http"


@interface ACImageBrowserUtils : NSObject

@property (nonatomic, assign) NSInteger             currentPage;
@property (nonatomic, assign) BOOL                  isFullscreen;

+ (instancetype)sharedInstance;

- (NSString *)imageDataType:(NSData *)data;

@end
