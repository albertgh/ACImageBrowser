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

- (void)configCellImageByURL:(NSURL *)url
            inCollectionView:(UICollectionView *)collectionView
                 atIndexPath:(NSIndexPath *)indexPath
{
    self.zoomableImageScrollView.imageBrowser = self.imageBrowser;
    
    [self.zoomableImageScrollView configImageByURL:url
                                  inCollectionView:collectionView
                                       atIndexPath:indexPath];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.imageBrowser.isFullscreen)
    {
        self.backgroundColor = k_ACIB_isFullscreen_BGColor;
    }
    else
    {
        self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
    }
    
    // reset zoomableISV
    [self.zoomableImageScrollView removeFromSuperview];
    
    self.zoomableImageScrollView = nil;
    
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

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (self.imageBrowser.isFullscreen)
        {
            self.backgroundColor = k_ACIB_isFullscreen_BGColor;
        }
        else
        {
            self.backgroundColor = k_ACIB_isNotFullscreen_BGColor;
        }
        
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
        
        self.zoomableImageScrollView.imageBrowser = self.imageBrowser;
        
        [self.contentView addSubview:self.zoomableImageScrollView];
    }
    return self;
}

@end
