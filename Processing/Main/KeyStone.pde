/**
 * This is a simple example of how to use the Keystone library.
 *
 * To use this example in the real world, you need a projector
 * and a surface you want to project your Processing sketch onto.
 *
 * Simply drag the corners of the CornerPinSurface so that they
 * match the physical surface's corners. The result will be an
 * undistorted projection, regardless of projector position or 
 * orientation.
 *
 * You can also create more than one Surface object, and project
 * onto multiple flat surfaces using a single projector.
 *
 * This extra flexbility can comes at the sacrifice of more or 
 * less pixel resolution, depending on your projector and how
 * many surfaces you want to map. 
 */

import deadpixel.keystone.*;

void initKeystone() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(width, height, P3D);
}

void drawProjection() {
  
  // Draw the scene, offscreen
  screen = get();
  
  offscreen.beginDraw();
  offscreen.image(screen,0,0);
  
  float dim = 400;
  int x_off = 100;
  
  offscreen.noStroke();
  offscreen.fill(#FFFF00, 200);
  offscreen.arc(x_off+dim/2, dim/2, 0.75*dim, 0.75*dim, PI, PI+PI*(position-min_pos)/(max_pos-min_pos), PIE);
  offscreen.fill(50, 100);
  offscreen.ellipse(x_off+dim/2, dim/2, dim/3, dim/3);
  offscreen.fill(255);
  offscreen.textAlign(CENTER, CENTER);
  offscreen.text(position, x_off+dim/2, dim/2 + 20);
  
  offscreen.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(255);
  lights();
 
  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
}
