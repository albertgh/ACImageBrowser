//
//  ACZoomableImageScrollView.h
//
//  Created by Albert Chu on 14/7/24.
//

#import <UIKit/UIKit.h>

#import "SDWebImageOperation.h"

@interface ACZoomableImageScrollView : UIScrollView

@property (nonatomic, retain) UIImageView                   *imageView;

@property (nonatomic, retain) id <SDWebImageOperation>      webImageOperation;

@property (nonatomic, retain) UIProgressView                *progressView;

@property (nonatomic, assign) BOOL                          isLoaded;

- (void)configImageByURL:(NSURL *)url
                  atItem:(NSInteger)item;

@end
