//
//  ACImageBrowserLandscapeLayout.m
//
//  Created by Albert Chu on 14/8/13.
//

#import "ACImageBrowserLandscapeLayout.h"

#import "ACImageBrowserConstants.h"


@implementation ACImageBrowserLandscapeLayout

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
        
        self.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.height,
                                   [UIScreen mainScreen].bounds.size.width);
        
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.minimumInteritemSpacing = 0.0f;
        self.minimumLineSpacing = k_ACIB_PageGap;
        
        self.sectionInset = UIEdgeInsetsZero;
        self.footerReferenceSize = CGSizeZero;
        self.headerReferenceSize = CGSizeZero;
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    // re calculate content size for last one's gap
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    CGFloat contentSize_width = (self.itemSize.width + k_ACIB_PageGap) * itemCount;
    CGSize contentSize = CGSizeMake(contentSize_width, self.itemSize.height);
    
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size))
    {
        return YES;
    }
    return NO;
}


@end
