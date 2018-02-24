/*  Future of Parking, Ira Winder and Gensler, 2018
 *
 *  The Future of Parking is an application that simulates and visualizes 
 *  parking utilization for passenger vehicles in hypothetical scenarios.
 *
 *  A simulation is populated with the following structured data CSVs, usually exported from
 *  ArcGIS or QGIS from available shape files
 *
 *  Vehicle Road Network CSV - Comma separated values where each node in the road network 
 *      represented as a row with the following 3 columns of information (i.e. data/roads.csv):
 *      
 *      X (Lat), Y (Lon), Road_ID
 *
 *  Parking Structure Nodes CSV - Comma Separated values where each row describes a 
 *      parking structure (i.e. data/parking_nodes.csv):
 *
 *      X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 *
 *  Parking Structure Polygons CSV - Comma Separated values where each row describes a 
 *      node of a parking structure polygon in the order that it is drawn (i.e. 
 *      data/parking_poly.csv):
 *
 *      X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 */
 
// Objects to define our Network
//
RoadNetwork rNetwork;
Graph network;
Pathfinder finder;

//  Object to define and capture a specific origin, destiantion, and path
ArrayList<Path> paths;
PGraphics pathsImg;

//  Object to define parking facilities
ArrayList<Parking> parking;
PGraphics parkingImg;

//  Objects to define agents that navigate our environment
ArrayList<Agent> people;

//  Geometric Parameters:
float latCtr, lonCtr, tol, latMin, latMax, lonMin, lonMax;

//  3D Environment and UI
//
Camera cam;
PVector b = new PVector(6000, 6000, 0); //Bounding Box for Environment (px)

boolean showFrameRate = false;

void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  initEnvironment();
  println("Environment Initiatlized");
  initPaths();
  println("Paths Initiatlized");
  initPopulation();
  println("Population Initiatlized");
  
  // Initialize the Camera
  cam = new Camera(b, -150, 200, 0.7, 0.1, 2.0, 0.4);
}

