class Slider{
  String name;
  
  boolean selected;
  float value;
  int sLength;
  int textBuffer;
  
  PVector position;
  PVector knobPosition;
  PVector knobWorldPosition;
  int knobRadius;
  
  //graphics
  PShape base;
  PShape knob;
  
  //Constructor
  //Slider(name,value,position)
  //Creates a slider with a starting value of v with a PVector representing the position of the top right corner of the graphic. The slider displays the name of the value it effects and the current value.
  Slider(String n,float v, PVector p){
    name = n;
    
    selected = false;
    value = v;
    position = p;
    
    sLength = width/2;
    knobPosition = new PVector(map(value,0,15,0,sLength),0);
    knobRadius = 7;
    base = createShape(RECT,0,0,sLength,(knobRadius-2)*2);
    base.setFill(150);
    ellipseMode(CORNER);
    knob = createShape(ELLIPSE,0,0,knobRadius*2,knobRadius*2);
    
    textBuffer = 5;
    knobWorldPosition = new PVector(position.x+knobPosition.x+knobRadius,position.y+knobPosition.y+textBuffer+knobRadius);
  }
  
  //Method: Draw()
  //Purpose: Updates the value and displays the slider and data.
  void drawSlider(){
    if(selected){
      knob.setFill(100);
      if(mouseX >= position.x && mouseX <= (position.x+sLength)){
        knobPosition.x = mouseX-position.x;
        knobWorldPosition.x = position.x+knobPosition.x+knobRadius;
        value = map(knobPosition.x,0,sLength,0,15);
      }
    }else{
      knob.setFill(200);
    }
    if(dist(mouseX,mouseY,knobWorldPosition.x,knobWorldPosition.y) <= knobRadius){
      knob.setStroke(color(255,0,0));
    }else{
      knob.setStroke(0);
    }
    pushMatrix();
      translate(position.x,position.y);
      String details = name + " = " + value;
      fill(0);
      text(details,0,0);
      translate(0,textBuffer);
      shape(base);
      translate(knobPosition.x,knobPosition.y);
      shape(knob);
    popMatrix();
  }
  
  //Method: updateSlider()
  //Purpose: Determines if the mouse clicked near the slider, and marks it as selected if it did.
  void updateSlider(){
    selected = (dist(mouseX,mouseY,knobWorldPosition.x,knobWorldPosition.y) <= knobRadius);
  }
}