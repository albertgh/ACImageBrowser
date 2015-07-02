//
//  ACZoomableImageScrollView.h
//
//  Created by Albert Chu on 14/7/24.
//

#import <UIKit/UIKit.h>

#import "SDWebImageOperation.h"

@class ACImageBrowser;

@interface ACZoomableImageScrollView : UIScrollView

@property (nonatomic, weak) ACImageBrowser                  *imageBrowser;

@property (nonatomic, strong) UIImageView                   *imageView;

@property (nonatomic, strong) NSString                      *imageURLString;

@property (nonatomic, weak) id <SDWebImageOperation>        webImageOperation;

@property (nonatomic, strong) UIProgressView                *progressView;

@property (nonatomic) BOOL                                  isLoaded;

- (void)configImageByURL:(NSURL *)url;

@end
