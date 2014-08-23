## ACImageBrowser

A Image Browser

<img src="https://github.com/albertgh/ACImageBrowser/raw/master/screenshot.gif"/>


## Installing

Drag **ACImageBrowser** folder into your project. 

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

#### Requirements

* iOS 7+

#### License

######WTFPL 


