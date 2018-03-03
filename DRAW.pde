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
  
  // Draw 3D Graphics
  cam.orient();
  
  //  Displays the Graph in grayscale.
  //
  tint(255, 25); // overlaid as an image
  image(network.img, 0, 0, b.x, b.y);
  tint(255, 175);
  image(routes.img, 0, 0, b.x, b.y);
  //tint(255, 255);
  //image(structures.img, 0, 0, b.x, b.y);
  
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
  
  cam.drawControls();
  
  
  //if (type1.size() > 0) {
  //  noFill();
  //  stroke(#FF0000);
  //  ellipse(s_x, s_y, 25, 25);
  //}
  
  // Draw Margin Toolbar
  bar.draw();
  
  // Synchronize Sliders to Systems Model
  //
  setSliders();
  
  // Synchronized Systems Model to Parking
  //
  setParking();
  
  // Draw System Output
  //
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  translate(width - bar.GAP - 200 - 2*bar.U_OFFSET, bar.GAP);
  
  // Shadow of Canvas
  //
  pushMatrix();
  translate(3, 3);
  noStroke();
  fill(0, 220);
  if (height > 800) {
    rect(0, 0, 200 + 2*bar.U_OFFSET, 800 - bar.GAP, bar.GAP);
  } else {
    rect(0, 0, 200 + 2*bar.U_OFFSET, height - 5*bar.GAP, bar.GAP);
  }
  popMatrix();
  
  // Canvas
  //
  fill(255, 20);
  noStroke();
  if (height > 800) {
    rect(0, 0, 200 + 2*bar.U_OFFSET, 800 - bar.GAP, bar.GAP);
  } else {
    rect(0, 0, 200 + 2*bar.U_OFFSET, height - 5*bar.GAP, bar.GAP);
  }
  popMatrix();
  
  pushMatrix();
  translate(0, bar.U_OFFSET);
  sys.plot4("Vehicle Counts [100's]",          sys.numCar1,   sys.numCar2,   sys.numCar3,     sys.numCar4,   car1Color,  car2Color,  car3Color,    car4Color,  width - bar.GAP - 200 - int(1.4*bar.U_OFFSET), bar.GAP+000, 200 + bar.U_OFFSET, 125, 0.04);
  sys.plot4("Trips by Vehicle Type [100's]",   sys.numTrip1,  sys.numTrip2,  sys.numTrip3,    sys.numTrip4,  car1Color,  car2Color,  car3Color,    car4Color,  width - bar.GAP - 200 - int(1.4*bar.U_OFFSET), bar.GAP+165, 200 + bar.U_OFFSET, 125, 0.03);
  sys.plot4("Parking Space Demand [100's]",    sys.numPark1,  sys.numPark2,  sys.numPark3,    sys.numPark4,  car1Color,  car2Color,  car3Color,    car4Color,  width - bar.GAP - 200 - int(1.4*bar.U_OFFSET), bar.GAP+330, 200 + bar.U_OFFSET, 125, 0.08);
  sys.plot4("Parking Space Vacancy [100's]",   sys.otherFree, sys.belowFree, sys.surfaceFree, sys.aboveFree, #990000,    belowColor, surfaceColor, aboveColor, width - bar.GAP - 200 - int(1.4*bar.U_OFFSET), bar.GAP+495, 200 + bar.U_OFFSET, 125, 0.08);
  
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  
  /*
  textAlign(CENTER, CENTER);
  fill(255, 200);
  textAlign(LEFT, TOP);
  String fRate = "";
  if (showFrameRate) fRate = "\nFramerate: " + frameRate;
  text("Gensler Future of Parking, Beta\n" +
       "Diana Vasquez, Kevin Kusina, Andrew Starr, Karina Silvestor, JF Finn, Ira Winder\n\n" +
       "Press ' p ' to regenerate vehicles\n" +
       "Press ' g ' to regenerate OD matrix\n" +
       "Press ' f ' to show/hide framerate\n" +
       fRate, cam.MARGIN*width, cam.MARGIN*height);
  fill(#CC33CC);
  text("Share Ride Vehicle", cam.MARGIN*width, 150);
  fill(255);
  text("Single Occupancy Vehicle", cam.MARGIN*width, 150 + 1*16);
  fill(structures.belowColor);
  text("Below Ground Parking", cam.MARGIN*width, 150 + 3*16);
  fill(structures.surfaceColor);
  text("Surface Parking", cam.MARGIN*width, 150 + 4*16);
  fill(structures.aboveColor);
  text("Parking Structure", cam.MARGIN*width, 150 + 5*16);
  fill(255);
  text("Uncategorized Parking", cam.MARGIN*width, 150 + 6*16);
  
  fill(255);
  text("Total Parking Features: " + structures.parking.size() + "\n" +
       "Total Vehicles: " + type1.size(), cam.MARGIN*width, 150 + 8*16);
  */
}

ArrayList<PVector> vehicleLocations(ArrayList<Agent> vehicles) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: vehicles) {
    l.add(a.location);
  }
  return l;
}