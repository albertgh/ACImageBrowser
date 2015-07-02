//
//  ACImageBrowserCell.m
//
//  Created by Albert Chu on 14/8/11.
//

#import "ACImageBrowserCell.h"
#import "ACZoomableImageScrollView.h"
#import "ACImageBrowserConstants.h"
#import "ACImageBrowser.h"


@implementation ACImageBrowserCell

#pragma mark - Public

- (void)configCellImageByURL:(NSURL *)url {
    self.zoomableImageScrollView.imageBrowser = self.imageBrowser;
    self.zoomableImageScrollView.imageURLString = url.absoluteString;
    [self.zoomableImageScrollView configImageByURL:url];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
        
    self.backgroundColor =
    self.imageBrowser.isFullscreen ?
    k_ACIB_isFullscreen_BGColor :
    k_ACIB_isNotFullscreen_BGColor;
    
    self.zoomableImageScrollView.imageURLString = nil;
    self.zoomableImageScrollView = [[ACZoomableImageScrollView alloc] init];
    self.zoomableImageScrollView.frame = CGRectMake(0.0f,
                                                    0.0f,
                                                    self.bounds.size.width,
                                                    self.bounds.size.height);

    self.zoomableImageScrollView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:self.zoomableImageScrollView];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor =
        self.imageBrowser.isFullscreen ?
        k_ACIB_isFullscreen_BGColor :
        k_ACIB_isNotFullscreen_BGColor;
        
        self.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        self.contentView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        self.zoomableImageScrollView = [[ACZoomableImageScrollView alloc] init];
        self.zoomableImageScrollView.frame = CGRectMake(0.0f,
                                                        0.0f,
                                                        self.bounds.size.width,
                                                        self.bounds.size.height);
        
        self.zoomableImageScrollView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        self.zoomableImageScrollView.imageBrowser = self.imageBrowser;
        
        [self.contentView addSubview:self.zoomableImageScrollView];
    }
    return self;
}

@end
