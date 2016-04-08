//Vehicle class
//Specific autonomous agents will inherit from this class 
//Abstract since there is no need for an actual Vehicle object
//Implements the stuff that each auto agent needs: movement, steering force calculations, and display

abstract class Vehicle {

  //--------------------------------
  //Class fields
  //--------------------------------
  //vectors for moving a vehicle
  PVector position, velocity, acceleration;

  //no longer need direction vector - will utilize forward and right
  //these orientation vectors provide a local point of view for the vehicle
  PVector forward,right;

  //floats to describe vehicle movement and size
  float maxSpeed, maxForce;
  float radius;
  float mass;
  
  //avoidence details
  float safeDistance;
  int predictionDistance;
  
  int timeOutOFBounds;

  //--------------------------------
  //Constructor
  //Vehicle(x position, y position, radius, max speed, max force,prediction distance)
  //--------------------------------
  Vehicle(float x, float y, float r, float ms, float mf,int pd) {
    //Assign parameters to class fields
    this(x,y,r,ms,mf,ms*r*5,pd);
  }
  
   //--------------------------------
  //Advanced Constructor
  //Vehicle(x position, y position, radius, max speed, max force, safe distance,prediction distance)
  //Allows for more control over the absticle avoidence behavior.
  //--------------------------------
  Vehicle(float x, float y, float r, float ms, float mf, float sd,int pd){
    position = new PVector(x,y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    
    //Forward and right
    forward = new PVector(0,1);
    right = forward.copy();
    right.rotate(HALF_PI);
    
    //floats
    radius = r;
    mass = r;
    maxSpeed = ms;
    maxForce = mf;
    safeDistance = sd;
    predictionDistance = pd;
    
    timeOutOFBounds = 0;
  }

  //--------------------------------
  //Abstract methods
  //--------------------------------
  //every sub-class Vehicle must use these functions
  abstract void calcSteeringForces();
  abstract void display();

  //--------------------------------
  //Class methods
  //--------------------------------
  
  //Method: update()
  //Purpose: Calculates the overall steering force within calcSteeringForces()
  //         Applies movement "formula" to move the position of this vehicle
  //         Zeroes-out acceleration 
  void update() {
    //calculate steering forces by calling calcSteeringForces()
    calcSteeringForces();
    //add acceleration to velocity, limit the velocity, and add velocity to position
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    
    //calculate forward and right vectors
    forward = velocity.copy();
    forward.normalize();
    right = forward.copy();
    right.rotate(HALF_PI);
    //reset acceleration
    acceleration.mult(0);
  }

  
  //Method: applyForce(force vector)
  //Purpose: Divides the incoming force by the mass of this vehicle
  //         Adds the force to the acceleration vector
  void applyForce(PVector force) {
    acceleration.add(PVector.div(force, mass));
    pushMatrix();
    translate(position.x,position.y);
    
   if(simMode == mode.DEBUG){
      //For debugging purposeses
      stroke(0,0,255);
      int refScale = 2;
      line(0,0,20*refScale*force.x,20*refScale*force.y);
    }
    popMatrix();
    stroke(0);
  }
  
  
  //--------------------------------
  //Steering Methods
  //--------------------------------
  
  //Method: seek(target's position vector)
  //Purpose: Calculates the steering force toward a target's position
  PVector seek(PVector target){
      
    //write the code to seek a target!
    PVector desiredVelocity = PVector.sub(target,position);
   if(simMode == mode.DEBUG){
      pushMatrix();
      translate(position.x,position.y);
      stroke(150);
      PVector refVector = desiredVelocity.copy();
      line(0,0,refVector.x,refVector.y);
      popMatrix();
    }
    desiredVelocity.setMag(maxSpeed);
    PVector steeringForce = PVector.sub(desiredVelocity,velocity);
    //steeringForce.limit(maxForce);
    return steeringForce;
  }
  
   //Method: flee(threat's position vector)
   //Adapted from seek.
  //Purpose: Calculates the steering force away from a target's position
  PVector flee(PVector threat){
      
    //write the code to seek a target!
    PVector desiredVelocity = PVector.sub(threat,position);
   if(simMode == mode.DEBUG){
      pushMatrix();
      translate(position.x,position.y);
      stroke(150);
      PVector refVector = desiredVelocity.copy();
      line(0,0,refVector.x,refVector.y);
      popMatrix();
    }
    desiredVelocity.mult(-1);
    desiredVelocity.setMag(maxSpeed);
    PVector steeringForce = PVector.sub(desiredVelocity,velocity);
    //steeringForce.limit(maxForce);
    return steeringForce;
  }
  
  //Method: obstacleAvoidence(obsticle's class)
  //Purpose: Calculates the steering vector to the mentioned vector.
  PVector obstacleAvoidence(Obstacle obstacle){
    obstacle.sprite.setStroke(0);
    PVector distenceToObstacle = PVector.sub(position,obstacle.position);
    //Checks if the object is further than the safe distance or
    if(distenceToObstacle.magSq()-sq(radius+obstacle.radius) > safeDistance || distenceToObstacle.dot(forward) > 0){
      return new PVector();
    }
    //Checking if an object is in the objects path of travel. I made some changes to try to avoid making an unneccisary PVector
   if(simMode == mode.DEBUG){
       obstacle.sprite.setStroke(color(255,0,0));
    }
    float projScaler = distenceToObstacle.dot(right); //since right is normalized this would be the scaler used to project refVector onto the right vector.
    if((radius+obstacle.radius) < abs(projScaler)){ //since right is normal, the magnitute of the right vector times a scaler is the scaler.
      return new PVector();
    }
   if(simMode == mode.DEBUG){
      pushMatrix();
      translate(position.x,position.y);
      stroke(150);
      PVector refVector = distenceToObstacle.copy();
      refVector.mult(-1);
      line(0,0,refVector.x,refVector.y);
      popMatrix();
    }
     PVector steering = right.copy().mult(maxSpeed).mult(mass);
    if(distenceToObstacle.dot(right) < 0){
      steering.mult(-1);
    }
    return steering;
  }
  
  //Method: staying in bounds (no parameters)
  //Purpose: turns inwards when near a boundry.
  PVector stayInBounds(){
    PVector sibVector = new PVector();
    boolean outOfBounds = false;
    
    if(position.x <= 100){
      sibVector.add(1,0);
      outOfBounds = true;
    } else if(position.x > width-100){
      sibVector.add(-1,0);
      outOfBounds = true;
    }
    
    if(position.y <= 100){
      sibVector.add(0,1);
      outOfBounds = true;
    } else if(position.y > height-100){
      sibVector.add(0,-1);
      outOfBounds = true;
    }
    //Fix for boundry hiding problem.
    if(outOfBounds){
      timeOutOFBounds++;
    }else{
      timeOutOFBounds=0;
    }
    if(timeOutOFBounds/100 > 0){
      sibVector.mult(timeOutOFBounds/100);
    }
    return sibVector;
  }
  
  //Method: wander (no parameters)
  //Purpose: chooses a spot in a three unit radius of the objects next position and seeks it
  PVector wander(){
    PVector nextPosition = PVector.add(position,forward.copy().mult(12));
    int wRadius = 9;
   if(simMode == mode.DEBUG){
      pushMatrix();
      translate(nextPosition.x,nextPosition.y);
      ellipseMode(RADIUS);
      stroke(112,112,0);
      ellipse(0,0,wRadius,wRadius);
      popMatrix();
    }
    PVector wanderTarget = PVector.add(nextPosition,PVector.random2D().mult(wRadius));
    return seek(wanderTarget);
  }
}