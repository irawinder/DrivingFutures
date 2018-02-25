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
  image(structures.img, 0, 0, b.x, b.y);
  
  for (Parking p: structures.parking) {
    if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
      pushMatrix();
      translate(p.location.x, p.location.y);
      fill(#339933, 150);
      box(0.05*sqrt(p.area), 0.05*sqrt(p.area), 0.05*sqrt(p.area));
      popMatrix();
    } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
      pushMatrix();
      translate(p.location.x, p.location.y, -0.05*sqrt(p.area));
      fill(#993333, 150);
      box(0.05*sqrt(p.area), 0.05*sqrt(p.area), 0.05*sqrt(p.area));
      popMatrix();
    }
  }
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  translate(0,0,1);
  boolean collisionDetection = true;
  for (Agent p: vehicles) {
    p.update(vehicleLocations(vehicles), collisionDetection);
    if (p.type.equals("SOV")) {
      p.display(#0066FF, 255);
    } else {
      p.display(#FF00FF, 255);
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
  fill(#3366CC);
  text("Single Occupancy Vehicle", cam.MARGIN*width, 150 + 1*16);
  fill(#CC3333);
  text("Below Ground Parking", cam.MARGIN*width, 150 + 3*16);
  fill(#CCCC33);
  text("Surface Parking", cam.MARGIN*width, 150 + 4*16);
  fill(#33CC33);
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