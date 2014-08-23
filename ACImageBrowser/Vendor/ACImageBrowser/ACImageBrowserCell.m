//
//  ACImageBrowserCell.m
//
//  Created by Albert Chu on 14/8/11.
//

#import "ACImageBrowserCell.h"

#import "ACZoomableImageScrollView.h"

#import "ACImageBrowserConstants.h"

#import "ACImageBrowserUtils.h"


@implementation ACImageBrowserCell

#pragma mark - Public

-(void)configCellImageByURL:(NSURL *)url
                     atItem:(NSInteger)item
{
    [self.zoomableImageScrollView configImageByURL:url
                                            atItem:item];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // passing item number to SDWebImage and check if is current
    // for completed block to decide do completed or not
    // provide a better experience, otherwise if keep scrolling
    // image never get download
    // so no need to be cancel operation now
    
    // very important for reusing cell
    //[self.zoomableImageScrollView.webImageOperation cancel];
    
    self.zoomableImageScrollView.imageView.image = nil;
    
    self.zoomableImageScrollView.progressView.progress = 0.0f;
    self.zoomableImageScrollView.progressView.hidden = YES;
    
    if ([ACImageBrowserUtils sharedInstance].isFullscreen)
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
        
        self.zoomableImageScrollView =
        [[ACZoomableImageScrollView alloc]
         initWithFrame:CGRectMake(0,
                                  0,
                                  self.bounds.size.width,
                                  self.bounds.size.height)];
        
        self.zoomableImageScrollView.autoresizingMask =
        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:self.zoomableImageScrollView];
    }
    return self;
}


@end
