#import "SwrveContentVideo.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SwrveSetup.h"
#import "SwrveConversationEvents.h"

#import "UIWebView+YouTubeVimeo.h"

@interface SwrveContentVideo () {
    NSString *_height;
    UIWebView *webview;
}

@end

@implementation SwrveContentVideo

@synthesize height = _height;
@synthesize interactedWith = _interactedWith;

-(id) initWithTag:(NSString *)tag andDictionary:(NSDictionary *)dict {
    self = [super initWithTag:tag type:kSwrveContentTypeVideo andDictionary:dict];
    _height = [dict objectForKey:@"height"];
    return self;
}

-(BOOL) willRequireLandscape {
    return YES;
}

-(void) stop {
    // Stop the running video - this will happen on a
    // page change.
    [webview loadHTMLString:@"" baseURL:nil];
}

-(void) loadView {
    // Create _view
    float vid_height = (_height) ? [_height floatValue] : 180.0;
    _view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, [SwrveConversationAtom widthOfContentView], vid_height)];
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300.0, vid_height)];
    [self sizeTheWebView];
    webview.backgroundColor = [UIColor clearColor];
    webview.opaque = NO;
    webview.delegate = self;
    webview.userInteractionEnabled = YES;
    [SwrveContentItem scrollView:webview].scrollEnabled = NO;
    [webview loadYouTubeOrVimeoVideo:self.value];
    [_view addSubview:webview];
    
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]; // Declare the Gesture.
    gesRecognizer.delegate = self;
    [gesRecognizer setNumberOfTapsRequired:1];
    [webview addGestureRecognizer:gesRecognizer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwrveNotificationViewReady object:nil];
    // Get notified if the view should change dimensions
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:kSwrveNotifyOrientationChange object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
#pragma unused(gestureRecognizer, otherGestureRecognizer)
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
#pragma unused(gestureRecognizer)
    _interactedWith = YES;
}

-(UIView *)view {
    if(!_view) {
        [self loadView];
    }
    return _view;
}

-(void) sizeTheWebView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Make the webview full width on iPad
        webview.frame = CGRectMake(0.0, 0.0, _view.frame.size.width, webview.frame.size.height/webview.frame.size.width*_view.frame.size.width);
    } else {
        // Cope with phone rotation
        // Too big or same size?
        if (webview.frame.size.width >= _view.frame.size.width) {
            webview.frame = CGRectMake(0.0, 0.0, _view.frame.size.width, webview.frame.size.height/webview.frame.size.width*_view.frame.size.width);
        }
        // Too small?
        if(webview.frame.size.width < _view.frame.size.width) {
            webview.frame = CGRectMake((_view.frame.size.width-webview.frame.size.width)/2, webview.frame.origin.y, webview.frame.size.width, webview.frame.size.height);
        }
    }
    // Adjust the containing view around this too
    _view.frame = CGRectMake(_view.frame.origin.x, _view.frame.origin.y, _view.frame.size.width, webview.frame.size.height);
}

// Respond to device orientation changes by resizing the width of the view
// Subviews of this should be flexible using AutoResizing masks
-(void) deviceOrientationDidChange {
    _view.frame = [self newFrameForOrientationChange];
    [self sizeTheWebView];
}

- (void)dealloc {
    if (webview.delegate == self) {
        webview.delegate = nil; // Unassign self from being the delegate, in case we get deallocated before the webview!
    }
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kSwrveNotifyOrientationChange object:nil];
}

@end
