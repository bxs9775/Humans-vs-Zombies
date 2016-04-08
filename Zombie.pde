//Zombie class
//Implements vehicle
//Persues humans, avoids trees, and stays in bounds.
class Zombie extends Vehicle{
  
  PVector steeringForce;
  
  PShape sprite;
  
  //max speed/force values
  final static int S_VAR_MIN = 1;
  final static int S_VAR_MAX = 3;
  final static int F_VAR_MIN = 1;
  final static int F_VAR_MAX = 5;
  
  //Default constructor
  Zombie(){
    this(random(100,width-100),random(100,height-100),random(S_VAR_MIN,S_VAR_MAX),random(F_VAR_MIN,F_VAR_MAX));
  }
  
  //Set point constructor
  Zombie(float x, float y){
    this(x,y,random(S_VAR_MIN,S_VAR_MAX),random(F_VAR_MIN,F_VAR_MAX));
  }
  
  //Parameterized constructor for a zombie transformed from a human
  Zombie(Human h){
    this(h.position.x,h.position.y,min(h.maxSpeed,random(S_VAR_MIN,S_VAR_MAX)),min(h.maxForce,random(F_VAR_MIN,F_VAR_MAX)));
  }
  
  //parameterized constructor
  Zombie(float x, float y, float ms, float mf) {
      
    //call the super class' constructor and pass in necessary arguments
    super(x,y,10,ms,mf,12*7*ms,15);

    //instantiate steeringForce vector to (0, 0)
    steeringForce = new PVector(0,0);
    fill(0);
    
    sprite = createShape(GROUP);
    rectMode(CENTER);
    PShape body = createShape(RECT,0,0,10,20);
    body.setFill(color(238,238,224));
    sprite.addChild(body);
    ellipseMode(RADIUS);
    PShape head = createShape(ELLIPSE,0,0,5,5);
    head.setFill(color(143,188,143));
    sprite.addChild(head);
  }
  
  //Main Methods
  
   //Method: display()
  //Purpose: Finds the angle this Zombie should be heading toward
  //         Draws this zombie as a triangle pointing toward 0 degreed
  void display() {
      
    //calculate the direction of the current velocity - this is done for you
    float angle = velocity.heading();   

    //draw this vehicle's body PShape using proper translation and rotation
    stroke(0);
    pushMatrix();
    translate(position.x,position.y);
    pushMatrix();
    rotate(angle);
    stroke(120);
    noFill();
    /*if(debugMode){
      ellipse(0,0,safeDistance*2,safeDistance*2); //Depicts the safe distance
    }*/ 
    shape(sprite);
    stroke(255);
    popMatrix();
   if(simMode == mode.DEBUG){
      //For debugging purposeses
      stroke(255,0,0);
      int refScale = 15;
      line(0,0,refScale*forward.x,refScale*forward.y); //forward vector depiction
      stroke(0,255,0);
      line(0,0,refScale*right.x,refScale*right.y); //right vector depiction
      stroke(0,0,255);
    }
    popMatrix();
    stroke(0);
  }
  
  //Calculates steering forces
  void calcSteeringForces(){
    //adds the obstacle avoidence forces
    for(Obstacle o:trees){
      PVector avoid = obstacleAvoidence(o);
      //PVector distenceToObstacle = PVector.sub(position,o.position);
      float adjustedWeight = avoidenceWeight*safeDistance/position.dist(o.position);
      avoid.mult(adjustedWeight);
      steeringForce.add(avoid);
    }
    
    PVector boundry = stayInBounds();
    boundry.mult(boundryWeight);
    steeringForce.add(boundry);
    
    Human target = closestHuman();
    if(target != null){
      PVector futurePosition = PVector.add(target.position,target.velocity.copy().mult(predictionDistance));
     if(simMode == mode.DEBUG){
        pushMatrix();
        translate(futurePosition.x,futurePosition.y);
        ellipseMode(RADIUS);
        stroke(112,112,0);
        ellipse(0,0,5,5);
        popMatrix();
      }
      PVector seek = seek(futurePosition);
      seek.mult(fleeWeight);
      steeringForce.add(seek);
    }else{
      PVector wVector = wander();
      wVector.mult(wanderWeight);
      steeringForce.add(wVector);
    }

    //limit this zombie's steering force to a maximum force
    steeringForce.limit(maxForce);

    //apply this steering force to the vehicle's acceleration
    applyForce(steeringForce);

    //reset the steering force to 0
    steeringForce.mult(0);
  }
  
   //Auxillary methods
  
  //Method: closestHuman()
  //Purpose: Searches through the array of humans for the closest one. Returns null if there are not any humans.
  Human closestHuman(){
    Human closest = null;
    float closestDist = max(width,height);
    float currentDist = -1;
    for(Human h:survivors){
      currentDist = position.dist(h.position);
      if(currentDist < closestDist){
        closest = h;
        closestDist = currentDist;
      }
    }
    return closest;
  }
}