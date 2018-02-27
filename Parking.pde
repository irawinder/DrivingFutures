// Car Colors
int car1Color = #FFFFFF;
int car2Color = #FF00FF;
int car3Color = #00FFFF;
int car4Color = #FFFF00;
 
// Parking Colors
int overColor = #FF0000;
int belowColor = #9900FF;
int surfaceColor = #CCCCCC;
int aboveColor = #0000FF;

class Parking {
  PVector location;
  String type;
  int capacity, utilization;
  float area, ratio;
  
  Parking(float x, float y, float area, String type, int capacity) {
    this.location = new PVector(x, y);
    this.type = type;
    this.capacity = capacity;
    this.area = area;
    //utilization = int( random(0, capacity) );
    utilization = 0;
    ratio = float(utilization) / capacity;
  }
}

class ParkingStructures {
  ArrayList<Parking> parking;
  PGraphics img;
  
  //int belowColor = #7A51A4;
  //int surfaceColor = #3FB6CB;
  //int aboveColor = #94D05C;
  
  int belowColor = #FF0000;
  int surfaceColor = #FFFF00;
  int aboveColor = #00FF00;
  int minCap = 200;
  
  ParkingStructures(int w, int h, float latMin, float latMax, float lonMin, float lonMax) {
    
    Table parkingCSV = loadTable("data/parking.csv", "header");
    parking = new ArrayList<Parking>();
    Parking park;
    float x, y, canvasX, canvasY, area;
    String type;
    int capacity;
    for (int i=0; i<parkingCSV.getRowCount(); i++) {
      x = parkingCSV.getFloat(i, 0);
      y = parkingCSV.getFloat(i, 1);
      canvasX  = w * (x - lonMin) / abs(lonMax - lonMin);
      canvasY  = h - h * (y - latMin) / abs(latMax - latMin);
      area = parkingCSV.getFloat(i, 7);
      type = parkingCSV.getString(i, "20171127_Parking Typology (use dropdown)");
      capacity = parkingCSV.getInt(i, "20171127_Gensler Revised Parking Spots");
      park = new Parking(canvasX, canvasY, area, type, capacity);
      if (capacity > 0) parking.add(park);
    }
    println("Parking Structures Loaded: " + parking.size());
    
    img = createGraphics(w, h);
    img.beginDraw();
    img.clear();
    for (Parking p: parking) {
      if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
        img.stroke(belowColor, 200);
        img.fill(belowColor, 20);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sur")) {
        img.stroke(surfaceColor, 255);
        img.fill(surfaceColor, 20);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
        img.stroke(aboveColor, 255);
        img.fill(aboveColor, 20);
      } else {
        img.stroke(255, 255);
        img.fill(255, 20);
      }
      img.strokeWeight(5);
      img.ellipse(p.location.x, p.location.y, 2.0*sqrt( max(minCap, p.capacity) ), 2.0*sqrt( max(minCap, p.capacity) ));

    }
    img.endDraw();
    
  }
}

class TravelRoutes {
  ArrayList<Path> paths;
  PGraphics img;
  Pathfinder finder;
  
