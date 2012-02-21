//
//  ViewSwitcher.h
//  Iteration
//
//  Created by Kathleen on 10/1/09.
//

#import <UIKit/UIKit.h>

#define LITE_VERSION 0

@class EAGLView;

@interface ViewSwitcher : UIViewController {

	UIView *containerView;	
	EAGLView *glView;
	UIView *viewFlipped;
	BOOL viewIsFlipped;
	
}

@property (assign) BOOL viewIsFlipped;
@property (nonatomic,retain) UIView *containerView;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UIView *viewFlipped;


- (IBAction)toggleView;


@end
