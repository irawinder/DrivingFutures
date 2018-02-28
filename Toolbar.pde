int s_vOffset = 180;
  
class Toolbar {
  int barWidth;
  int GAP; // pixel distance from edge of screen
  int u_width; // pixel width of margin content
  int V_OFFSET = 70; // standard vertical pixel distance between control elements
  int U_OFFSET = 25; // standard horizontal pixel distance from edge of canvas
  
  String title, credit, explanation;
  
  ControlSlider s1;
  ControlSlider s2;
  ControlSlider s3;
  ControlSlider s4;
  ControlSlider s5;
  ControlSlider s6;
  
  RadioButton b1;
  RadioButton b2;
  RadioButton b3;
  RadioButton b4;
  RadioButton b5;
  RadioButton b6;
  RadioButton b7;
  RadioButton b8;
  
  TriangleMap t1;
  
  Toolbar(int w, int g) {
    barWidth = w;
    GAP = g;
    u_width = barWidth - 3*U_OFFSET;
    initControls();
  }
  
  void initControls() {
    s1 = new ControlSlider();
    s1.name = "Year of Analysis";
    s1.unit = "";
    s1.keyPlus = 'w';
    s1.keyMinus = 'q';
    s1.xpos = GAP + U_OFFSET;
    s1.ypos = s_vOffset + int(0.5*V_OFFSET);
    s1.len = u_width;
    s1.valMin = 2010;
    s1.valMax = 2030;
    s1.value = 2018;
    
    s2 = new ControlSlider();
    s2.name = "Annual Vehicle Trip Growth";
    s2.unit = "%";
    //s2.keyPlus = 'q';
    //s2.keyMinus = 'w';
    s2.xpos = GAP + U_OFFSET;
    s2.ypos = s_vOffset + int(1.0*V_OFFSET);
    s2.len = u_width;
    s2.valMin = -2;
    s2.valMax = 5;
    s2.value = 3;
    
    s3 = new ControlSlider();
    s3.name = "RideShare: System Equilibrium";
    s3.unit = "%";
    //s3.keyPlus = 'q';
    //s3.keyMinus = 'w';
    s3.xpos = GAP + U_OFFSET;
    s3.ypos = s_vOffset + int(1.75*V_OFFSET);
    s3.len = u_width;
    s3.valMin = 0;
    s3.valMax = 100;
    s3.value = 50;
    
    s4 = new ControlSlider();
    s4.name = "RideShare: Peak Hype";
    s4.unit = "";
    //s4.keyPlus = 'q';
    //s4.keyMinus = 'w';
    s4.xpos = GAP + U_OFFSET;
    s4.ypos = s_vOffset + int(2.25*V_OFFSET);
    s4.len = u_width;
    s4.valMin = 2010;
    s4.valMax = 2030;
    s4.value = 2017;
    
    s5 = new ControlSlider();
    s5.name = "AV: System Equilibrium";
    s5.unit = "%";
    //s5.keyPlus = 'q';
    //s5.keyMinus = 'w';
    s5.xpos = GAP + U_OFFSET;
    s5.ypos = s_vOffset + int(3.0*V_OFFSET);
    s5.len = u_width;
    s5.valMin = 0;
    s5.valMax = 100;
    s5.value = 90;
    
    s6 = new ControlSlider();
    s6.name = "AV: Peak Hype";
    s6.unit = "";
    //s6.keyPlus = 'q';
    //s6.keyMinus = 'w';
    s6.xpos = GAP + U_OFFSET;
    s6.ypos = s_vOffset + int(3.5*V_OFFSET);
    s6.len = u_width;
    s6.valMin = 2010;
    s6.valMax = 2030;
    s6.value = 2024;
    
    b1 = new RadioButton();
    b1.name = "Below\nGround";
    b1.col = belowColor;
    b1.keyToggle = '1';
    b1.xpos = GAP + U_OFFSET;
    b1.ypos = s_vOffset + int(6.5*V_OFFSET);
    b1.value = true;
    
    b2 = new RadioButton();
    b2.name = "Surface";
    b2.col = surfaceColor;
    b2.keyToggle = '2';
    b2.xpos = GAP + U_OFFSET;
    b2.ypos = s_vOffset + int(7.0*V_OFFSET);
    b2.value = true;
    
    b3 = new RadioButton();
    b3.name = "Above\nGround";
    b3.col = aboveColor;
    b3.keyToggle = '3';
    b3.xpos = GAP + U_OFFSET;
    b3.ypos = s_vOffset + int(7.5*V_OFFSET);
    b3.value = true;
    
    b8 = new RadioButton();
    b8.name = "Reserved";
    b8.col = reservedColor;
    b8.keyToggle = '8';
    b8.xpos = GAP + U_OFFSET;
    b8.ypos = s_vOffset + int(8.0*V_OFFSET);
    b8.value = true;
    
    b4 = new RadioButton();
    b4.name = "Private";
    b4.col = car1Color;
    b4.keyToggle = '4';
    b4.xpos = GAP + barWidth/2;
    b4.ypos = s_vOffset + int(6.5*V_OFFSET);
    b4.value = true;
    
    b5 = new RadioButton();
    b5.name = "Shared";
    b5.col = car2Color;
    b5.keyToggle = '5';
    b5.xpos = GAP + barWidth/2;
    b5.ypos = s_vOffset + int(7.0*V_OFFSET);
    b5.value = true;
    
    b6 = new RadioButton();
    b6.name = "Private\nAutonomous";
    b6.col = car3Color;
    b6.keyToggle = '6';
    b6.xpos = GAP + barWidth/2;
    b6.ypos = s_vOffset + int(7.5*V_OFFSET);
    b6.value = true;
    
    b7 = new RadioButton();
    b7.name = "Shared\nAutonomous";
    b7.col = car4Color;
    b7.keyToggle = '7';
    b7.xpos = GAP + barWidth/2;
    b7.ypos = s_vOffset + int(8.0*V_OFFSET);
    b7.value = true;
    
    t1 = new TriangleMap();
    t1.name = "Parking\nVacancy\nPriority";
    t1.name1 = "BEL";
    t1.col1 = belowColor;
    t1.name2 = "SRF";
    t1.col2 = surfaceColor;
    t1.name3 = "ABV";
    t1.col3 = aboveColor;
    t1.xpos = GAP + U_OFFSET;
    t1.ypos = s_vOffset + int(4.0*V_OFFSET);
    t1.corner1.x = GAP + 0.50*barWidth;
    t1.corner1.y = s_vOffset + int(4.25*V_OFFSET);
    t1.corner2.x = GAP + 0.33*barWidth;
    t1.corner2.y = s_vOffset + int(5.25*V_OFFSET);
    t1.corner3.x = GAP + 0.67*barWidth;
    t1.corner3.y = s_vOffset + int(5.25*V_OFFSET);
    t1.avgX = (t1.corner1.x+t1.corner2.x+t1.corner3.x)/3.0;
    t1.avgY = (t1.corner1.y+t1.corner2.y+t1.corner3.y)/3.0;
    t1.avg = new PVector(t1.avgX, t1.avgY);
    t1.r = t1.avg.dist(t1.corner1);
    float avgX = (t1.corner1.x+t1.corner2.x+t1.corner3.x)/3.0;
    float avgY = (t1.corner1.y+t1.corner2.y+t1.corner3.y)/3.0;
    t1.pt = new PVector(avgX, avgY);
  }
  
