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

//  Object to Define Systems Model
AV_System sys;

//  Objects to define agents that navigate our environment:
ArrayList<Agent> type1;
ArrayList<Agent> type2;
ArrayList<Agent> type3;
ArrayList<Agent> type4;

//  3D Environment and UI
Camera cam;
PVector b = new PVector(6000, 6000, 0); //Bounding Box for Environment (px)

Toolbar bar;
int toolbar_width = 250;

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
  
  // Initialize the Camera
  cam = new Camera(toolbar_width, b, -350, 50, 0.7, 0.1, 2.0, 0.45);
  
  // Setup Toolbar
  //
  bar = new Toolbar(toolbar_width, int(cam.MARGIN*height));
  bar.title = "Shared Autonomous Future, v1.0\n";
  bar.credit = "Ira Winder, Diana Vasquez, \nKevin Kusina, Andrew Starr, \nKarina Silvestor, JF Finn";
  bar.explanation = "Explore a hypothetical future of shared and autonomous vehicles";
  
  // Setup System Simulation
  sys = new AV_System(1000, 2010, 2030);
  sys.av_growth = 1.0;
  sys.rideShare_growth = 1.0;
  sys.totBelow = structures.totBelow / 100;
  sys.totSurface = structures.totSurface / 100;
  sys.totAbove = structures.totAbove / 100;
  setSliders();
  sys.update();
  setParking();
  
  // Initialize Vehicle Agents
  initPopulation();  println("Population Initialized");
}

// Set System Parameters According to Slider Values
//
void setSliders() {
  sys.year_now                  = int(bar.s1.value);
  sys.demand_growth             = bar.s2.value/100.0;
  sys.av_share                  = bar.s3.value/100.0;
  sys.av_peak_hype_year         = int(bar.s4.value);
  sys.rideShare_share           = bar.s5.value/100.0;
  sys.rideShare_peak_hype_year  = int(bar.s6.value);
  sys.priorityBelow             = bar.t1.value1;
  sys.prioritySurface           = bar.t1.value2;
  sys.priorityAbove             = bar.t1.value3;
  showBelow                     = bar.b1.value;
  showSurface                   = bar.b2.value;
  showAbove                     = bar.b3.value;
  showReserved                  = bar.b8.value;
  showCar1                      = bar.b4.value;
  showCar2                      = bar.b5.value;
  showCar3                      = bar.b6.value;
  showCar4                      = bar.b7.value;
}

void setParking() {
  int yr = sys.year_now - sys.year_0;
  float belowRatio   = 1 - float(sys.belowFree[yr])   / sys.totBelow;
  float surfaceRatio = 1 - float(sys.surfaceFree[yr]) / sys.totSurface;
  float aboveRatio   = 1 - float(sys.aboveFree[yr])   / sys.totAbove;
  for (Parking p: structures.parking) {
    if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
      p.ratio = belowRatio;
    } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sur")) {
      p.ratio = surfaceRatio;
    } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
      p.ratio = aboveRatio;
    }
    p.utilization = int(p.ratio*p.capacity);
  }
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
  int yr = sys.year_now - sys.year_0;
  
  type1 = new ArrayList<Agent>();
  type2 = new ArrayList<Agent>();
  type3 = new ArrayList<Agent>();
  type4 = new ArrayList<Agent>();
  
  for (int i=0; i<sys.numCar1[yr]; i++) addVehicle(type1, "1");
  for (int i=0; i<sys.numCar2[yr]; i++) addVehicle(type2, "2");
  for (int i=0; i<sys.numCar3[yr]; i++) addVehicle(type3, "3");
  for (int i=0; i<sys.numCar4[yr]; i++) addVehicle(type4, "4");
}

void updatePopulation() {
  int yr = sys.year_now - sys.year_0;
  
  while (type1.size() > sys.numCar1[yr]) type1.remove(0);
  while (type2.size() > sys.numCar2[yr]) type2.remove(0);
  while (type3.size() > sys.numCar3[yr]) type3.remove(0);
  while (type4.size() > sys.numCar4[yr]) type4.remove(0);
  
  while (type1.size() < sys.numCar1[yr]) addVehicle(type1, "1");
  while (type2.size() < sys.numCar2[yr]) addVehicle(type2, "2");
  while (type3.size() < sys.numCar3[yr]) addVehicle(type3, "3");
  while (type4.size() < sys.numCar4[yr]) addVehicle(type4, "4");
  
}

void addVehicle(ArrayList<Agent> array, String type) {
  //  An example population that traverses along shortest path calculation
  //  FORMAT: Agent(x, y, radius, speed, path);
  //
  Agent vehicle;
  PVector loc;
  int random_waypoint;
  float random_speed;
  
  Path random;
  boolean loop = true;
  boolean teleport = true;
  
  random = routes.paths.get( int(random(routes.paths.size())) );
  int wpts = random.waypoints.size();
  while (wpts < 2) {
    random = routes.paths.get( int(random(routes.paths.size())) );
    wpts = random.waypoints.size();
  }
  random_waypoint = int(random(random.waypoints.size()));
  random_speed = 3.0*random(0.3, 0.4);
  loc = random.waypoints.get(random_waypoint);
  vehicle = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints, loop, teleport, "RIGHT", type);
  array.add(vehicle);
}

void keyPressed() {
  cam.moved();
  
  switch(key) {
    //case 'g':
    //  initPaths();
    //  initPopulation();
    //  break;
    case 'f':
      showFrameRate = !showFrameRate;
      break;
    case 'r':
      cam.reset();
      bar.restoreDefault();
      setSliders();
      setParking();
      sys.update();
      setParking();
      updatePopulation();
      break;
    //case 'p':
    //  initPopulation();
    //  break;
    //case 't':
    //  println(cam.zoom, cam.offset.x, cam.offset.y);
    //  break;
  }
}

void mousePressed() {
  cam.pressed();
  bar.pressed();
  sys.update();
  updatePopulation();
}

void mouseMoved() {
  cam.moved();
}

void mouseReleased() {
  bar.released();
  sys.update();
  updatePopulation();
}

void mouseDragged() {
  sys.update();
  updatePopulation();
}