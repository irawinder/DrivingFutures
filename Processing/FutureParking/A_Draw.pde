/*  DRIVING FUTURES
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Draw Functions (Superficially Isolated from FutureParking.pde)
 *
 *  MIT LICENSE:  Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 
boolean showCar1 = true;
boolean showCar2 = true;
boolean showCar3 = true;
boolean showCar4 = true;
boolean showBelow = true;
boolean showSurface = true;
boolean showAbove = true;
boolean showReserved = true;
boolean SHOW_INFO = true;

// Car Colors
int car1Color = #999999;
int car2Color = #FF00FF;
int car3Color = #00FFFF;
int car4Color = #FFFF00;
 
// Parking Colors
int reservedColor = #999999;
int belowColor    = #CC99FF;
int surfaceColor  = #FFBB66;
int aboveColor    = #5555FF;

// Road Color
int roadColor = #FFAAAA;

boolean initialized = false;

void run() {

  background(20);
  
  // -------------------------
  // Begin Updating backend system components
  
  // Update camera position settings for a number of frames after key updates
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  // Synchronize Sliders to Systems Model
  //
  setSliders();
  
  // Synchronized Systems Model to Parking
  //
  setParking();
  
  // Draw and Calculate 3D Graphics 
  cam.orient();
  
  
  
  // -------------------------
  // Begin Drawing 3D Elements
  //
  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****
  
  //  Displays the Graph in grayscale.
  //
  fill(roadColor); stroke(255); // Default Colors
  tint(255, 25); // overlaid as an image
  image(network.img, 0, 0, B.x, B.y);
  tint(255, 175);
  image(routes.img, 0, 0, B.x, B.y);
  //tint(255, 255);
  //image(structures.img, 0, 0, B.x, B.y);
  
  //// Field: Draw Selection Field
  ////
  //pushMatrix(); translate(0, 0, 1);
  //image(cam.chunkField.img, 0, 0, B.x, B.y);
  //popMatrix();
  
  // Draw Parking Infrastructure
  //
  for (Parking p: structures.parking) {
    pushMatrix();
    
    boolean OVER_RIDE = false;
    if (p.capacity > 0 || OVER_RIDE) {
      
      
      // Draw Fill / ID Dot
      String sub = "";
      if (p.type.length() >= 3) sub = p.type.substring(0,3);
      p.show = false;
      if (sub.equals("Bel") && showBelow) {
        p.show = true;
      } else if (sub.equals("Sur") && showSurface) {
        p.show = true;
      } else if (sub.equals("Sta") && showAbove) {
        p.show = true;
      } else if (showReserved && !sub.equals("Bel") && !sub.equals("Sur") && !sub.equals("Sta")) {
        p.show = true;
      } 
      
      if (p.show) {
        // Find Screen location of parking ammenity
        p.setScreen();
    
        // Draw Parking Button/Icon
        translate(0,0,1);
        noStroke();
        if (p.highlight) {
          fill(p.col, 255);
        } else {
          fill(p.col, 200);
        }
        ellipse(p.location.x, p.location.y, 2.0*sqrt( max(structures.minCap, p.capacity) ), 2.0*sqrt( max(structures.minCap, p.capacity) ));
        
        // Draw Parking Utilization
        translate(0,0,3);
        noStroke();  
        if (p.highlight) {
          fill(0, 150);
        } else {
          fill(0, 200);
        }
        //ellipse(p.location.x, p.location.y, 0.1*sqrt(p.ratio*p.area), 0.1*sqrt(p.ratio*p.area));
        if (p.utilization > 0 && p.capacity > 0) {
          arc(p.location.x, p.location.y, -10 + 2.0*sqrt( max(structures.minCap, p.capacity) ), -10 + 2.0*sqrt( max(structures.minCap, p.capacity) ), 0, p.ratio*2*PI);
        }
      
        // Draw Capacity Text
        //
        translate(0,0,1);
        fill(255, 255);
        textAlign(CENTER, CENTER);
        if (p.capacity - p.utilization > 0) text(p.capacity - p.utilization, p.location.x, p.location.y);
      } 
    }
    popMatrix();
  }
  
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  translate(0,0,1);
  boolean collisionDetection = false;
  if (showCar1) {
    for (Agent p: type1) {
      p.update(vehicleLocations(type1), collisionDetection);
      p.display(car1Color, 200);
    }
  }
  if (showCar2) {
    for (Agent p: type2) {
      p.update(vehicleLocations(type1), collisionDetection);
      p.display(car2Color, 200);
    }
  }
  if (showCar3) {
    for (Agent p: type3) {
      p.update(vehicleLocations(type1), collisionDetection);
      p.display(car3Color, 200);
    }
  }
  if (showCar4) {
    for (Agent p: type4) {
      p.update(vehicleLocations(type1), collisionDetection);
      p.display(car4Color, 200);
    }
  }
  
  if (cam.enableChunks) {
    // Click-Object: Draw mouse-based object additions
    if (additions.size() > 0) {
      for (PVector v: additions) {
        pushMatrix(); translate(v.x, v.y, v.z + 15);
        fill(#00FF00, 200); noStroke();
        sphere(15);
        popMatrix();
      }
    }
  }
  
  // Click-Object: Draw Selection Cursor
  float cursorX = 0;
  float cursorY = 0;
  if (cam.enableChunks) {
    //cam.chunkField.drawCursor();
    if (cam.chunkField.closestFound) {
      Chunk c = cam.chunkField.closest;
      PVector loc = c.location;
      
      // Place Ghost of Object to Place
      pushMatrix(); translate(loc.x, loc.y, loc.z + 15);
      fill(#00FF00, 100); noStroke();
      sphere(15);
      popMatrix();
      
      // Calculate Curson Screen Location
      cursorX = screenX(loc.x, loc.y, loc.z + 30/2.0);
      cursorY = screenY(loc.x, loc.y, loc.z + 30/2.0);
    }
  }
  
  // -------------------------
  // Begin Drawing 2D Elements
  hint(DISABLE_DEPTH_TEST);
  camera(); noLights(); perspective(); 
  
  if (SHOW_INFO) {
    // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
    cam.drawControls();
    
    // Draw Margin Toolbar
    bar_left.draw();
    bar_right.draw();
    
    // Radio Button Labels:
    //
    textAlign(LEFT, BOTTOM);
    pushMatrix(); translate(bar_left.barX + bar_left.margin, 17.5*bar_left.CONTROL_H);
    text("Parking", 0, 0);
    translate(bar_left.contentW/2, 0);
    text("Vehicles", 0, 0);
    popMatrix();
    
    // Draw System Output
    //
    hint(DISABLE_DEPTH_TEST);
    pushMatrix(); translate(bar_right.barX + bar_right.margin, bar_right.controlY);
    sys.plot4("Vehicle Counts", "[100's]",       sys.numCar1,   sys.numCar2,   sys.numCar3,     sys.numCar4,   car1Color,  car2Color,  car3Color,    car4Color,  0,   0, bar_right.contentW, 125, 0.04);
    sys.plot4("Trips by Vehicle Type", "[100's]",sys.numTrip1,  sys.numTrip2,  sys.numTrip3,    sys.numTrip4,  car1Color,  car2Color,  car3Color,    car4Color,  0, 165, bar_right.contentW, 125, 0.03);
    sys.plot4("Parking Space Demand", "[100's]", sys.numPark1,  sys.numPark2,  sys.numPark3,    sys.numPark4,  car1Color,  car2Color,  car3Color,    car4Color,  0, 330, bar_right.contentW, 125, 0.08);
    sys.plot4("Parking Space Vacancy", "[100's]",sys.otherFree, sys.belowFree, sys.surfaceFree, sys.aboveFree, #990000,    belowColor, surfaceColor, aboveColor, 0, 495, bar_right.contentW, 125, 0.08);
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }
  
  // Find Nearest Vehicle or Parking Entity
  //
  int index = 0; String type = "";
  PVector mouse = new PVector(mouseX, mouseY);
  float shortestDistance = Float.POSITIVE_INFINITY;
  int MIN_DIST = 50;
  if (showCar1) for (int i=0; i<type1.size(); i++) {
    Agent p = type1.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; index = i; type = "car1";
    }
  }
  if (showCar2) for (int i=0; i<type2.size(); i++) {
    Agent p = type2.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; index = i; type = "car2";
    }
  }
  if (showCar3) for (int i=0; i<type3.size(); i++) {
    Agent p = type3.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; index = i; type = "car3";
    }
  }
  if (showCar4) for (int i=0; i<type4.size(); i++) {
    Agent p = type4.get(i);
    p.highlight = false;
    float dist = mouseDistance(mouse, p.s_x, p.s_y);
    if ( dist < shortestDistance && dist < MIN_DIST ) {
      shortestDistance = dist; index = i; type = "car4";
    }
  }
  for (int i=0; i<structures.parking.size(); i++) {
    Parking p = structures.parking.get(i);
    p.highlight = false;
    if (p.show) {
      float dist = mouseDistance(mouse, p.s_x, p.s_y);
      if ( dist < shortestDistance && dist < MIN_DIST ) {
        shortestDistance = dist; index = i; type = "parking";
      }
    }
  }
  
  // Set Diameter of Cursor
  //
  float diam = min(50, 5/pow(cam.zoom, 2));
  
  // Recall Nearest Object and draw cursor
  //
  noFill(); stroke(255);
  if (type.equals("car1")) {
    Agent p = type1.get(index);
    p.highlight = true;
  } else if (type.equals("car2")) {
    Agent p = type2.get(index);
    p.highlight = true;
  } else if (type.equals("car3")) {
    Agent p = type3.get(index);
    p.highlight = true;
  } else if (type.equals("car4")) {
    Agent p = type4.get(index);
    p.highlight = true;
  } else if (type.equals("parking")) {
    Parking p = structures.parking.get(index);
    p.highlight = true;
    p.displayInfo();
  }
  
  if (cam.enableChunks) {
    // Click-Object: Draw Cursor Text
    diam = min(100, 5/pow(cam.zoom, 2));
    if (cam.chunkField.closestFound) {
      fill(#00FF00, 200); textAlign(LEFT, CENTER);
      text("Place Marker", cursorX + 0.3*diam, cursorY);
    }
  }
  
}

float mouseDistance (PVector mouse, float s_x, float s_y) {
  return abs(mouse.x-s_x) + abs(mouse.y-s_y);
}

ArrayList<PVector> vehicleLocations(ArrayList<Agent> vehicles) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: vehicles) {
    l.add(a.location);
  }
  return l;
}