  // Activated when mouse is pressed
  void pressed() {
    s1.listen();
    s2.listen();
    s3.listen(); 
    s4.listen(); 
    s5.listen();
    s6.listen(); 
    
    b1.listen(); 
    b2.listen(); 
    b3.listen(); 
    b4.listen(); 
    b5.listen(); 
    b6.listen();
    b7.listen();
    b8.listen();
    
    t1.listen();
  }
  
  // Activated when mouse is released
  void released() {
    s1.isDragged = false;
    s2.isDragged = false;
    s3.isDragged = false;
    s4.isDragged = false;
    s5.isDragged = false;
    s6.isDragged = false;
    t1.isDragged = false;
  }
  
  void restoreDefault() {
    s1.value = 2018;
    s2.value = 3;
    s3.value = 50;
    s4.value = 2017;
    s5.value = 90;
    s6.value = 2024;
    
    b1.value = true;
    b2.value = true;
    b3.value = true;
    b4.value = true;
    b5.value = true;
    b6.value = true;
    b7.value = true;
    b8.value = true;
    
    float avgX = (t1.corner1.x+t1.corner2.x+t1.corner3.x)/3.0;
    float avgY = (t1.corner1.y+t1.corner2.y+t1.corner3.y)/3.0;
    t1.pt = new PVector(avgX, avgY);
    t1.update();
  }
  
