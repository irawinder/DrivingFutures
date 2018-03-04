boolean showCar1 = true;
boolean showCar2 = true;
boolean showCar3 = true;
boolean showCar4 = true;
boolean showBelow = true;
boolean showSurface = true;
boolean showAbove = true;
boolean showReserved = true;

void draw() {
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
  
  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****
  
  
  
  // -------------------------
  // Begin Drawing 3D Elements
  
  //  Displays the Graph in grayscale.
  //
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
  
  for (Parking p: structures.parking) {
    pushMatrix();
    
    boolean overRide = false;
    if (p.capacity > 0 || overRide) {
      
      // Draw Fill / ID Dot
      //
      int alpha = 200;
      noStroke();
      boolean show = false;
      String sub = "";
      if (p.type.length() >= 3) sub = p.type.substring(0,3);
      if (sub.equals("Bel") && showBelow) {
        fill(belowColor, alpha);
        show = true;
      } else if (sub.equals("Sur") && showSurface) {
        fill(surfaceColor, alpha);
        show = true;
      } else if (sub.equals("Sta") && showAbove) {
        fill(aboveColor, alpha);
        show = true;
      } else if (showReserved && !sub.equals("Bel") && !sub.equals("Sur") && !sub.equals("Sta")) {
        fill(reservedColor, alpha);
        show = true;
      } 
      
      if (show) {
        // Draw Parking Button/Icon
        translate(0,0,1);
        ellipse(p.location.x, p.location.y, 2.0*sqrt( max(structures.minCap, p.capacity) ), 2.0*sqrt( max(structures.minCap, p.capacity) ));
        
        // Draw Parking Utilization
        translate(0,0,1);
        noStroke();
        fill(255, 200);
        //ellipse(p.location.x, p.location.y, 0.1*sqrt(p.ratio*p.area), 0.1*sqrt(p.ratio*p.area));
        if (p.utilization > 0 && p.capacity > 0) {
          arc(p.location.x, p.location.y, 1.75*sqrt( max(structures.minCap, p.capacity) ), 1.75*sqrt( max(structures.minCap, p.capacity) ), 0, p.ratio*2*PI);
        }
        noFill();
      }
      
      // Draw Capacity Text
      //
      translate(0,0,1);
      fill(0, 255);
      textAlign(CENTER, CENTER);
      text(p.capacity - p.utilization, p.location.x, p.location.y);
    } else {
      // Draw Capacity Text
      //
      translate(0,0,1);
      fill(255, 255);
      textAlign(CENTER, CENTER);
      text(p.capacity - p.utilization, p.location.x, p.location.y);
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
  
  // Click-Object: Draw mouse-based object additions
  if (additions.size() > 0) {
    for (PVector v: additions) {
      pushMatrix(); translate(v.x, v.y, v.z + 15);
      fill(#00FF00, 200); noStroke();
      sphere(15);
      popMatrix();
    }
  }
  
  // Click-Object: Draw Selection Cursor
  float cursorX = 0;
  float cursorY = 0;
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
  
  //Agent p;
  //float s_x = 0;
  //float s_y = 0;
  //if (type1.size() > 0) {
  //  p = type1.get(0);
  //  s_x = screenX(p.location.x, p.location.y, p.location.z);
  //  s_y = screenX(p.location.x, p.location.y, p.location.z);
  //  p.display(#FF0000, 200);
  //  println(p.location.x, p.location.y, p.location.y, s_x, s_y);
  //}
  
  // -------------------------
  // Begin Drawing 2D Elements
  hint(DISABLE_DEPTH_TEST);
  camera(); noLights(); perspective(); 
  
  //if (type1.size() > 0) {
  //  noFill();
  //  stroke(#FF0000);
  //  ellipse(s_x, s_y, 25, 25);
  //}
  
  // Click-Object: Draw Cursor Text
  float diam = min(100, 5/pow(cam.zoom, 2));
  if (cam.chunkField.closestFound) {
    fill(#00FF00, 200); textAlign(LEFT, CENTER);
    text("Place Marker", cursorX + 0.3*diam, cursorY);
  }
  
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
  text("Parking", 0, 0);
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

ArrayList<PVector> vehicleLocations(ArrayList<Agent> vehicles) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: vehicles) {
    l.add(a.location);
  }
  return l;
}