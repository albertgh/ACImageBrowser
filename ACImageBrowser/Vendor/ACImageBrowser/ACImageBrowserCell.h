//
//  ACImageBrowserCell.h
//
//  Created by Albert Chu on 14/8/11.
//

#import <UIKit/UIKit.h>

@class ACZoomableImageScrollView;

@interface ACImageBrowserCell : UICollectionViewCell

@property (nonatomic, retain) ACZoomableImageScrollView   *zoomableImageScrollView;

-(void)configCellImageByURL:(NSURL *)url
                     atItem:(NSInteger)item;

@end