void draw() {
  background(20);
  
  // Draw 3D Graphics
  cam.orient();
  
  //  Displays the Graph in grayscale.
  //
  tint(255, 25); // overlaid as an image
  image(network.img, 0, 0, b.x, b.y);
  tint(255, 175);
  image(pathsImg, 0, 0, b.x, b.y);
  image(parkingImg, 0, 0, b.x, b.y);
  
  for (Parking p: parking) {
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
      
  //  Displays the path last calculated in Pathfinder.
  //  The results are overridden everytime findPath() is run.
  //  FORMAT: display(color, alpha)
  //
  //boolean showVisited = false;
  //finder.display(100, 150, showVisited);
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  translate(0,0,1);
  boolean collisionDetection = true;
  for (Agent p: people) {
    p.update(personLocations(people), collisionDetection);
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
  text("Total Parking Features: " + parking.size() + "\n" +
       "Total Vehicles: " + people.size(), cam.MARGIN*width, 150 + 8*16);
  
}

void initEnvironment() {
  //  Parameter Space for Geometric Area
  //
  latCtr = +42.350;
  lonCtr = -71.066;
  tol    =  0.035;
  latMin = latCtr - tol;
  latMax = latCtr + tol;
  lonMin = lonCtr - tol;
  lonMax = lonCtr + tol;
  
  //  A Road Network Created from a QGIS File
  //
  // Use this function rarely when you need to clean a csv file. It saves a new file to the data folder
  //rNetwork = new RoadNetwork("data/roads.csv", latMin, latMax, lonMin, lonMax); 
  //
  rNetwork = new RoadNetwork("data/roads.csv");
  
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 5;  // pixels
  int graphWidth = int(b.x);   // pixels
  int graphHeight = int(b.y); // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution, rNetwork);
  
  //  A list of parking structures
  //
  Table parkingCSV = loadTable("data/parking.csv", "header");
  parking = new ArrayList<Parking>();
  Parking park;
  float x, y, canvasX, canvasY, area;
  String type;
  int capacity;
  for (int i=0; i<parkingCSV.getRowCount(); i++) {
    x = parkingCSV.getFloat(i, 0);
    y = parkingCSV.getFloat(i, 1);
    canvasX  = b.x * (x - lonMin) / (2*tol);
    canvasY  = b.y - b.y * (y - latMin) / (2*tol);
    area = parkingCSV.getFloat(i, 7);
    type = parkingCSV.getString(i, "20171127_Parking Typology (use dropdown)");
    capacity = parkingCSV.getInt(i, "20171127_Gensler Revised Parking Spots");
    park = new Parking(canvasX, canvasY, area, type, capacity);
    parking.add(park);
  }
  println("Parking Structures Loaded: " + parking.size());
  
  parkingImg = createGraphics(int(b.x), int(b.y));
  parkingImg.beginDraw();
  parkingImg.clear();
  for (Parking p: parking) {
    if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
      parkingImg.fill(#FF0000, 150);
      parkingImg.stroke(#FF0000, 255);
    } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sur")) {
      parkingImg.fill(#FFFF00, 150);
      parkingImg.stroke(#FFFF00, 255);
    } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
      parkingImg.fill(#00FF00, 150);
      parkingImg.stroke(#00FF00, 255);
      pushMatrix();
      translate(p.location.x, p.location.y);
      fill(#00FF00, 150);
      box(0.1*sqrt(p.area), 0.1*sqrt(p.area), 0.05*sqrt(p.area));
      popMatrix();
    } else {
      parkingImg.fill(255, 150);
      parkingImg.stroke(255, 255);
    }
    parkingImg.strokeWeight(5);
    parkingImg.ellipse(p.location.x, p.location.y, 0.1*sqrt(p.area), 0.1*sqrt(p.area));
    parkingImg.fill(255);
    parkingImg.textAlign(CENTER, CENTER);
    parkingImg.text(p.capacity, p.location.x, p.location.y);
  }
  parkingImg.endDraw();
}

void initPaths() {
  //  An example pathfinder object used to derive the shortest path
  //  setting enableFinder to "false" will bypass the A* algorithm
  //  and return a result akin to "as the bird flies"
  //
  finder = new Pathfinder(network);
  
  //  FORMAT 1: Path(float x, float y, float l, float w)
  //  FORMAT 2: Path(PVector o, PVector d)
  //
  paths = new ArrayList<Path>();
  Path path;
  PVector origin, destination;
  
  boolean debug = false;
  
  if (debug) {
    
    for (int i=0; i<5; i++) {
      //  An example Origin and Desination between which we want to know the shortest path
      //
      int rand1 = int( random(network.nodes.size()));
      int rand2 = int( random(parking.size()));
      origin      = network.nodes.get(rand1).loc;
      destination = parking.get(rand2).location;
      path = new Path(origin, destination);
      path.solve(finder);
      paths.add(path);
    }
    
  } else {

    for (Parking p: parking) {
      //  An example Origin and Desination between which we want to know the shortest path
      //
      int rand1 = int( random(network.nodes.size()));
      origin      = network.nodes.get(rand1).loc;
      destination = p.location;
      path = new Path(origin, destination);
      path.solve(finder);
      paths.add(path);
    }
    
  }
  
  pathsImg = createGraphics(int(b.x), int(b.y));
  pathsImg.beginDraw();
  pathsImg.clear();
  for (Path p: paths) {
    // Draw Shortest Path
    //
    pathsImg.noFill();
    PVector n1, n2;
    for (int i=1; i<p.waypoints.size(); i++) {
      n1 = p.waypoints.get(i-1);
      n2 = p.waypoints.get(i);
      pathsImg.stroke(#00FF00, 20);
      pathsImg.strokeWeight(3);
      pathsImg.line(n1.x, n1.y, n2.x, n2.y);
    }
  }
  for (Path p: paths) {
    // Draw Origin (Red) and Destination (Blue)
    //
    pathsImg.fill(0, 255); // Green
    pathsImg.stroke(255, 255);
    pathsImg.strokeWeight(4);
    pathsImg.ellipse(p.origin.x, p.origin.y, p.diameter, p.diameter);
    //pathsImg.ellipse(p.destination.x, p.destination.y, p.diameter, p.diameter);
    
  }
  pathsImg.endDraw();
}

void initPopulation() {
  //  An example population that traverses along shortest path calculation
  //  FORMAT: Agent(x, y, radius, speed, path);
  //
  Agent person;
  PVector loc;
  int random_waypoint;
  float random_speed;
  people = new ArrayList<Agent>();
  Path random;
  for (int i=0; i<1000; i++) {
    random = paths.get( int(random(paths.size())) );
    if (random.waypoints.size() > 1) {
      random_waypoint = int(random(random.waypoints.size()));
      random_speed = 1.0*random(0.1, 0.3);
      loc = random.waypoints.get(random_waypoint);
      person = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints);
      people.add(person);
    }
  }
}

ArrayList<PVector> personLocations(ArrayList<Agent> people) {
  ArrayList<PVector> l = new ArrayList<PVector>();
  for (Agent a: people) {
    l.add(a.location);
  }
  return l;
}

void keyPressed() {
  switch(key) {
    case 'g':
      initPaths();
      initPopulation();
      break;
    case 'f':
      showFrameRate = !showFrameRate;
      break;
    case 'r':
      cam.reset();
      break;
    case 'p':
      println(cam.zoom, cam.offset.x, cam.offset.y);
      break;
  }
}

void mousePressed() {
  cam.pressed();
}

void mouseMoved() {
  cam.moved();
}