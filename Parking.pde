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