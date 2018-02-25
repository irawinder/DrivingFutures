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

//  Object to define and capture a specific origin, destiantion, and path
TravelRoutes routes;

//  Object to define parking facilities
ParkingStructures structures;


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
  
  // Initialize Simulation Components
  initEnvironment(); println("Environment Initialized");
  initPaths();       println("Paths Initialized");
  initPopulation();  println("Population Initialized");
  
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
  
  //  A Road Network Created from a QGIS OSM File
  //
  // Use this function rarely when you need to clean a csv file. It saves a new file to the data folder
  //rNetwork = new RoadNetwork("data/roads.csv", latMin, latMax, lonMin, lonMax);
  //
  rNetwork = new RoadNetwork("data/roads.csv");
  
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 5;     // pixels
  int graphWidth = int(b.x);  // pixels
  int graphHeight = int(b.y); // pixels
  network = new Graph(graphWidth, graphHeight, latMin, latMax, lonMin, lonMax, nodeResolution, rNetwork);
  
  //  A list of parking structures
  //
  structures = new ParkingStructures(int(b.x), int(b.y), latMin, latMax, lonMin, lonMax);
}

void initPaths() {
  // Collection of routes to and from home, work, and parking ammentities
  routes = new TravelRoutes(int(b.x), int(b.y), network, structures);
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
  boolean loop = true;
  boolean teleport = true;
  for (int i=0; i<1000; i++) {
    random = routes.paths.get( int(random(routes.paths.size())) );
    if (random.waypoints.size() > 1) {
      random_waypoint = int(random(random.waypoints.size()));
      random_speed = 10.0*random(0.1, 0.3);
      loc = random.waypoints.get(random_waypoint);
      person = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints, loop, teleport, "RIGHT");
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
      initPopulation();
      break;
  }
}

void mousePressed() {
  cam.pressed();
}

void mouseMoved() {
  cam.moved();
}