  TravelRoutes(int w, int h, Graph n, ParkingStructures s) {
    //  FORMAT 1: Path(float x, float y, float l, float w)
    //  FORMAT 2: Path(PVector o, PVector d)
    //
    paths = new ArrayList<Path>();
    Path path, pathReturn;
    PVector origin, destination;
    
    boolean debug = false;
    
    //  An example pathfinder object used to derive the shortest path
    //  setting enableFinder to "false" will bypass the A* algorithm
    //  and return a result akin to "as the bird flies"
    //
    finder = new Pathfinder(n);
    
    if (debug) {
      
      for (int i=0; i<5; i++) {
        //  An example Origin and Desination between which we want to know the shortest path
        //
        int rand1 = int( random(n.nodes.size()));
        int rand2 = int( random(s.parking.size()));
        boolean closedLoop = true;
        origin      = n.nodes.get(rand1).loc;
        destination = s.parking.get(rand2).location;
        path = new Path(origin, destination);
        path.solve(finder);
        
        if (path.waypoints.size() <= 1) { // Prevents erroneous origin point from being added when only return path found
          path.waypoints.clear();
        }
        pathReturn = new Path(destination, origin); 
        pathReturn.solve(finder);
        path.joinPath(pathReturn, closedLoop);
        
        paths.add(path);
      }
      
    } else {
  
      for (Parking p: s.parking) {
        //  An example Origin and Desination between which we want to know the shortest path
        //
        int rand1 = int( random(n.nodes.size()));
        boolean closedLoop = true;
        origin      = n.nodes.get(rand1).loc;
        destination = p.location;
        path = new Path(origin, destination);
        path.solve(finder);
        if (path.waypoints.size() <= 1) { // Prevents erroneous origin point from being added when only return path found
          path.waypoints.clear();
        }
        pathReturn = new Path(destination, origin); 
        pathReturn.solve(finder);
        path.joinPath(pathReturn, closedLoop);
        paths.add(path);
      }
      
    }
    
    img = createGraphics(w, h);
    img.beginDraw();
    img.clear();
    for (Path p: paths) {
      // Draw Shortest Path
      //
      PVector pt;
      img.noFill();
      img.stroke(255, 20);
      img.strokeWeight(10);
      img.strokeCap(ROUND);
      img.beginShape();
      for (int i=0; i<p.waypoints.size(); i++) {
        pt = p.waypoints.get(i);
        img.vertex(pt.x, pt.y);
      }
      img.endShape();
      
    }
    for (Path p: paths) {
      // Draw Origin (Red) and Destination (Blue)
      //
      img.fill(0, 255); // Green
      img.stroke(255, 255);
      img.strokeWeight(4);
      img.ellipse(p.origin.x, p.origin.y, p.diameter, p.diameter);
      //img.ellipse(p.destination.x, p.destination.y, p.diameter, p.diameter);
      
    }
    img.endDraw();
  }
}

// That that contains a system of elements including autonomous vehicles, ride share vehicles, 
// parking information, trip demands, and simulated outputs.
//
class AV_System {
  int tripDemand_0;
  int year_0, year_f, year_now, intervals; // initial and final years
  float demand_growth; // yearly growth for trip demand (exponential growth)
  
  float rideShare_share; // % trips using Ride Share at Equilibrium
  float rideShare_growth; // Pace of Adoption (k-value of logistic eq.)
  int rideShare_peak_hype_year; // Year of peak adoption
  
  float av_share; // % trips using Autonomous Vehicle at Equilibrium
  float av_growth; // Pace of Adoption (k-value of logistic eq.)
  int av_peak_hype_year; // Year of peak adoption
  
  int totOther, totBelow, totSurface, totAbove; // Total Parking Stock at year_0
  float priorityBelow, prioritySurface, priorityAbove; // Relative priority when removing parking utilization (all three must add up to 1!!
  
  /* 4 Car Types:
   *
   *                Human Driver              Autonomous Vehicle
   *
   *  Private       1. [Private, Driver]      3. [Private, AV]
   *
   *   Shared       2. [Shared,  Driver]      4. [Shared,  AV]
   */
  
  // Number of Trips Demanded for array of N years (This is a KEY Independent Variable!)
  int[] tripDemand;
  
  // Number of Vehicles of Each Type for array of N years
  int[] numCar1,  numCar2,  numCar3,  numCar4,  totalCars;
  
  // Number of Local Parking Spaces needed for each Vehicle to array of N years
  int[] numPark1, numPark2, numPark3, numPark4, totalPark;
  
  // Number of Vehicles of Each Type for array of N years
  int[] numTrip1,  numTrip2,  numTrip3,  numTrip4;
  
  // Number of Parking Spaces "Freed Up" by vehicle reduction
  int[] otherFree, belowFree, surfaceFree, aboveFree, totalFree;
   
