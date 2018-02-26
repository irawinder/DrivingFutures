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