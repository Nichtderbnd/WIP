    /* osc send-recieve,processing sketch */
    
    import oscP5.*;
    import netP5.*;
      
OscP5 oscP5;
NetAddress myRemoteLocation;
String remoteIP = "141.83.181.60";
boolean walking = false;
float   accelerometerZ,
        direction,
        rad,
        degree,
        stepsX = 0, 
        stepsY = 0;
int     distVert,
        distDiag,
        scale = 6,
        width1=600,
        height1=800,
        task = 0;
int[][] taskPos = {{-3250, -4000, -1200, -1800},
                    {-2900, -3600, -2500, -3000},
                    {100, 100, 100, 100}};
PImage  img;
    
int     btn1X = 330, 
        btn1Y = 0,
        btn2X = 435,
        btn3X = 540;
int     btn1Width = 100, 
        btn1Height = 30;
color   btn1Color = color (255),
        btn1Highlight = color (200),
        bckColor = color(0);
boolean btn1Over = false,
        btn2Over = false,
        btn3Over = false,
        imageIsLoaded = false;
    
    void setup() {
      accelerometerZ = 9;
      
      size(displayWidth, displayHeight, P3D);
      frameRate(60);
      textAlign(LEFT, TOP);
      textSize(18);
      fill(50);
          
      /* start oscP5, listening for incoming messages on port 12000 */
      oscP5 = new OscP5(this,12000);
      
      /* send to phone address, not needed yet */
      myRemoteLocation = new NetAddress(remoteIP,12001); 
    }

    void draw() {
      
      update (mouseX, mouseY);
      background(bckColor);
      fill(255);
      rect(btn1X, btn1Y, btn1Width, btn1Height);
      fill(255);
      rect(btn2X, btn1Y, btn1Width, btn1Height);
      rect(btn3X, btn1Y, btn1Width, btn1Height);
      textSize(12);
      fill(0);
      text("Europa-Karte", btn1X+5, btn1Y+7);
      text("Welt-Karte", btn2X+5, btn1Y+7);
      text("Fall-Weiß", btn3X+5, btn1Y+7);
      fill(0);
      
   //   background(78, 93, 75);
      
      if(imageIsLoaded) {
      /*map position on screen*/
      image(img, stepsX, stepsY, width*scale, height*scale);
      //  image(img, 0, 0, width, height);
      
      stepper();
      checkPos();
      displayText();
    
      /*displays sensor data on screen*/
      text("Accelerometer: " + 
            "z: " + nfp(accelerometerZ, 1, 2) + "\n" +
            "Compass Direction: " +
            nfp(degree, 1, 2) + "°" + "\n" +
            "StepsX: " + nfp(stepsX, 1, 2) + "\n" +
            "StepsY: " + nfp(stepsY, 1, 2), 0, 0, width, height);       
      }
    }
    
    void checkPos(){
      if(walking && stepsX <= taskPos[task][0] && stepsX > taskPos[task][1] 
          && stepsY <= taskPos[task][2] && stepsY > taskPos[task][3]){
            OscMessage myMessage = new OscMessage("/nextTask");
            myMessage.add("sendingPosition");
            oscP5.send(myMessage, myRemoteLocation);
            this.task++;
          }
    }
    
    void stepper(){ 
      
      /* radiant (Bogenmass) calculation */
      rad = 2*PI + direction;
      /*translate radiant to degree */
      degree = (360/(2*PI))*rad;
      
      distVert = 10;
      distDiag = 10;
   
       if(stepsX>0) stepsX=0;
        if(stepsY>0) stepsY=0;
        if(stepsX< -width*(scale-1)) stepsX=-width*(scale-1);
        if(stepsY < -height*(scale-1)) stepsY=-height*(scale-1);
        
      /* if accelerometer detects a step, calculate new x- and y-position for the map */
      
     if ((accelerometerZ >= 11.81 || accelerometerZ <= 7.81) && walking){
       stepsX = stepsX+(cos(rad)*10);
       stepsY = stepsY+(sin(rad)*10);
       }
         
    }         
   
    void mousePressed() {
      
       if (btn1Over) {
    img=loadImage("europeMap.gif");
    imageIsLoaded = true;
  }
  
      if (btn2Over) {
    img=loadImage("worldMap.png");
    imageIsLoaded = true;
  }
  
      if (btn3Over) {
    img=loadImage("Poland1939_GermanPlanMap.jpg");
    imageIsLoaded = true;
  }
      
      /* send a message to client on mouse (touch) click */
     // OscMessage myMessage = new OscMessage("/test");
    //  myMessage.add(123);
    //  oscP5.send(myMessage, myRemoteLocation); 
     // println("standard sketch, sending to "+myRemoteLocation);
    }

    /* incoming osc message are forwarded to the oscEvent method. */
    void oscEvent(OscMessage theOscMessage) {
      /* print the address pattern and the typetag of the received OscMessage */
      print("### received an osc message.");
      print(" addrpattern: "+theOscMessage.addrPattern());
      println(" typetag: "+theOscMessage.typetag());
      
      /* listening to incoming sensor input */
      if (theOscMessage.checkAddrPattern("/accelerometerZ")==true) {
        accelerometerZ = theOscMessage.get(0).floatValue();
        return;
      }
      if (theOscMessage.checkAddrPattern("/direction")==true) {
        direction = theOscMessage.get(0).floatValue();
        return; 
      }
      if (theOscMessage.checkAddrPattern("/reset")==true) {
        this.stepsX = -3200; /*-(width*(scale/2));*/
        this.stepsY = -1600; /*-(height*(scale/2));*/
        this.task = 0;
        return;
      }
      if (theOscMessage.checkAddrPattern("/walk")==true) {
        this.walking = !this.walking;
        return;
      }
    }
    
    void update (int x, int y) {
  if(overBtn1(btn1X, btn1Y, btn1Width, btn1Height)) {
  btn1Over = true;
  } else {
    btn1Over = false;
  }
  
    if(overBtn1(btn2X, btn1Y, btn1Width, btn1Height)) {
  btn2Over = true;
  } else {
    btn2Over = false;
  }
  
      if(overBtn1(btn3X, btn1Y, btn1Width, btn1Height)) {
  btn3Over = true;
  } else {
    btn3Over = false;
  }
  
}
 
    boolean overBtn1(int x, int y, int width, int height){
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void displayText(){
      textSize(40);
      fill(0, 102, 153, 51);
      textAlign(CENTER, TOP);
      text("Norden", displayWidth/2, 0);
      fill(0, 102, 153, 51);
      textAlign(CENTER, BOTTOM);
      text("Süden", displayWidth/2, displayHeight-50);
      fill(0, 102, 153, 51);
      textAlign(LEFT);
      text("Westen", 10, displayHeight/2);
      fill(0, 102, 153, 51);
      textAlign(RIGHT);
      text("Osten", displayWidth, displayHeight/2);
  }