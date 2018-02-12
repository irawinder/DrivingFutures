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
//
ArrayList<Path> paths;

//  Objects to define agents that navigate our environment
//
ArrayList<Agent> people;

//  Geometric Parameters:
//
float latCtr, lonCtr, tol, latMin, latMax, lonMin, lonMax;

//  3D Environment and UI
//
Camera cam;
PVector b = new PVector(4000, 4000, 0); //Bounding Box for Environment (px)

boolean showFrameRate = false;

void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  initEnvironment();
  initPaths();
  initPopulation();
  
  // Initialize the Camera
  cam = new Camera(b, -295, 410, 0.4, 0.1, 2.0, 0.31);
}

void draw() {
  background(0);
  
  // Draw 3D Graphics
  cam.orient();
  
  //  Displays the Graph in grayscale.
  //
  tint(255, 75); // overlaid as an image
  image(network.img, 0, 0, b.x, b.y);
  
  //  Displays the path last calculated in Pathfinder.
  //  The results are overridden everytime findPath() is run.
  //  FORMAT: display(color, alpha)
  //
  //boolean showVisited = false;
  //finder.display(100, 150, showVisited);
  
  //  Displays the path properties.
  //  FORMAT: display(color, alpha)
  //
  //for (Path p: paths) {
  //  p.display(100, 20);
  //}
  //for (int i=0; i<paths.size(); i+=5) {
  //  paths.get(i).display(100, 20);
  //}
  
  //  Update and Display the population of agents
  //  FORMAT: display(color, alpha)
  //
  translate(0,0,1);
  boolean collisionDetection = true;
  for (Agent p: people) {
    p.update(personLocations(people), collisionDetection);
    p.display(#FFFF00, 200);
  }
  
  cam.drawControls();
  
  textAlign(CENTER, CENTER);
  fill(255);
  textAlign(LEFT, TOP);
  String fRate = "";
  if (showFrameRate) fRate = "\nFramerate: " + frameRate;
  text("Press 'r' to regenerate OD matrix\n" +
       "Press 'f' to show/hide framerate\n" +
       fRate, 20, 20);
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
  //rNetwork = new RoadNetwork(roadFile + ".csv", latMin, latMax, lonMin, lonMax); 
  //
  rNetwork = new RoadNetwork("data/roads.csv");
  
  //  An example gridded network of width x height (pixels) and node resolution (pixels)
  //
  int nodeResolution = 5;  // pixels
  int graphWidth = int(b.x);   // pixels
  int graphHeight = int(b.y); // pixels
  network = new Graph(graphWidth, graphHeight, nodeResolution, rNetwork);
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
  Path p;
  PVector origin, destination;
  for (int i=0; i<100; i++) {
    //  An example Origin and Desination between which we want to know the shortest path
    //
    int rand1 = int( random(network.nodes.size()));
    int rand2 = int( random(network.nodes.size()));
    origin      = network.nodes.get(rand1).loc;
    destination = network.nodes.get(rand2).loc;
    p = new Path(origin, destination);
    p.solve(finder);
    paths.add(p);
  }
}

void findPaths() {
  finder = new Pathfinder(network);
  
  for (Path p: paths) {
    p.solve(finder);
  }
  
  initPopulation();
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