  // Draw Margin Elements
  //
  void draw() {
    camera();
    noLights();
    perspective();
    hint(DISABLE_DEPTH_TEST);
    
    pushMatrix();
    translate(GAP, GAP);
    
    // Shadow of Canvas
    //
    pushMatrix();
    translate(3, 3);
    noStroke();
    fill(0, 220);
    if (height > 800) {
      rect(0, 0, barWidth, 800 - GAP, GAP);
    } else {
      rect(0, 0, barWidth, height - 2*GAP, GAP);
    }
    popMatrix();
    
    // Canvas
    //
    fill(255, 20);
    noStroke();
    if (height > 800) {
      rect(0, 0, barWidth, 800 - GAP, GAP);
    } else {
      rect(0, 0, barWidth, height - 2*GAP, GAP);
    }
    
    // Title and Info
    //
    translate(U_OFFSET, U_OFFSET);
    textAlign(LEFT, TOP);
    fill(255);
    text(title + "\n" + credit + "\n\n" + explanation, 0, 0, barWidth - 2*U_OFFSET, height - 2*GAP - 2*U_OFFSET);
    text("Parking:" , 0                       , 540);
    text("Vehicles:", barWidth/2 - b1.diameter, 540);
    
    popMatrix();
    
    s1.update();
    s1.drawMe();
    
    s2.update();
    s2.drawMe();
    
    s3.update();
    s3.drawMe();
    
    s4.update();
    s4.drawMe();
    
    s5.update();
    s5.drawMe();
    
    s6.update();
    s6.drawMe();
    
    b1.drawMe();
    b2.drawMe();
    b3.drawMe();
    b4.drawMe();
    b5.drawMe();
    b6.drawMe();
    b7.drawMe();
    b8.drawMe();
    
    t1.update();
    t1.drawMe();
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  // Returns true of margin is currently being hoverd over
  boolean hover() {
    if (mouseX > GAP && mouseX < GAP + barWidth && 
        mouseY > GAP && mouseY < height - GAP) {
      return true;
    } else {
      return false;
    }
  }
}

class ControlSlider {
  String name;
  String unit;
  int xpos;
  int ypos;
  int len;
  int diameter;
  char keyMinus;
  char keyPlus;
  boolean isDragged;
  int valMin;
  int valMax;
  float value;
  
  ControlSlider() {
    xpos = 0;
    ypos = 0;
    len = 200;
    diameter = 10;
    keyMinus = '-';
    keyPlus = '+';
    isDragged = false;
    valMin = 0;
    valMax = 0;
    value = 0;
  }
  
  void update() {
    //Keyboard Controls
    if ((keyPressed == true) && (key == keyMinus)) {value--;}
    if ((keyPressed == true) && (key == keyPlus)) {value++;}
    
    if (isDragged) {
      value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    }
  
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  void listen() {
    if((mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > (xpos-diameter/2)) && (mouseX < (xpos+len+diameter/2))) {
      isDragged = true;
    }
  }
  
  void drawMe() {
    
    // Slider Info
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, BOTTOM);
    text(name,xpos,ypos-0.75*diameter);
    textAlign(LEFT, CENTER);
    text(int(value) + " " + unit,xpos+6+len,ypos-1);
    
    // Slider Bar
    fill(100);
    noStroke();
    rect(xpos,ypos-0.3*diameter,len,0.6*diameter,diameter);
    
    // Slider Circle
    noStroke();
    fill(200);
    ellipse(xpos+0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),ypos,diameter,diameter);
  }
}

class RadioButton {
  String name;
  int col;
  int xpos;
  int ypos;
  int diameter;
  char keyToggle;
  int valMin;
  int valMax;
  boolean value;
  
  RadioButton() {
    xpos = 0;
    ypos = 0;
    diameter = 25;
    keyToggle = ' ';
    value = false;
    col = #FFFFFF;
  }
  
