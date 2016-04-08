
//Beginning to code autonomous agents
//Will implement inheritance with a Vehicle class and a Seeker class


//Seeker s;

mode simMode; //for visualization


ArrayList<Obstacle> trees;

//having trouble deciding to put humans and zomibies is a single array which simplifies Update() and Display()
//or seperately which would allow for the reduction in collision detections
ArrayList<Human> survivors;
ArrayList<Zombie> zombies;
Slider[] sliders;
//final int AVOID = 0, FLEE = 1, SEEK = 2, BOUNDRY = 3, WANDER = 4;;//weights for behaviors
float avoidenceWeight,fleeWeight,seekWeight,boundryWeight, wanderWeight;

PVector mousePos;

void setup() {
  size(1200, 800);
 // s = new Seeker(width/2, height/2, 6, 4, 0.1);
  simMode = mode.PLAY;
  
  avoidenceWeight = 5;
  fleeWeight = 1.4;
  seekWeight = 2;
  boundryWeight = 5.1;
  wanderWeight = 1;
  
  sliders = new Slider[5];
  sliders[0] = new Slider("Avoidence",10,new PVector(width/4,height/2-60));
  sliders[1] = new Slider("Flee",1.4,new PVector(width/4,height/2-30));
  sliders[2] = new Slider("Seek",5,new PVector(width/4,height/2));
  sliders[3] = new Slider("Boundry",5.1,new PVector(width/4,height/2+30));
  sliders[4] = new Slider("Wander",1,new PVector(width/4,height/2+60));
  
  trees = new ArrayList<Obstacle>();
  int numtrees = (int)(random(5,36));
  for(int i = 0; i < numtrees; i++){
    trees.add(new Obstacle(random(100,width-100),random(100,height-100),random(9,21)));
  }
  survivors = new ArrayList<Human>();
  int numHumans = (int)(random(10,16));
  for(int i = 0; i < numHumans; i++){
    survivors.add(new Human());
  }
  zombies = new ArrayList<Zombie>();
  for(int i = 0; i < 16-numHumans; i++){
    zombies.add(new Zombie());
  }
  
}

void draw() {
  if(simMode == mode.OPTIONS){
    background(200);
    for(int i = 0; i < sliders.length;i++){
      sliders[i].drawSlider();
    }
  }else{
    runSim();
  }
}

void keyPressed(){
  if(key == '1'){
    if(simMode == mode.DEBUG){
      simMode = mode.PLAY;
    } else{
      simMode = mode.DEBUG;
    }
  }
  if(key == '2'){
    if(simMode == mode.DEBUG){
      simMode = mode.OPTIONS;
    } else if(simMode == mode.OPTIONS){
      simMode = mode.DEBUG;
    }
  }
}

//Processes mouse clicks during debug mode.
//Left clicks create humans, right clicks create zombies
//Center clicks should delete the character the mouse is over, but they move too fast for the click to register.
void mouseClicked(){
  if(simMode == mode.DEBUG){
    if(mouseButton == LEFT){
      survivors.add(new Human(mouseX,mouseY));
    } else if(mouseButton == RIGHT){
      zombies.add(new Zombie(mouseX,mouseY));
    } else if(mouseButton == CENTER){
      mousePos = new PVector(mouseX,mouseY);
      for(int i = 0; i < zombies.size(); i++){
        if(mousePos.dist(zombies.get(i).position) < (zombies.get(i).radius+6)){
          zombies.remove(i);
          return;
        }
      }
      
      for(int i = 0; i < survivors.size(); i++){
        if(mousePos.dist(survivors.get(i).position) < survivors.get(i).radius){
          survivors.remove(i);
          return;
        }
      }
    }
  } else if(simMode == mode.OPTIONS){
    for(int i = 0; i < sliders.length;i++){
      sliders[i].updateSlider();
    }
    avoidenceWeight = sliders[0].value;
    fleeWeight = sliders[1].value;
    seekWeight = sliders[2].value;
    boundryWeight = sliders[3].value;
    wanderWeight = sliders[4].value;
  }
}
  
//Method: runSim
//Purpose: handles updates when not in options mode.
void runSim(){
  background(0,200,0);
  
  fill(0);
  textSize(16);
  String message = "Press 1 to toggle between ie and debug mode.";
  if(simMode == mode.DEBUG){
    message += "\nPress 2 to access the options menu.\nLeft click to create humans.\nRight click to create zombies.\nClick the center mouse button over humans or zombies to delete them.";
    noFill();
    stroke(0);
    rectMode(CORNERS);
    rect(100,100,width-100,height-100);
  }
  text(message,25,25);
  
  // Draw an ellipse at the mouse location
 
  for(Obstacle o:trees){
    o.update();
    o.display();
  }
  
  //update humans and zombies
  Zombie z = null;
  for(int i = 0; i < zombies.size(); i++){
    z = zombies.get(i);
    z.update();
    z.display();
    Human h = null;
    for(int j = 0; j < survivors.size(); j++){
      h = survivors.get(j);
      if(z.position.dist(h.position) < (z.radius+h.radius)){
        zombies.add(new Zombie(h));
        survivors.remove(j);
        j--;
      }
    }
  }
  
  for(Human h:survivors){
    h.update();
    h.display();
  }
}