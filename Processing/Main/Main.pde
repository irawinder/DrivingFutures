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

//  GeoLocation Parameters:
float latCtr, lonCtr, bound, latMin, latMax, lonMin, lonMax;

//  Object to Define Systems Model
Parking_System sys;
//  Object to define parking facilities:
Parking_Structures structures;
// Object to define and capture paths to collection of origins, destinations:
Parking_Routes routes;

//  Objects to define agents that navigate our environment:
ArrayList<Agent> type1; // Private non-AV
ArrayList<Agent> type2; // Shared  non-AV
ArrayList<Agent> type3; // Private AV
ArrayList<Agent> type4; // Shared  AV

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B = new PVector(6000, 6000, 0); // Bounding Box for 3D Environment
int MARGIN = 25; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

// Index of Entity one is currently hovering over
int hoverIndex = 0; String hoverType = "";

boolean initialized;

void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  initialized = false;
}

void draw() {
  if (!initialized) {
    
    // A_Init.pde - runs until initialized = true
    //
    initialize();
    
  } else {
    
    // A_Listen.pde and A_Render
    //
    listen();
    render3D();
    render2D();
    
  }
}