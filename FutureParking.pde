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
  //size(1280, 800, P3D);
  fullScreen(P3D);
  initEnvironment();
  initPaths();
  initPopulation();
  
  // Initialize the Camera
  cam = new Camera(b, -150, 200, 0.7, 0.1, 2.0, 0.4);
}

void draw() {
  background(20);
  
  // Draw 3D Graphics
  cam.orient();
  
  //  Displays the Graph in grayscale.
  //
  tint(255, 75); // overlaid as an image
  image(network.img, 0, 0, b.x, b.y);
  tint(255, 255);
  image(pathsImg, 0, 0, b.x, b.y);
  image(parkingImg, 0, 0, b.x, b.y);
  
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
    p.display(#FFFF00, 200);
  }
  
  cam.drawControls();
  
  textAlign(CENTER, CENTER);
  fill(255);
  textAlign(LEFT, TOP);
  String fRate = "";
  if (showFrameRate) fRate = "\nFramerate: " + frameRate;
  text("Press ' g ' to regenerate OD matrix\n" +
       "Press ' f ' to show/hide framerate\n" +
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
    println(p.type);
    if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
      // Custom
    } else {
      
    } 
    parkingImg.stroke(#0000FF, 255);
    parkingImg.strokeWeight(5);
    parkingImg.fill(#0000FF, 150);
      
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
  
  pathsImg = createGraphics(int(b.x), int(b.y));
  pathsImg.beginDraw();
  pathsImg.clear();
  for (Path p: paths) {
    // Draw Shortest Path
    //
    pathsImg.noFill();
    pathsImg.strokeWeight(3);
    pathsImg.stroke(#00CC00); // Green
    PVector n1, n2;
    for (int i=1; i<p.waypoints.size(); i++) {
      n1 = p.waypoints.get(i-1);
      n2 = p.waypoints.get(i);
      pathsImg.line(n1.x, n1.y, n2.x, n2.y);
    }
  }
  for (Path p: paths) {
    // Draw Origin (Red) and Destination (Blue)
    //
    pathsImg.fill(#FF0000, 200); // Red
    pathsImg.ellipse(p.origin.x, p.origin.y, p.diameter, p.diameter);
    //pathsImg.ellipse(p.destination.x, p.destination.y, p.diameter, p.diameter);
    pathsImg.strokeWeight(1);
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