/*  SHARED AUTONOMOUS FUTURE
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  The Future of Parking is an application that simulates and visualizes 
 *  parking utilization for passenger vehicles in hypothetical scenarios.
 *
 *  TAB MAP:
 *
 *      "A_" denotes high layer of organization on par with FutureParking.pde
 *
 *      FutureParking.pde - highest level layer containing most interdependencies and complexity
 *      A_Draw.pde        - might as well be in FutureParking.pde but placed in it's own tab for ease of editing
 *      A_Parking.pde     - might as well be in FutureParking.pde but placed in it's own tab for ease of editing
 *      Agent.pde, Camera.pde, Pathfinder.pde, Toolbar.pde - Primitive class modules with no interdependencies
 *
 *  PRIMARY CLASSES:
 *
 *      These are not necessarily inter-dependent
 *
 *      Parking_System()     - Mathematically realated parameters to forcast vheicle and parking demand over time using logistic equations   
 *      Parking_Structures() - A portfolio of Parking Structures (Surface, Below Ground, and Above Ground)
 *      Agent()              - A force-based autonomous agent that can navigate along a series of waypoints that comprise a path
 *      Camera()             - The primary container for implementing and editing Camera parameters
 *      ToolBar()            - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
 *
 *  DATA INPUT:
 *
 *      A simulation is populated with the following structured data CSVs, usually exported from
 *      ArcGIS or QGIS from available OSM files
 *
 *      Vehicle Road Network CSV
 *      Comma separated values where each node in the road network 
 *      represented as a row with the following 3 columns of information (i.e. data/roads.csv):
 *        
 *          X (Lat), Y (Lon), Road_ID
 *
 *      Parking Structure Nodes CSV
 *      Comma Separated values where each row describes a 
 *      parking structure (i.e. data/parking_nodes.csv):
 *
 *          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 *
 *      Parking Structure Polygons CSV
 *      Comma Separated values where each row describes a 
 *      node of a parking structure polygon in the order that it is drawn (i.e. 
 *      data/parking_poly.csv):
 *
 *          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 *
 *  MIT LICENSE:  Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 
//  GeoLocation Parameters:
float latCtr, lonCtr, tol, latMin, latMax, lonMin, lonMax;

//  Object to define and capture paths to collection of origins, destinations:
Parking_Routes routes;
//  Object to define parking facilities:
Parking_Structures structures;
//  Object to Define Systems Model
Parking_System sys;

//  Objects to define agents that navigate our environment:
ArrayList<Agent> type1;
ArrayList<Agent> type2;
ArrayList<Agent> type3;
ArrayList<Agent> type4;

// Objects for importing road network
//
RoadNetwork rNetwork;
Graph network;

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B = new PVector(6000, 6000, 0); // Bounding Box for 3D Environment
int MARGIN = 25; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

// Locations of objects user can place with mouse
//
ArrayList<PVector> additions; 

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
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = height - 2*MARGIN;
  
  // Initialize Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "Shared Autonomous Future V1.1";
  bar_left.credit = "I. Winder, D. Vasquez, K. Kusina,\nA. Starr, K. Silvester, JF Finn";
  bar_left.explanation = "Explore a hypothetical future of shared and autonomous vehicles.";
  bar_left.explanation += "\n[r] <- Press 'r' key to reset";
  bar_left.controlY = BAR_Y + bar_left.margin + 4*bar_left.CONTROL_H;
  bar_left.addSlider("Year of Analysis",              "",  2010, 2030, 2018, 'q', 'w');
  bar_left.addSlider("Annual Vehicle Trip Growth",    "%", -2,      5,    3, 'Q', 'W');
  bar_left.addSlider("RideShare: System Equilibrium", "%", 0,     100,   50, 'a', 's');
  bar_left.addSlider("RideShare: Peak Hype",          "",  2010, 2030, 2018, 'A', 'S');
  bar_left.addSlider("AV: System Equilibrium",        "%",    0,  100,   90, 'z', 'x');
  bar_left.addSlider("AV: Peak Hype",                 "",  2010, 2030, 2024, 'Z', 'X');
  bar_left.addTriSlider("Parking\nVacancy\nPriority", "Below\nGround", belowColor, 
                                                      "Surface\nParking", surfaceColor, 
                                                      "Above\nGround", aboveColor);
  bar_left.addButton("BLANK", 0, true, ' '); // Spacer for Parking and Vehicle Button Lables
  bar_left.addButton("Below",               belowColor,    true, '1');
  bar_left.addButton("Surface",             surfaceColor,  true, '2');
  bar_left.addButton("Above",               aboveColor,    true, '3');
  bar_left.addButton("RSVD",                reservedColor, true, '4');
  bar_left.addButton("Private",             car1Color,     true, '5');
  bar_left.addButton("Shared",              car2Color,     true, '6');
  bar_left.addButton("AV Private",          car3Color,     true, '7');
  bar_left.addButton("AV Shared",           car4Color,     true, '8');
  bar_left.buttons.remove(0); // Remove blanks
  for (int i=0; i<4; i++) {   // Shift last 4 buttons right
    bar_left.buttons.get(i+4).xpos = bar_left.barX + bar_left.barW/2; 
    bar_left.buttons.get(i+4).ypos = bar_left.buttons.get(i).ypos;
  }
  
  // Initialize Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "[Analysis] System Projections";
  bar_right.credit = "";
  bar_right.explanation = "";
  bar_right.controlY = BAR_Y + bar_right.margin + bar_left.CONTROL_H;

  // Initialize Simulation Components
  initEnvironment(); println("Environment Initialized");
  initPaths();       println("Paths Initialized");
  
  // Initialize the Camera
  // cam = new Camera(toolbar_width, b, -350, 50, 0.7, 0.1, 2.0, 0.45);
  // Initialize 3D World Camera Defaults
  cam = new Camera (B, MARGIN);
  // eX, eW (extentsX ...) prevents accidental dragging when interactiong with toolbar
  cam.eX = MARGIN + BAR_W;
  cam.eW = width - 2*(BAR_W + MARGIN);
  cam.X_DEFAULT    = -350;
  cam.Y_DEFAULT     =   50;
  cam.ZOOM_DEFAULT = 0.45;
  cam.ZOOM_POW     = 2.00;
  cam.ZOOM_MAX     = 0.10;
  cam.ZOOM_MIN     = 0.70;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.enableChunks = false;  // Enable/Disable 3D mouse cursor
  cam.init(); //Must End with init() if any variables within Camera() are changed from default
  
  // Setup System Simulation
  sys = new Parking_System(901, 2010, 2030);
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
  
  // Sample 3D objects to manipulate
  additions = new ArrayList<PVector>();
  
  network.saveJSON();
}

// Set System Parameters According to Slider Values
//
void setSliders() {
  sys.year_now                  = int(bar_left.sliders.get(0).value);
  sys.demand_growth             = bar_left.sliders.get(1).value/100.0;
  sys.av_share                  = bar_left.sliders.get(2).value/100.0;
  sys.av_peak_hype_year         = int(bar_left.sliders.get(3).value);
  sys.rideShare_share           = bar_left.sliders.get(4).value/100.0;
  sys.rideShare_peak_hype_year  = int(bar_left.sliders.get(5).value);
  sys.priorityBelow             = bar_left.tSliders.get(0).value1;
  sys.prioritySurface           = bar_left.tSliders.get(0).value2;
  sys.priorityAbove             = bar_left.tSliders.get(0).value3;
  showBelow                     = bar_left.buttons.get(0).value;
  showSurface                   = bar_left.buttons.get(1).value;
  showAbove                     = bar_left.buttons.get(2).value;
  showReserved                  = bar_left.buttons.get(3).value;
  showCar1                      = bar_left.buttons.get(4).value;
  showCar2                      = bar_left.buttons.get(5).value;
  showCar3                      = bar_left.buttons.get(6).value;
  showCar4                      = bar_left.buttons.get(7).value;
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
  int graphWidth = int(B.x);  // pixels
  int graphHeight = int(B.y); // pixels
  network = new Graph(graphWidth, graphHeight, latMin, latMax, lonMin, lonMax, nodeResolution, rNetwork);
  
  //  A list of parking structures
  //
  structures = new Parking_Structures(int(B.x), int(B.y), latMin, latMax, lonMin, lonMax);
}

void initPaths() {
  // Collection of routes to and from home, work, and parking ammentities
  routes = new Parking_Routes(int(B.x), int(B.y), network, structures);
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
      cam.showFrameRate = !cam.showFrameRate;
      break;
    case 'c':
      cam.reset();
      break;
    case 'r':
      bar_left.restoreDefault();
      bar_right.restoreDefault();
      bar_left.pressed();
      bar_right.pressed();
      setSliders();
      setParking();
      sys.update();
      setParking();
      updatePopulation();
      additions.clear();
      break;
    //case 'p':
    //  initPopulation();
    //  break;
    //case 'p':
    //  println("cam.offset.x = " + cam.offset.x);
    //  println("cam.offset.x = " + cam.offset.x);
    //  println("cam.zoom = "     + cam.zoom);
    //  println("cam.rotation = " + cam.rotation);
    //  break;
  }
}

void mousePressed() {
  cam.pressed();
  bar_left.pressed();
  bar_right.pressed();
  sys.update();
  updatePopulation();
}

void mouseMoved() {
  cam.moved();
}

void mouseReleased() {
  bar_left.released();
  bar_right.released();
  sys.update();
  updatePopulation();
}

void mouseDragged() {
  sys.update();
  updatePopulation();
}

void mouseClicked() {
  if (cam.chunkField.closestFound && cam.enableChunks) {
    additions.add(cam.chunkField.closest.location);
  }
}