//
//  ViewSwitcher.m
//  Iteration
//
//  Created by Kathleen on 10/1/09.
//

#import "ViewSwitcher.h"
#import "EAGLView.h"

@implementation ViewSwitcher

@synthesize containerView;
@synthesize glView;
@synthesize viewFlipped;
@synthesize viewIsFlipped;

- (void)loadView {	
	// create and store a container view
	
	UIView *localContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	self.view = containerView;
	
	viewIsFlipped = FALSE;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[glView startAnimation];
	[containerView addSubview:glView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (IBAction)toggleView {        
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:(viewIsFlipped ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:self.view cache:YES];
    
    if (viewIsFlipped) {
		[viewFlipped removeFromSuperview];
		[containerView addSubview:glView];
		viewIsFlipped = FALSE;
    } 
	else{
		[glView stopAnimation];
		[glView removeFromSuperview];
		[containerView addSubview:viewFlipped];
		viewIsFlipped = TRUE;
	} 
	[UIView commitAnimations];
	
	
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
	if (!viewIsFlipped){
		[glView startAnimation];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
