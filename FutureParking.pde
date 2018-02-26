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
 
//  Geometric Parameters:
float latCtr, lonCtr, tol, latMin, latMax, lonMin, lonMax;

// Objects to define our Network:
//
RoadNetwork rNetwork;
Graph network;

//  Object to define and capture paths to collection of origins, destinations:
TravelRoutes routes;

//  Object to define parking facilities:
ParkingStructures structures;

//  Objects to define agents that navigate our environment:
ArrayList<Agent> vehicles;

//  3D Environment and UI
//
Camera cam;
PVector b = new PVector(6000, 6000, 0); //Bounding Box for Environment (px)

boolean showFrameRate = false;

void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  //  Parameter Space for Geometric Area
  //
  latCtr = +42.350;
  lonCtr = -71.066;
  tol    =  0.035;
  latMin = latCtr - tol;
  latMax = latCtr + tol;
  lonMin = lonCtr - tol;
  lonMax = lonCtr + tol;
  
  // Initialize Simulation Components
  initEnvironment(); println("Environment Initialized");
  initPaths();       println("Paths Initialized");
  initPopulation();  println("Population Initialized");
  
  // Initialize the Camera
  cam = new Camera(b, -150, 200, 0.7, 0.1, 2.0, 0.4);
}

void initEnvironment() {
  
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
  Agent vehicle;
  PVector loc;
  int random_waypoint;
  float random_speed;
  vehicles = new ArrayList<Agent>();
  Path random;
  boolean loop = true;
  boolean teleport = true;
  for (int i=0; i<1000; i++) {
    random = routes.paths.get( int(random(routes.paths.size())) );
    if (random.waypoints.size() > 1) {
      random_waypoint = int(random(random.waypoints.size()));
      random_speed = 3.0*random(0.3, 0.4);
      //random_speed = 1.5;
      loc = random.waypoints.get(random_waypoint);
      vehicle = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints, loop, teleport, "RIGHT");
      vehicles.add(vehicle);
    }
  }
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