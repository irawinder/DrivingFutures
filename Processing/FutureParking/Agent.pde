/*  AGENT CLASS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  A force-based autonomous agent that can navigate along 
 *  a series of waypoints that comprise a path
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

// TODO - Reduce complexity/entanglements of Agent() class

class Agent {
  PVector location;
  PVector velocity;
  PVector smoothVelocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;
  float tolerance = 0;
  ArrayList<PVector> path;
  int pathIndex, pathLength; // Index and Amount of Nodes in a Path
  int pathDirection; // -1 or +1 to specific directionality
  boolean loop, teleport;
  String laneSide;
  String type;
  
  float s_x, s_y; // screen location (for mouse commnads)
  void setScreen() {
    s_x = screenX(location.x, location.y, location.z);
    s_y = screenY(location.x, location.y, location.z);
  }
  void setScreen(float x, float y) { // Ofset screen location by x, y
    s_x = screenX(location.x+x, location.y+y, location.z);
    s_y = screenY(location.x+x, location.y+y, location.z);
  }
  
  Agent(float x, float y, int rad, float maxS, ArrayList<PVector> path, boolean loop, boolean teleport, String laneSide, String type) {
    r = rad;
    tolerance *= r;
    maxspeed = maxS;
    maxforce = 0.2;
    this.path = path;
    this.type = type;
    pathLength = path.size();
    
    // If loop = true, agent will immediately seek to origin if destination is reached
    // If loop = false, agent will retrace its path back and forth along a path
    this.loop = loop;
    
    // If teleport and loop = true; agent will teleport to origin when destination is reached
    // If teleport = false; agent will seek origin without teleporting when destination is reached; may ignore path when returning
    this.teleport = teleport;
    
    // If laneSide = "RIGHT"; cars will be offset to the right
    // If laneSide = "LEFT"; cars will be offset to the left
    this.laneSide = laneSide;
    
    if (loop) {
      pathDirection = +1;
    } else {
      if (random(-1, 1) <= 0 ) {
        pathDirection = -1;
      } else {
        pathDirection = +1;
      }
    }
    
    float jitterX = random(-tolerance, tolerance);
    float jitterY = random(-tolerance, tolerance);
    location = new PVector(x + jitterX, y + jitterY);
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    smoothVelocity = new PVector(0, 0);
    pathIndex = getClosestWaypoint(location);
  }
  
  PVector seek(PVector target){
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    return steer;
  }
  
  PVector separate(ArrayList<PVector> others){
    float desiredseparation = 0.5 * r;
    PVector sum = new PVector();
    int count = 0;
    
    for(PVector loc : others) {
      float d = PVector.dist(loc, location);
      
      if ((d > 0 ) && (d < desiredseparation)){
        
        PVector diff = PVector.sub(loc, location);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0){
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
   return sum;   
  }
  
  // calculates the index of path node closest to the given canvas coordinate 'v'.
  // returns 0 if node not found.
  //
  int getClosestWaypoint(PVector v) {
    int point_index = 0;
    float distance = Float.MAX_VALUE;
    float currentDist;
    PVector p;
    for (int i=0; i<path.size(); i++) {
      p = path.get(i);
      currentDist = sqrt( sq(v.x-p.x) + sq(v.y-p.y) );
      if (currentDist < distance) {
        point_index = i;
        distance = currentDist;
      }
    }
    return point_index;
  }
  
  void update(ArrayList<PVector> others, boolean collisionDetection) {
    
    // Apply Repelling Force
    PVector separateForce;
    if (collisionDetection) {
      separateForce = separate(others);
      separateForce.mult(1);
      acceleration.add(separateForce);
    }
    
    // Apply Seek Force
    PVector waypoint = path.get(pathIndex);
    float jitterX = random(-tolerance, tolerance);
    float jitterY = random(-tolerance, tolerance);
    PVector direction = new PVector(waypoint.x + jitterX, waypoint.y + jitterY);
    PVector seekForce = seek(direction);
    seekForce.mult(1);
    acceleration.add(seekForce);
    
    // Update velocity
    velocity.add(acceleration);
    smoothVelocity.add(velocity);
    
    // Update Location
    location.add(new PVector(velocity.x, velocity.y));
        
    // Limit speed
    velocity.limit(maxspeed);
    
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
    
    // Checks if Agents reached current waypoint
    // If reaches endpoint, reverses direction
    //
    float prox = sqrt( sq(location.x - waypoint.x) + sq(location.y - waypoint.y) );
    if (prox < 3 && path.size() > 1 ) {
      
      // If return to origin
      if (loop) {
        if (pathDirection == 1 && pathIndex == pathLength-1) {
          pathIndex = 0;
          if (teleport) {
            location.x = path.get(0).x;
            location.y = path.get(0).y;
          }
        } else {
          pathIndex += pathDirection;
        }
        
      // If retrace path backward
      } else {
        if (pathDirection == 1 && pathIndex == pathLength-1 || pathDirection == -1 && pathIndex == 0) {
          pathDirection *= -1;
        }
        pathIndex += pathDirection;
      }
    }
  }
  
  void display(color col, int alpha) {
    pushMatrix(); translate(location.x, location.y);
    
    // Adjust vehicle's orientation and lane (right or left)
    float SCALER = 4.0;
    float orientation = velocity.heading(); 
    float x=0; float y=0;
    if(laneSide.equals("RIGHT")) {
      x = 0.6*SCALER*r*cos(orientation+PI/2);
      y = 0.6*SCALER*r*sin(orientation+PI/2);
    } else if(laneSide.equals("LEFT")) {
      x = -0.6*SCALER*r*cos(orientation+PI/2);
      y = -0.6*SCALER*r*sin(orientation+PI/2);
    }
    translate(x, y); rotate(orientation);
    
    fill(col, alpha); noStroke();
    box(2*SCALER*r, SCALER*r, 0.75*SCALER*r);
    popMatrix();
    
    // Find Screen location of vehicle
    setScreen(x, y);
  }
}