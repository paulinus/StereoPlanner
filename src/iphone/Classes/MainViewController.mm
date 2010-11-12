//
//  StereoPlannerViewController.m
//  StereoPlanner
//
//  Created by Pau Gargallo on 6/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"

#include "document.h"


@implementation MainViewController

@synthesize mama;
@synthesize selector;
@dynamic selectedSliderVariable;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Create the document
  doc_ = new SpDocument;
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"monkey" ofType:@"geo"];  
  if (filePath) {
    //NSString *myText = [NSString stringWithContentsOfFile:filePath];
    //const char *text = [myText UTF8String];
    doc_->LoadGeometry([filePath cStringUsingEncoding:1]);
  }  

  captureViewController = [[CaptureViewController alloc] init];
  [captureViewController.view setFrame:[mama frame]];
  [captureViewController setDocument:doc_];
  
  cinemaViewController = [[CinemaViewController alloc] init];
  [cinemaViewController.view setFrame:[mama frame]];
  [cinemaViewController setDocument:doc_];
  
  calculatorViewController = [[CalculatorViewNController alloc] initWithMainViewController:self];
  [calculatorViewController.view setFrame:[mama frame]];
  [calculatorViewController setDocument:doc_];
  [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

  [self selectSetCinema];

  
  slider = [[InfiniteSlider alloc] init];
  [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

  [self setSelectedSliderVariable:SLIDER_CONVERGENCE];
   
  CGRect rect = [mama frame];
  int h = 40;
  rect.origin.y = rect.origin.y + rect.size.height - h;
  rect.size.height = h;
  
  [slider setFrame:rect];
  [slider setBackgroundColor:[UIColor blackColor]];
  [slider setAlpha:0.5];
  [mama addSubview:slider];
  [mama bringSubviewToFront:slider];
}

- (void)setSelectedSliderVariable:(SliderVariable)v {
  if (selectedSliderVariable != v) {
    selectedSliderVariable = v;
    [slider setLabel:[self getSliderVariableLabel]];
    [slider setValue:[self getSliderVariableValue]];
  }
}

- (SliderVariable)selectedSliderVariable {
  return selectedSliderVariable;
}

- (NSString *)getSliderVariableLabel {
  switch (selectedSliderVariable) {
    case SLIDER_NEAR:
      return @"Near";
    case SLIDER_FAR:
      return @"Far";
    case SLIDER_CONVERGENCE:
      return @"Convergence";
    case SLIDER_FOCAL_LENGTH:
      return @"Focal length";
    case SLIDER_INTEROCULAR:
      return @"Interocular";
    case SLIDER_SCREEN_WIDTH:
      return @"Screen width";
    default:
      return @"";
  }
}

- (float)getSliderVariableValue {
  switch (selectedSliderVariable) {
    case SLIDER_NEAR:
      return doc_->NearDistance();
    case SLIDER_FAR:
      return doc_->FarDistance();
    case SLIDER_CONVERGENCE:
      return doc_->RigConvergence();
    case SLIDER_FOCAL_LENGTH:
      return doc_->FocalLegth();
    case SLIDER_INTEROCULAR:
      return doc_->RigInterocular();
    case SLIDER_SCREEN_WIDTH:
      return doc_->ScreenWidth();
    default:
      return 0;
  }
}

- (void)setSliderVariableValue:(float)value {
  switch (selectedSliderVariable) {
    case SLIDER_NEAR:
      doc_->SetNearDistance(value);
      break;
    case SLIDER_FAR:
      doc_->SetFarDistance(value);
      break;
    case SLIDER_CONVERGENCE:
      doc_->SetRigConvergence(value);
      break;
    case SLIDER_FOCAL_LENGTH:
      doc_->SetFocalLegth(value);
      break;
    case SLIDER_INTEROCULAR:
      doc_->SetRigInterocular(value);
      break;
    case SLIDER_SCREEN_WIDTH:
      doc_->SetScreenWidth(value);
      break;
  }
}

- (void)sliderChanged:(id)sender {
  if (slider.value != [self getSliderVariableValue]) {
    [self setSliderVariableValue:slider.value];
    [self documentChanged];
  }
}

- (void)documentChanged {
  if (slider.value != [self getSliderVariableValue])
    slider.value = [self getSliderVariableValue];
  
  if ([captureViewController.view isDescendantOfView:mama])
    [(CaptureView *)captureViewController.view updateGL];
  
  if ([cinemaViewController.view isDescendantOfView:mama])
    [(CinemaView *)cinemaViewController.view updateGL];
  
  if ([calculatorViewController.view isDescendantOfView:mama])
    [calculatorViewController updateView];    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  delete doc_;
}


- (void)dealloc {
  [super dealloc];
}


- (IBAction)selectSetCinema {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.75];
  
  switch ([selector selectedSegmentIndex]) {
    case 0:
      [(CaptureView *)captureViewController.view updateGL];
      [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:mama cache:YES];
      [cinemaViewController.view removeFromSuperview];
      [mama addSubview:captureViewController.view];
      break;
    case 1:     
      [(CinemaView *)cinemaViewController.view updateGL];
      [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:mama cache:YES];
      [captureViewController.view removeFromSuperview];
      [mama addSubview:cinemaViewController.view];
      break;
    case 2:
      [calculatorViewController updateView];
      [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:mama cache:YES];
      [captureViewController.view removeFromSuperview];
      [mama addSubview:calculatorViewController.view];
      break;      
  }
  [UIView commitAnimations];
  [mama bringSubviewToFront:slider];
}

@end
