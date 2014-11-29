## ACImageBrowser

A customizable Image Browser


<img src="https://github.com/albertgh/ACImageBrowser/raw/master/screenshot.gif"/>


## Installing

Drag `ACImageBrowser` folder into your project. 

```objective-c
#import "ACImageBrowser.h"
```
    
    
## Usage

```objc
// creat the array with your Images URL objects, pass it to initWithImagesURLArray:
NSMutableArray *photosURL = [[NSMutableArray alloc] init];
// ......
ACImageBrowser *browser = [[ACImageBrowser alloc] initWithImagesURLArray:photosURL];

// Browse from which index.
[browser setPageIndex:2];

// Disable single tap to turn on and off fullscreen mode, default is YES.
browser.fullscreenEnable = NO;
```

```objc
// If you want to know ACImageBrowser dismiss at which index, use this delegate.  
browser.delegate = self;

#pragma mark - ACImageBrowserDelegate

- (void)dismissAtIndex:(NSInteger)index
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Dismiss at index: %lu", (unsigned long)index);
}
```
## Customize

If you want to custom a sub class, here is some methods you should know.

```objc
//** for custom subclass working with things like bottom toolbar ***************************
// default animation duration is ACIBU_BGColor_AnimationDuration (0.28f)
- (void)willAnimateToFullscreenMode;
- (void)willAnimateToNormalMode;
//****************************************************************************************//

//** deleting and saving ******************************************************************
- (void)deletePhotoAtCurrentIndex:(void (^)(void))deletingBlock
                          success:(void (^)(BOOL finished))finishedBlock;

- (void)savePhotoToCameraRollProgress:(void (^)(CGFloat percent))progressBlock
                              success:(void (^)(BOOL success))successBlock;
//****************************************************************************************//
```

See more in the sample `YourCustomACImageBrowser.m`.


#### Requirements

* iOS 7+


#### Open source project used

* [SDWebImage](https://github.com/rs/SDWebImage)


#### License

* MIT 


