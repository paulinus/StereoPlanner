//
//  EAGLView.m
//  provaOpenGLES
//
//  Created by Pau Gargallo on 6/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#include "document.h"

#import "CaptureView.h"


@implementation CaptureView

@synthesize interactionMode;

- (id)commonInit {
  interactionMode = CaptureViewInteractionModeOrbit;
  return [super commonInit];
}

- (void)setDocument:(const SpDocument *)document {
  
  doc_ = document;
  [self updateGL];
}

- (void)drawViewingAreaAtDepth:(float)z {
  float lleft, lright, rleft, rright, bottom, top;
  StereoFrustum f = doc_->ShootingFrustrum();
  f.ViewAreaLeft(z, &lleft, &lright, &bottom, &top);
  f.ViewAreaRight(z, &rleft, &rright, &bottom, &top);
  
  GLfloat z_view_area[] = {
    lleft, bottom, -z,  rleft, bottom, -z,
    rleft, bottom, -z,  lright, bottom, -z,
    lright, bottom, -z,  rright, bottom, -z,
    
    lleft, top, -z,  rleft, top, -z,
    rleft, top, -z,  lright, top, -z,
    lright, top, -z,  rright, top, -z,
    
    lleft, bottom, -z,  lleft, top, -z,
    rleft, bottom, -z,  rleft, top, -z,
    lright, bottom, -z,  lright, top, -z,
    rright, bottom, -z,  rright, top, -z
  };
  glDisable(GL_LIGHTING);
  glColor4f(.7, .7, .7, 1);
  glVertexPointer(3, GL_FLOAT, 0, z_view_area);
  glEnableClientState(GL_VERTEX_ARRAY);
  glDrawArrays(GL_LINES, 0, 20);
  glDisableClientState(GL_VERTEX_ARRAY);
}

- (void)drawFrustumLines {
  float z = std::max(std::max(doc_->NearDistance(), doc_->RigConvergence()), 
                     doc_->FarDistance());
  float lleft, lright, rleft, rright, bottom, top;
  StereoFrustum f = doc_->ShootingFrustrum();
  f.ViewAreaLeft(z, &lleft, &lright, &bottom, &top);
  f.ViewAreaRight(z, &rleft, &rright, &bottom, &top);
  
  float l = -doc_->RigInterocular() / 2;
  
  GLfloat frustruml[] = {
    l,0,0, lleft, bottom, -z,
    l,0,0, lright, bottom, -z,
    l,0,0, lright, top, -z,
    l,0,0, lleft, top, -z
  };
  GLfloat frustrumr[] = {
    -l,0,0, rleft, bottom, -z,
    -l,0,0, rright, bottom, -z,
    -l,0,0, rright, top, -z,
    -l,0,0, rleft, top, -z
  };
  
  glDisable(GL_LIGHTING);
  glEnableClientState(GL_VERTEX_ARRAY);
  
  // left
  glColor4f(.7, .4, .4, 1);
  glVertexPointer(3, GL_FLOAT, 0, frustruml);
  glDrawArrays(GL_LINES, 0, 8);
  // right
  glColor4f(.4, .7, .7, 1);
  glVertexPointer(3, GL_FLOAT, 0, frustrumr);
  glDrawArrays(GL_LINES, 0, 8);
  glDisableClientState(GL_VERTEX_ARRAY);
}


// TODO(pau): split this function in subfunctions.
- (void)draw {
  [super draw];

  if (doc_) {
    [super renderGeometry:&(doc_->CaptureGeometry())];
  
    // Move to rig's reference frame.
    glPushMatrix();
    glTranslatef(doc_->RigX(), doc_->RigY(), doc_->RigZ());
    Transform3f m;
    m = PanTiltRollA(doc_->RigPan(), doc_->RigTilt(), doc_->RigRoll());
    glMultMatrixf(m.data());
    
    // Draw cameras.
    float l = -doc_->RigInterocular() / 2;
    float r = doc_->RigInterocular() / 2;
    GLfloat eyes[] = {
      0,0,0,
      l,0,0,
      r,0,0
    };
    GLfloat eyecolors[] = {
      0, 1, 0, 1,
      1, .7, .5, 1,
      .5, .7, 1, 1
    };
    
    glDisable(GL_LIGHTING);
    glPointSize(3);
    glVertexPointer(3, GL_FLOAT, 0, eyes);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_FLOAT, 0, eyecolors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_POINTS, 0, 3);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    
    // Draw the screen.
    [self drawViewingAreaAtDepth:doc_->RigConvergence()];
      
    // Draw Frustum
    [self drawFrustumLines];
    
    // Draw fear and far planes.
    [self drawViewingAreaAtDepth:doc_->NearDistance()];
    [self drawViewingAreaAtDepth:doc_->FarDistance()];
    
    glPopMatrix(); // Rig's reference frame.
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (interactionMode == CaptureViewInteractionModeOrbit) {
    [super touchesMoved:touches withEvent:event];
  }
}

- (void)dealloc {
  [super dealloc];
}

@end
