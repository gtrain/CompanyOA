

#import <Foundation/Foundation.h>

@interface UIView (Toast)

// each makeToast method creates a view and displays it as toast
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title image:(UIImage *)image;
- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image;

// displays toast with an activity spinner
- (void)makeToastActivity;
- (void)makeToastActivity:(id)position;
- (void)hideToastActivity;

// the showToast methods display any view as toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point;

@end

/*
case 0: {
    // Make toast
    [self.view makeToast:@"This is a piece of toast."];
    break;
}

case 1: {
    // Make toast with a title
    [self.view makeToast:@"This is a piece of toast with a title."
                duration:3.0
                position:@"top"
                   title:@"Toast Title"];
    
    break;
}

case 2: {
    // Make toast with an image
    [self.view makeToast:@"This is a piece of toast with an image."
                duration:3.0
                position:@"center"
                   image:[UIImage imageNamed:@"toast.png"]];
    break;
}

case 3: {
    // Make toast with an image & title
    [self.view makeToast:@"This is a piece of toast with a title & image"
                duration:3.0
                position:@"bottom"
                   title:@"Toast Title"
                   image:[UIImage imageNamed:@"toast.png"]];
    break;
}

case 4: {
    // Show a custom view as toast
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 400)] autorelease];
    [customView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)]; // autoresizing masks are respected on custom views
    [customView setBackgroundColor:[UIColor orangeColor]];
    
    [self.view showToast:customView
                duration:2.0
                position:@"center"];
    
    break;
}

case 5: {
    // Show an imageView as toast, on center at point (110,110)
    UIImageView *toastView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast.png"]] autorelease];
    
    [self.view showToast:toastView
                duration:2.0
                position:[NSValue valueWithCGPoint:CGPointMake(110, 110)]]; // wrap CGPoint in an NSValue object
    
    break;
}

case 6: {
    if (_isShowingActivity) {
        [_activityButton setTitle:@"Hide Activity" forState:UIControlStateNormal];
        [self.view makeToastActivity];
    } else {
        [_activityButton setTitle:@"Show Activity" forState:UIControlStateNormal];
        [self.view hideToastActivity];
    }
    _isShowingActivity = !_isShowingActivity;
    break;
}
*/