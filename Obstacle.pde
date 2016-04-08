class Obstacle extends Vehicle{
  PShape sprite;
  
  //creates a new obstacle with a position and radius.
  Obstacle(float x, float y, float r){
    super(x,y,r,0,0,0);
    sprite = createShape(ELLIPSE,0,0,2*radius,2*radius);
    sprite.setFill(color(0,127,0));
  }
  
  //draws the Obsticle
  void display(){
    pushMatrix();
    translate(position.x,position.y);
    shape(sprite);
    popMatrix();
  }
  
  //Required by parent class
  void calcSteeringForces(){
  }
}