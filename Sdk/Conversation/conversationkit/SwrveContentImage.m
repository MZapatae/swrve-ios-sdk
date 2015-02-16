
/*******************************************************
 * Copyright (C) 2011-2012 Converser contact@converser.io
 *
 * This file is part of the Converser iOS SDK.
 *
 * This code may not be copied and/or distributed without the express
 * permission of Converser. Please email contact@converser.io for
 * all redistribution and reuse enquiries.
 *******************************************************/

#import "SwrveContentImage.h"
#import "SwrveSetup.h"

@interface SwrveContentImage () {
    UIImageView *iv;
}
@end

@implementation SwrveContentImage

-(id) initWithTag:(NSString *)tag andDictionary:(NSDictionary *)dict {
    self = [super initWithTag:tag type:kSwrveContentTypeImage andDictionary:dict];
    return self;
}

-(void) loadView {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.value]]];
        [self sizeAndDisplayImage:image];
    });
}

- (void)sizeAndDisplayImage:(UIImage *)image
{
    // Create _view and add image to it
    iv = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Image setting and manipulation should be done on the main thread, otherwise this slows down a lot on iOS 7
        self->iv.image = image;
        [self->iv sizeToFit];
        CGRect r = self->iv.frame;
        if(r.size.width > [SwrveConversationAtom widthOfContentView]) {
            self->iv.frame = CGRectMake(r.origin.x, r.origin.y, [SwrveConversationAtom widthOfContentView], r.size.height/r.size.width*[SwrveConversationAtom widthOfContentView]);
        }
        // If it is too small let's center it in the view, or just add it as a subview of the same size
        self->_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [SwrveConversationAtom widthOfContentView], self->iv.frame.size.height)];
        if(r.size.width < [SwrveConversationAtom widthOfContentView]) {
            self->iv.frame = CGRectMake(([SwrveConversationAtom widthOfContentView]-r.size.width)/2, r.origin.y, r.size.width, r.size.height);
        }
        [self->_view addSubview:self->iv];
    });
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwrveNotificationViewReady object:nil];
    // Get notified if the view should change dimensions
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:kSwrveNotifyOrientationChange object:nil];
}

-(UIView *)view {
    if(!_view) {
        [self loadView];
    }
    return _view;
}

// Respond to device orientation changes by resizing the width of the view
// Subviews of this should be flexible using AutoResizing masks
-(void) deviceOrientationDidChange {
    _view.frame = [self newFrameForOrientationChange];
    // Redraw the image and image view within this view
    CGRect r = iv.frame;

    // Too big or same size?
    if (r.size.width >= _view.frame.size.width) {
        iv.frame = CGRectMake(0.0, 0.0, _view.frame.size.width, r.size.height/r.size.width*_view.frame.size.width);
    }
    // Too small?
    if(r.size.width < _view.frame.size.width) {
        iv.frame = CGRectMake((_view.frame.size.width-r.size.width)/2, r.origin.y, r.size.width, r.size.height);
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kSwrveNotifyOrientationChange object:nil];
}

@end
