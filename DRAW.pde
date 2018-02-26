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
  tint(255, 255);
  image(structures.img, 0, 0, b.x, b.y);
  
  for (Parking p: structures.parking) {
    pushMatrix();
    
    if (p.utilization > 0 ) {
      
      // Draw Parking Utilization
      int minCap = 200;
      translate(0,0,5);
      noStroke();
      fill(255, 150);
      //ellipse(p.location.x, p.location.y, 0.1*sqrt(p.ratio*p.area), 0.1*sqrt(p.ratio*p.area));
      arc(p.location.x, p.location.y, 2.5*sqrt( max(structures.minCap, p.capacity) ), 2.5*sqrt( max(structures.minCap, p.capacity) ), 0, p.ratio*2*PI);
      noFill();
      
      // Draw Fill / ID Dot
      //
      translate(0,0,5);
      int alpha = 200;
      noStroke();
      if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
        fill(structures.belowColor, alpha);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sur")) {
        fill(structures.surfaceColor, alpha);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
        fill(structures.aboveColor, alpha);
      } else {
        fill(255, alpha);
      }
      ellipse(p.location.x, p.location.y, 2.0*sqrt( max(structures.minCap, p.capacity) ), 2.0*sqrt( max(structures.minCap, p.capacity) ));
      
      // Draw Capacity Text
      //
      translate(0,0,1);
      fill(0, 255);
      textAlign(CENTER, CENTER);
      text(p.capacity, p.location.x, p.location.y);
    } else {
      // Draw Capacity Text
      //
      translate(0,0,1);
      fill(255, 255);
      textAlign(CENTER, CENTER);
      text(p.capacity, p.location.x, p.location.y);
    }
    popMatrix();
  }
  
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  translate(0,0,1);
  boolean collisionDetection = false;
  for (Agent p: vehicles) {
    p.update(vehicleLocations(vehicles), collisionDetection);
    if (p.type.equals("SOV")) {
      p.display(255, 200);
    } else {
      p.display(#FF00FF, 200);
    }
  }
  
  cam.drawControls();
  
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
       "Total Vehicles: " + vehicles.size(), cam.MARGIN*width, 150 + 8*16);
  
}

ArrayList<PVector> vehicleLocations(ArrayList<Agent> vehicles) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: vehicles) {
    l.add(a.location);
  }
  return l;
}