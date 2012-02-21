//
//  EAGLView.h
//  Iteration
//
//  Created by Kathleen on 9/6/09.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/


@interface EAGLView : UIView {
	
	IBOutlet UISlider* nitersSlider;
	IBOutlet UISlider* alphaSlider;
	IBOutlet UISlider* color1Slider;
	IBOutlet UISlider* color2Slider;
	IBOutlet UISlider* color3Slider;
	IBOutlet UISwitch* compositeSwitch;
	IBOutlet UISlider* zoomSlider;
	IBOutlet UISwitch* symmetrySwitch;
	IBOutlet UIBarButtonItem* saveButton;

	
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer, bigFramebuffer;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	GLfloat* iterVerts;
	GLubyte* iterColors;
	int ncps;
	
	float a,b,c,d;
	
	GLuint			    brushTexture;
	GLuint				bigTexture;
	
	GLfloat			squareVerts[8];
	GLfloat			squareTexCoords[8];
	
	GLint				bigWidth;
	GLint				bigHeight;
	GLint				finalWidth;
	GLint				finalHeight;
	
	UIAlertView *savedAlert;
}

@property NSTimeInterval animationInterval;


- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
- (void)resetParams;
- (float)makeRandom: (float) radius;
- (float)zin: (float) angle;

- (IBAction)reset:(id)sender;
- (IBAction)save:(id)sender;

- (UIImage *) glToUIImage;
- (void)captureToPhotoAlbum;

@property (retain, nonatomic) UISlider* nitersSlider;
@property (retain, nonatomic) UISlider* alphaSlider;
@property (retain, nonatomic) UISlider* color1Slider;
@property (retain, nonatomic) UISlider* color2Slider;
@property (retain, nonatomic) UISlider* color3Slider;
@property (retain, nonatomic) UISwitch* compositeSwitch;
@property (retain, nonatomic) UISlider* zoomSlider;
@property (retain, nonatomic) UISwitch* symmetrySwitch;
@property (retain, nonatomic) UIBarButtonItem* saveButton;



@end
