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
ArrayList<Agent> vehicles;

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
  initPopulation();  println("Population Initialized");
  
  // Initialize the Camera
  cam = new Camera(toolbar_width, b, -350, 50, 0.7, 0.1, 2.0, 0.45);
  
  // Setup Toolbar
  //
  bar = new Toolbar(toolbar_width, int(cam.MARGIN*height));
  bar.title = "Shared AV Futures";
  bar.credit = "Ira Winder, 2018";
  bar.explanation = "Adjust the sliders to explore a hypothetical future of shared, autonomous vehicles.";
  
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
      
      // Select A Random Type Placeholder
      float r = random(0, 1);
      String type;
      if (r<0.5) {
        type = "1";
      } else if(r<0.7) {
        type = "2";
      } else if(r<0.9) {
        type = "3";
      } else {
        type = "4";
      }
      
      vehicle = new Agent(loc.x, loc.y, 2, random_speed, random.waypoints, loop, teleport, "RIGHT", type);
      vehicles.add(vehicle);
    }
  }
}

void keyPressed() {
  cam.moved();
  
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
      bar.restoreDefault();
      setSliders();
      setParking();
      sys.update();
      setParking();
      break;
    case 'p':
      initPopulation();
      break;
    case 't':
      println(cam.zoom, cam.offset.x, cam.offset.y);
      break;
  }
}

void mousePressed() {
  cam.pressed();
  bar.pressed();
  sys.update();
}

void mouseMoved() {
  cam.moved();
}

void mouseReleased() {
  bar.released();
  sys.update();
}

void mouseDragged() {
  sys.update();
}