  void listen() {
    
    // Mouse Controls
    if((mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > xpos) && (mouseX < xpos+diameter)) {
      value = !value;
    }
    
    // Keyboard Controls
    if ((keyPressed == true) && (key == keyToggle)) {value = !value;}
  }
  
  void drawMe() {
    
    // Button Info
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, CENTER);
    text(name,xpos + 1.5*diameter,ypos);
    
    // Button Holder
    noFill();
    stroke(100);
    strokeWeight(3);
    ellipse(xpos+0.5*diameter,ypos,diameter,diameter);
    
    // Button Circle
    noStroke();
    if (value) { fill(col); } 
    else       { fill( 0 ); } 
    ellipse(xpos+0.5*diameter,ypos,0.7*diameter,0.7*diameter);
  }
}

// Class that maps a point within a triangle to 3 values that add to 1.0
//
class TriangleMap {
  float value1, value2, value3;
  String name, name1, name2, name3;
  int col1, col2, col3;
  int xpos, ypos;
  PVector pt, corner1, corner2, corner3;
  int diameter;
  boolean isDragged;
  float avgX, avgY, r;
  PVector avg;
  
  TriangleMap() {
    diameter = 10;
    corner1 = new PVector(0, 0);
    corner2 = new PVector(0, 0);
    corner3 = new PVector(0, 0);
    pt      = new PVector(0, 0);
    xpos = 0;
    ypos = 0;
    isDragged = false;
    // Default
    value1 = 0.1;
    value2 = 0.2;
    value3 = 0.7;
  }
  
  void listen() {
    PVector mouse = new PVector(mouseX, mouseY);
    if (mouse.dist(avg) < r) isDragged = true;
  }
  
  void update() {
    
    // Update Mouse Condition
    if(isDragged || keyPressed) {
      PVector mouse = new PVector(mouseX, mouseY);
      if(mouse.dist(avg) > r && isDragged) {
        PVector ray = new PVector(mouse.x - avg.x, mouse.y - avg.y);
        ray.setMag(r);
        mouse = new PVector(avg.x, avg.y);
        mouse.add(ray);
      }
      if (isDragged) {
        pt.x = mouse.x;
        pt.y = mouse.y;
      }
      
      // Update Values
      float dist1 = 1 / pow(pt.dist(corner1) + 0.001, 4);
      float dist2 = 1 / pow(pt.dist(corner2) + 0.001, 4);
      float dist3 = 1 / pow(pt.dist(corner3) + 0.001, 4);
      float sum = dist1 + dist2 + dist3;
      dist1 /= sum;
      dist2 /= sum;
      dist3 /= sum;
      value1 = dist1;
      value2 = dist2;
      value3 = dist3;
      
      if (value1 > 0.8) {
        value1 = 0.98;
        value2 = 0.01;
        value3 = 0.01;
      }
      
      if (value2 > 0.8) {
        value1 = 0.01;
        value2 = 0.98;
        value3 = 0.01;
      }
      
      if (value3 > 0.8) {
        value1 = 0.01;
        value2 = 0.01;
        value3 = 0.98;
      }
    }
  }
  
  void drawMe() {
    // Draw Background Circle + Triangle
    //
    noStroke();
    fill(75);
    ellipse(avg.x, avg.y, 2*r, 2*r);
    fill(100);
    beginShape();
    vertex(corner1.x, corner1.y);
    vertex(corner2.x, corner2.y);
    vertex(corner3.x, corner3.y);
    endShape(CLOSE);
    
    // Draw Cursor
    //
    fill(255);
    ellipse(pt.x, pt.y, diameter, diameter);
    
    // Draw Element Meta Information
    //
    textAlign(LEFT, TOP);
    text(name, xpos, ypos);
    textAlign(CENTER, BOTTOM);
    fill(col1);
    text(name1, corner1.x, corner1.y-2);
    textAlign(RIGHT, TOP);
    fill(col2);
    text(name2 + " ", corner2.x, corner2.y);
    textAlign(LEFT, TOP);
    fill(col3);
    text(" " + name3, corner3.x, corner3.y);
    fill(255, 100); // Repeat Text to "Lighten Up"
    text(" " + name3, corner3.x, corner3.y);
    
  }
}