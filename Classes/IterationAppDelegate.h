//
//  IterationAppDelegate.h
//  Iteration
//
//  Created by Kathleen on 9/6/09.
//

#import <UIKit/UIKit.h>

//@class EAGLView;
@class ViewSwitcher;

@interface IterationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	ViewSwitcher *switcher;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ViewSwitcher *switcher;


@end

