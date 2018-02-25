class Parking {
  PVector location;
  String type;
  int capacity;
  float area;
  
  Parking(float x, float y, float area, String type, int capacity) {
    this.location = new PVector(x, y);
    this.type = type;
    this.capacity = capacity;
    this.area = area;
  }
}

class ParkingStructures {
  ArrayList<Parking> parking;
  PGraphics img;
  
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
      parking.add(park);
    }
    println("Parking Structures Loaded: " + parking.size());
    
    img = createGraphics(w, h);
    img.beginDraw();
    img.clear();
    for (Parking p: parking) {
      if (p.type.length() >= 3 && p.type.substring(0,3).equals("Bel")) {
        img.fill(#FF0000, 150);
        img.stroke(#FF0000, 255);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sur")) {
        img.fill(#FFFF00, 150);
        img.stroke(#FFFF00, 255);
      } else if (p.type.length() >= 3 && p.type.substring(0,3).equals("Sta")) {
        img.fill(#00FF00, 150);
        img.stroke(#00FF00, 255);
        pushMatrix();
        translate(p.location.x, p.location.y);
        fill(#00FF00, 150);
        box(0.1*sqrt(p.area), 0.1*sqrt(p.area), 0.05*sqrt(p.area));
        popMatrix();
      } else {
        img.fill(255, 150);
        img.stroke(255, 255);
      }
      img.strokeWeight(5);
      img.ellipse(p.location.x, p.location.y, 0.1*sqrt(p.area), 0.1*sqrt(p.area));
      img.fill(255);
      img.textAlign(CENTER, CENTER);
      img.text(p.capacity, p.location.x, p.location.y);
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