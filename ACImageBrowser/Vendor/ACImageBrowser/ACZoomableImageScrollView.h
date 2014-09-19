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

@property (nonatomic, retain) UIImageView                   *imageView;

@property (nonatomic, weak) id <SDWebImageOperation>        webImageOperation;

@property (nonatomic, retain) UIProgressView                *progressView;

@property (nonatomic, assign) BOOL                          isLoaded;

- (void)configImageByURL:(NSURL *)url
                  atItem:(NSInteger)item;

@end
