//
//  ACImageBrowserUtils.m
//
//  Created by Albert Chu on 14/8/14.
//

#import "ACImageBrowserUtils.h"

@implementation ACImageBrowserUtils

+ (instancetype)sharedInstance
{
    static ACImageBrowserUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ACImageBrowserUtils alloc] init];
        _sharedInstance.isFullscreen = NO;
        _sharedInstance.currentPage = 0;
    });
    return _sharedInstance;
}

#pragma mark - Type Util

- (NSString *)imageDataType:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return k_ACIBU_ImageType_jpg;
        case 0x42:
        case 0x4D:
            return k_ACIBU_ImageType_bmp;
        case 0x89:
            return k_ACIBU_ImageType_png;
        case 0x47:
            return k_ACIBU_ImageType_gif;
        case 0x49:
        default:
            return k_ACIBU_ImageType_others;
    }
}

@end
