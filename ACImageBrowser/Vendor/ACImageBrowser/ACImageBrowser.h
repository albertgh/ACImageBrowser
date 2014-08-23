//
//  ACImageBrowser.h
//
//  Created by Albert Chu on 14/8/11.
//

#import <UIKit/UIKit.h>

@protocol ACImageBrowserDelegate <NSObject>
- (void)dismissAtIndex:(NSInteger)index;
@end

@interface ACImageBrowser : UIViewController

@property (nonatomic, assign) id<ACImageBrowserDelegate>    delegate;

- (id)initWithImagesURLArray:(NSArray *)imagesURLArray;

- (void)setPageIndex:(NSUInteger)index;

@end
