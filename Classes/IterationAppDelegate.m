//
//  IterationAppDelegate.m
//  Iteration
//
//  Created by Kathleen on 9/6/09.
//

#import "IterationAppDelegate.h"
#import "ViewSwitcher.h"

@implementation IterationAppDelegate

@synthesize window;
@synthesize switcher;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:[switcher view]];

	//glView.animationInterval = 1.0 / 60.0;
	//[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	//glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	//glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[switcher release];
	[super dealloc];
}

@end