  // Number of trips served per vehicle of each type
  float TRIPS_PER_CAR1 = 1.0;
  float TRIPS_PER_CAR2 = 4.0;
  float TRIPS_PER_CAR3 = 1.0;
  float TRIPS_PER_CAR4 = 5.0;
   
  // Number of parking Spaces needed per vehicle of each type
  float SPACES_PER_CAR1 = 1.00;
  float SPACES_PER_CAR2 = 0.05;
  float SPACES_PER_CAR3 = 0.75;
  float SPACES_PER_CAR4 = 0.15;
   
  AV_System(int tripDemand_0, int year_0, int year_f) {
    this.tripDemand_0 = tripDemand_0;
    this.year_0 = year_0;
    this.year_f = year_f;
    intervals = 1 + year_f - year_0;
    year_now = year_0;
     
    tripDemand    = new int[intervals];
     
    numCar1       = new int[intervals];
    numCar2       = new int[intervals];
    numCar3       = new int[intervals];
    numCar4       = new int[intervals];
    totalCars     = new int[intervals];
     
    numPark1      = new int[intervals];
    numPark2      = new int[intervals];
    numPark3      = new int[intervals];
    numPark4      = new int[intervals];
    totalPark     = new int[intervals];
     
    numTrip1      = new int[intervals];
    numTrip2      = new int[intervals];
    numTrip3      = new int[intervals];
    numTrip4      = new int[intervals];
     
    otherFree     = new int[intervals];
    belowFree     = new int[intervals];
    surfaceFree   = new int[intervals];
    aboveFree     = new int[intervals];
    totalFree     = new int[intervals];
  }
   
  void update() {
    float av_s, rs_s; // Instantaneous share of AV and RideShare
     
    for (int i=0; i<intervals; i++) {
      av_s = logistic(av_share,        av_growth,        year_0 + i, av_peak_hype_year);
      rs_s = logistic(rideShare_share, rideShare_growth, year_0 + i, rideShare_peak_hype_year);

      tripDemand[i] = int(tripDemand_0 * pow(1 + demand_growth, i));
       
      // Update Vehicle Counts
      numCar1[i] = int( tripDemand[i] * (1 - av_s) * (1 - rs_s) / TRIPS_PER_CAR1 );
      numCar2[i] = int( tripDemand[i] * (0 + av_s) * (1 - rs_s) / TRIPS_PER_CAR2 );
      numCar3[i] = int( tripDemand[i] * (1 - av_s) * (0 + rs_s) / TRIPS_PER_CAR3 );
      numCar4[i] = int( tripDemand[i] * (0 + av_s) * (0 + rs_s) / TRIPS_PER_CAR4 );
       
      // Update Parking Space Demand
      numPark1[i]  = int( numCar1[i] * SPACES_PER_CAR1 );
      numPark2[i]  = int( numCar2[i] * SPACES_PER_CAR2 );
      numPark3[i]  = int( numCar3[i] * SPACES_PER_CAR3 );
      numPark4[i]  = int( numCar4[i] * SPACES_PER_CAR4 );
      totalPark[i] = numPark1[i] + numPark2[i] + numPark3[i] + numPark4[i];
       
      // Update Unutilized Parking Capacity
      totalFree[i]   = int( (1 - float(totalPark[i]) / tripDemand_0) * (totBelow +  totSurface + totAbove) );
      belowFree[i]   = 0;
      surfaceFree[i] = 0;
      aboveFree[i]   = 0;
      if (totalFree[i] < 0) {
        // Negative total capacity is over capacity
        otherFree[i] = totalFree[i];
      } else {
        otherFree[i] = 0;
      }
      
      // Allocation Parking Vacancy Based Upon priority triangle
      float rand;
      int k = totalFree[i];
      while (k > 0) {
        rand = random(0, 1);
         
        // Check Below Parking
        if ( rand < priorityBelow ) {
           
          if (belowFree[i] < totBelow) {
            belowFree[i]++;
            k--;
          } else {
            rand = random(0, prioritySurface + priorityAbove);
            if (rand < prioritySurface) {
              if (surfaceFree[i] < totSurface) {
                surfaceFree[i]++;
                k--;
              } else {
                if (aboveFree[i] < totAbove) {
                  aboveFree[i]++;
                  k--;
                }
              }
            }
          }
         
        // Check Surface Parking
        } else if( rand >= priorityBelow && rand < prioritySurface ) {
           
          if (surfaceFree[i] < totSurface) {
            surfaceFree[i]++;
            k--;
          } else {
            rand = random(0, priorityBelow + priorityAbove);
            if (rand < priorityBelow) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } else {
                if (aboveFree[i] < totAbove) {
                  aboveFree[i]++;
                  k--;
                }
              }
            }
          }
         
        // Check Above Parking 
        } else {
         
          if (aboveFree[i] < totAbove) {
            aboveFree[i]++;
            k--;
          } else {
            rand = random(0, priorityBelow + prioritySurface);
            if (rand < priorityBelow) {
              if (belowFree[i] < totBelow) {
                belowFree[i]++;
                k--;
              } else {
                if (surfaceFree[i] < totSurface) {
                  surfaceFree[i]++;
                  k--;
                }
              }
            }
          }
           
        }
      }
      
