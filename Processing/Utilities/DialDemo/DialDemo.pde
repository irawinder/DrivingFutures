float scroll, position, max_pos;
float drag;

void setup() {
  size(500, 500);
  position = 0;
  max_pos = 100;
  scroll = 0;
  drag = 10;
}

void draw() {
  scroll = max(0,  scroll);
  scroll = min(max_pos, scroll);
  position = position + (scroll - position) / drag;
  
  background(0);
  noStroke();
  fill(#FFFF00, 200);
  arc(width/2, width/2, 0.75*width, 0.75*width, PI, PI+PI*position/max_pos, PIE);
  fill(50, 100);
  ellipse(width/2, width/2, width/3, width/3);
  fill(255);
  textAlign(CENTER, CENTER);
  text(position, width/2, width/2 + 20);
} 

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scroll += e;
}
