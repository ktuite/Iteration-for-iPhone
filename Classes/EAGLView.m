//
//  EAGLView.m
//  Iteration
//
//  Created by Kathleen on 9/6/09.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>m

#import "EAGLView.h"
#import	"ViewSwitcher.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize nitersSlider;
@synthesize alphaSlider;
@synthesize color1Slider;
@synthesize color2Slider;
@synthesize color3Slider;
@synthesize zoomSlider;
@synthesize compositeSwitch;
@synthesize symmetrySwitch;
@synthesize saveButton;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {		
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		savedAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Iteration Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        
        animationInterval = 1.0 / 60.0;
		
		ncps = 600;
		iterVerts = malloc(ncps * 25 * 2 * sizeof(GLfloat));
		iterColors = malloc(ncps * 25 * 4 * sizeof(GLubyte));
		
		[self resetParams];
		
    }
	
    return self;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	[self startAnimation];
}

- (void)drawView {
	int niters = nitersSlider.value;
	int alpha = alphaSlider.value;
	float foo = color1Slider.value;
	float bar = color2Slider.value;
	float cat = color3Slider.value;
	float zoom_level = 0.45 * pow(2, zoomSlider.value);
	BOOL symmetry = symmetrySwitch.on;

	for (int i = 0; i < ncps; i++){
		float x = [self makeRandom: 1.0];
		float y = [self makeRandom: 1.0];
		float p = [self zin: [self makeRandom: 3.14159265]];
		
		for (int j = 0; j < niters; j++){
			float xp = sin(a*x) + (symmetry?sin(b*y):cos(b*y)) + p;
			float yp = sin(c*x) + sin(d*y) + p;
			x = xp;
			y = yp;
			
			float t = j/(float) niters;
			
			iterVerts[2*(i*niters + j) + 0] = x;
			iterVerts[2*(i*niters + j) + 1] = y;

			iterColors[4*(i*niters + j) + 0] = 255 * t * foo;
			iterColors[4*(i*niters + j) + 1] = 2 * 255 * t * (1-t) * bar;
			iterColors[4*(i*niters + j) + 2] = 255 * (1-t) * cat;
			iterColors[4*(i*niters + j) + 3] = alpha;
		}
		
	}
    
    [EAGLContext setCurrentContext:context];
    
	/* render into the texture */
	
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, bigFramebuffer);
    glViewport(0, 0, finalWidth, finalHeight);
    
	glEnable(GL_BLEND);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrthof(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glScalef(zoom_level, zoom_level, 1.0f);	
	
	glVertexPointer(2, GL_FLOAT, 0, iterVerts);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, iterColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
	glBindTexture(GL_TEXTURE_2D, brushTexture);
    glDrawArrays(GL_POINTS, 0, ncps * niters);
	glDisableClientState(GL_COLOR_ARRAY);
	
	
	/* draw the texture on the screen */
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
	glDisable(GL_BLEND);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrthof(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glVertexPointer(2, GL_FLOAT, 0, squareVerts);
	glEnableClientState(GL_VERTEX_ARRAY);

	glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glBindTexture(GL_TEXTURE_2D, bigTexture);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);


	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)resetParams {
	float k = 2.5;
	a = [self makeRandom: k];
	b = [self makeRandom: k];
	c = [self makeRandom: k];
	d = [self makeRandom: k];
	
	if (!compositeSwitch.on){
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, bigFramebuffer);
		glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);
	}
}

- (float)makeRandom: (float) radius{
	return (rand() / (float) RAND_MAX) * 2 * radius - radius;
}

- (float)zin: (float) angle{
	int s = 8;
	if(angle < 0) {
		return round(s*sin(angle))/(float)s;
	} else {
		return sin(angle);
	}	
}

- (IBAction)reset:(id)sender {
	[self resetParams];
}

- (IBAction)save:(id)sender {
	[self stopAnimation];
	[self captureToPhotoAlbum];
	[savedAlert show];
	//[self startAnimation];
	// really need to figure out how to stop animations and 
	// restart when alert goes away OR glView comes back into view..
}

- (UIImage *) glToUIImage {
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, bigFramebuffer);

	int W = finalWidth;
	int H = finalHeight;
	NSInteger myDataLength = W * H * 4;
	// allocate array and read pixels into it.
	GLubyte *buffer = (GLubyte *) malloc(myDataLength);
	glFlush();
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	glReadPixels(0, 0, W, H, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	// gl renders "upside down" so swap top to bottom into new array.
	// there's gotta be a better way, but this works.
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
	for(int y = 0; y < H; y++)
	{
		for(int x = 0; x < W * 4; x++)
		{
			buffer2[(H - 1 - y) * W * 4 + x] = buffer[y * 4 * W + x];
		}
	}
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * W;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(W, H, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	// then make the uiimage from that
	 
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	return myImage;
}
	 
- (void)captureToPhotoAlbum {
	UIImage *image = [self glToUIImage];
	UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
#if LITE_VERSION
	[saveButton setEnabled:NO];
	[alphaSlider setValue: 12.0];
#else
	[saveButton setEnabled:YES];
	[nitersSlider setValue: 6];
#endif
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer {
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	CGImageRef		brushImage;
	CGContextRef	brushContext;
	size_t			width, height;
	GLubyte			*brushData;
	
	brushImage = [UIImage imageNamed:@"Particle-ps.png"].CGImage;
	width = CGImageGetWidth(brushImage);
	height = CGImageGetHeight(brushImage);
	// Make sure the image exists
	if(brushImage) {
		brushData = (GLubyte *) malloc(width * height * 4);
		brushContext = CGBitmapContextCreate(brushData, width, width, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
		CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
		CGContextRelease(brushContext);
		glGenTextures(1, &brushTexture);
		glBindTexture(GL_TEXTURE_2D, brushTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
		free(brushData);		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		// Enable use of the texture
		glEnable(GL_TEXTURE_2D);
		// Set a blending function to use
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		// Enable blending
		glEnable(GL_BLEND);
	}
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	glPointSize(4);

	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	/* new code 1/3/2010 */
#if LITE_VERSION
		bigWidth = 512;
		bigHeight = 512;
		finalWidth = 320;
		finalHeight = 480;
#else
	
	bigWidth = 2048;
	bigHeight = 2048;
	finalWidth = 1536;
	finalHeight = 2048;
	/*
		bigWidth = 1024;
		bigHeight = 1024;
		finalWidth = 640;
		finalHeight = 960;
	*/
#endif

	
	squareVerts[0] = -1;
	squareVerts[1] = -1;
	squareVerts[2] = -1;
	squareVerts[3] = 1;
	squareVerts[4] = 1;
	squareVerts[5] = 1;
	squareVerts[6] = 1;
	squareVerts[7] = -1;
	
	squareTexCoords[0] = 0;
	squareTexCoords[1] = 0;
	squareTexCoords[2] = 0;
	squareTexCoords[3] = (float)finalHeight/bigHeight;
	squareTexCoords[4] = (float)finalWidth/bigWidth;
	squareTexCoords[5] = (float)finalHeight/bigHeight;
	squareTexCoords[6] = (float)finalWidth/bigWidth;
	squareTexCoords[7] = 0;
	
	
	glGenFramebuffersOES(1, &bigFramebuffer);
	glGenTextures(1, &bigTexture);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, bigFramebuffer);
	
    glBindTexture(GL_TEXTURE_2D, bigTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bigWidth, bigHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, bigTexture, 0);
	
	if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"Failed for new FrameBuffer");
		
	}
	
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;

}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	[savedAlert release];
    [super dealloc];
}

@end