      // Update Relative number of Trips 
      numTrip1[i]  = int( numCar1[i] * TRIPS_PER_CAR1 );
      numTrip2[i]  = int( numCar2[i] * TRIPS_PER_CAR2 );
      numTrip3[i]  = int( numCar3[i] * TRIPS_PER_CAR3 );
      numTrip4[i]  = int( numCar4[i] * TRIPS_PER_CAR4 );
    }
  }
  
  // Equation for Logistic (carrying capacity)
  // https://en.wikipedia.org/wiki/Logistic_function
  //
  float logistic(float L, float k, float x, float x_0) {
    return L / (1 + exp( -k*(x - x_0) ));
  }
  
  // Plot a stacked bar char with 4 elements per interval
  void plot4(String title, int[] value1, int[] value2, int[] value3, int[] value4, int color1, int color2, int color3, int color4, int x, int y, int w, int h, float scaler) {
  
    pushMatrix();
    translate(x, y);
    float iWidth = float(w)/intervals;
     
    // Draw current year indicator
    //
    fill(255, 100);
    int j = (year_now - year_0);
    rect(j*iWidth + 0.35*iWidth, 22, 1, h-22, 5);
    
    // Cycle through each interval of the graph
    for (int i=0; i<intervals; i++) {
      float xpos1 = i*iWidth;
      noStroke();
      
      // Value 1
      fill(color1);
      rect( xpos1, h - scaler*value1[i], 0.75*iWidth, scaler*value1[i] );
      // Value 2
      fill(color2);
      rect( xpos1, h - scaler*(value1[i] + value2[i]), 0.75*iWidth, scaler*value2[i] );
      // Value 3
      fill(color3);
      rect( xpos1, h - scaler*(value1[i] + value2[i] + value3[i]), 0.75*iWidth, scaler*value3[i] );
      // Value 4
      fill(color4);
      rect( xpos1, h - scaler*(value1[i] + value2[i] + value3[i] + value4[i]), 0.75*iWidth, scaler*value4[i] );
       
    }
    
    // Draw Current Year Total
    //
    fill(150);
    textAlign(LEFT, TOP);
    text("Tot: " + (value1[j]+value2[j]+value3[j]+value4[j]), j*iWidth + iWidth, 20);
    textAlign(RIGHT, TOP);
    text(year_now, j*iWidth - 0.5*iWidth, 20);
    
    // Draw Graph Title and x_axis
    //
    fill(255);
    textAlign(LEFT, TOP);
    text(title, 0, 0);
    fill(150);
    textAlign(LEFT, BOTTOM);
    text(year_0, 0, h+16);
    textAlign(RIGHT, BOTTOM);
    text(year_f, w, h+16);

    popMatrix();
  }
}