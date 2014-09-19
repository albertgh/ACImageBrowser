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

-(void)configCellImageByURL:(NSURL *)url
                     atItem:(NSInteger)item
{
    
    self.zoomableImageScrollView.imageBrowser = self.imageBrowser;
    
    [self.zoomableImageScrollView configImageByURL:url
                                            atItem:item];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.zoomableImageScrollView.imageView.image = nil;
    
    self.zoomableImageScrollView.progressView.progress = 0.0f;
    self.zoomableImageScrollView.progressView.hidden = YES;
    
    self.zoomableImageScrollView.isLoaded = NO;
    
    if (self.imageBrowser.isFullscreen)
    {
        self.backgroundColor = k_ACIB_isFullscreen_BGColor;
        self.zoomableImageScrollView.backgroundColor = k_ACIB_isFullscreen_BGColor;
        self.zoomableImageScrollView.imageView.backgroundColor = k_ACIB_isFullscreen_BGColor;
    }
    else
    {
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        self.zoomableImageScrollView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        self.zoomableImageScrollView.imageView.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    }
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
                
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        
        self.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        self.contentView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        self.zoomableImageScrollView =
        [[ACZoomableImageScrollView alloc]
         initWithFrame:CGRectMake(0,
                                  0,
                                  self.bounds.size.width,
                                  self.bounds.size.height)];
        
        self.zoomableImageScrollView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.zoomableImageScrollView];
    }
    return self;
}

@end
