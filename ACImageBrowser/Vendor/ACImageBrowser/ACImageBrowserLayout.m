//
//  ACImageBrowserLayout.m
//
//  Created by Albert Chu on 14/11/13.
//

#import "ACImageBrowserLayout.h"

#import "ACImageBrowserConstants.h"

@implementation ACImageBrowserLayout

- (id)initWithItemSize:(CGSize)size {
    self = [super init];
    if (self) {
        // Initialization code
        self.itemSize = size;
        
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.minimumInteritemSpacing = 0.0f;
        self.minimumLineSpacing = ACIB_PageGap;
        
        self.sectionInset = UIEdgeInsetsZero;
        self.footerReferenceSize = CGSizeZero;
        self.headerReferenceSize = CGSizeZero;
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    // re calculate content size for last one's gap
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    CGFloat contentSize_width = (self.itemSize.width + ACIB_PageGap) * itemCount;
    CGSize contentSize = CGSizeMake(contentSize_width, self.itemSize.height);
    
    return contentSize;
}

@end
