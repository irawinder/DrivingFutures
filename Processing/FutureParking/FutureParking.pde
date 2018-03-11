/*  DRIVING FUTURES
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
 *      A_Init            - mostly void functions to initializing application and simulation
 *      A_Draw.pde        - mostly void functions for drawing application to screen
 *      A_Parking.pde     - Primary simulation environment
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

import java.io.File;
import java.io.FileNotFoundException;

//  GeoLocation Parameters:
float latCtr, lonCtr, tol, latMin, latMax, lonMin, lonMax;

// Object to define and capture paths to collection of origins, destinations:
Parking_Routes routes;
File routesJSON;
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
File graphJSON;

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

// Index of Entity one is currently hovering over
int hoverIndex = 0; String hoverType = "";

void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  loadingBG = loadImage("loading.png");
  loadScreen(loadingBG, initPhase, NUM_PHASES, "");
}

void draw() {
  if (!initialized) {
    initialize();
  } else {
    run();
  }
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

// Calculate Parking Ratios for each structure for current year only
//
void setParking() {
  
  // Account for unactive parking first ...
  sys.belowOff   = 0;
  sys.surfaceOff = 0;
  sys.aboveOff   = 0;
  for (Parking p: structures.parking) {
    if (!p.active) {
      if (p.col == belowColor)   sys.belowOff   += p.capacity;
      if (p.col == surfaceColor) sys.surfaceOff += p.capacity;
      if (p.col == aboveColor)   sys.aboveOff   += p.capacity;
      p.utilization = 0;
    }
  }
  sys.belowOff   /= 100;
  sys.surfaceOff /= 100;
  sys.aboveOff   /= 100;
  
  sys.update();
  
  // For active parking, calculate ratio
  //
  int yr = sys.year_now - sys.year_0;
  float belowRatio   = 1 - float(sys.belowFree[yr]    )  / sys.totBelow  ;
  float surfaceRatio = 1 - float(sys.surfaceFree[yr]  )  / sys.totSurface;
  float aboveRatio   = 1 - float(sys.aboveFree[yr]    )  / sys.totAbove  ;
  
  for (Parking p: structures.parking) {
    p.ratio = 0;
    if (p.col == belowColor && p.active) {
      p.ratio = belowRatio;
    } else if (p.col == surfaceColor && p.active) {
      p.ratio = surfaceRatio;
    } else if (p.col == aboveColor && p.active) {
      p.ratio = aboveRatio;
    } else if (p.col == reservedColor && p.active) {
      p.ratio = 1.0;
    }
    p.utilization = int(p.ratio*p.capacity);
  }
}

void keyPressed() {
  if (initialized) {
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
        structures.reset();
        initPopulation();
        additions.clear();
        break;
      //case 'h':
      //  SHOW_INFO = !SHOW_INFO;
      //  break;
      //case 's':
      //  save("capture.png");
      //  break;
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
    
    // Update Inputs and model
    bar_left.pressed();
    bar_right.pressed();
    setSliders();
    setParking();
    updatePopulation();
  }
}

void mousePressed() {
  if (initialized) {
    cam.pressed();
    bar_left.pressed();
    bar_right.pressed();
    sys.update();
    updatePopulation();
  }
}

void mouseMoved() {
  if (initialized) {
    cam.moved();
  }
}

void mouseReleased() {
  if (initialized) {
    bar_left.released();
    bar_right.released();
    sys.update();
    updatePopulation();
  }
}

void mouseDragged() {
  if (initialized) {
    sys.update();
    updatePopulation();
  }
}

void mouseClicked() {
  if (initialized) {
    if (cam.chunkField.closestFound && cam.enableChunks) {
      additions.add(cam.chunkField.closest.location);
    }
    if (hoverType.equals("parking")) {
      structures.parking.get(hoverIndex).active = !structures.parking.get(hoverIndex).active;
      setParking();
    }
    boolean newPath = false;
    if (hoverType.equals("car1")) newPath = true;
    if (hoverType.equals("car2")) newPath = true;
    if (hoverType.equals("car3")) newPath = true;
    if (hoverType.equals("car4")) newPath = true;
    if (newPath) {
      for (Agent p: type1) p.showPath = false;
      for (Agent p: type2) p.showPath = false;
      for (Agent p: type3) p.showPath = false;
      for (Agent p: type4) p.showPath = false;
      if (hoverType.equals("car1")) type1.get(hoverIndex).showPath = !type1.get(hoverIndex).showPath;
      if (hoverType.equals("car2")) type2.get(hoverIndex).showPath = !type2.get(hoverIndex).showPath;
      if (hoverType.equals("car3")) type3.get(hoverIndex).showPath = !type3.get(hoverIndex).showPath;
      if (hoverType.equals("car4")) type4.get(hoverIndex).showPath = !type4.get(hoverIndex).showPath;
    }
  }
}