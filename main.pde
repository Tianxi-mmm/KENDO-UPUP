import gab.opencv.*;
import processing.video.*;
import ddf.minim.*;


Minim minim;
AudioInput in;

Capture video;
OpenCV opencv;
Contour contour;
////////////////////////////////////////////
////////////////////////////////// VARIABLES
//////////////////////////

dragonfly df;

float targetSoundLevel = 0.05; 
int count = 0;
int n = 0;
int FPS = 15;
float sound;
int lifespan = 5;
PImage canny;


int centerdfx = 640;
int centerdfy1 = 90;
int centerdfy2 = 630;
int d=72;

/////////////////////////////////////////////
////////////////////////////////// VOID SETUP
/////////////////////////////////////////////

void setup() {
  size(1280, 720);
  textSize(25);

  minim=new Minim(this);
  in=minim.getLineIn();
  
  opencv = new OpenCV(this, 640,360);
  
  //video = new Capture(this, Capture.list()[10]);
  
  video = new Capture(this, 640,360);
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  background(0);
  df = new dragonfly();
  
  strokeWeight(1);
  printArray(Capture.list());
}


////////////////////////////////////////////
////////////////////////////////// VOID DRAW
////////////////////////////////////////////

void draw() { 
  //when the score reaches 50, the current task finishes.
  if (count > 50){
    video.stop();
    noLoop();
    drawTextCrazy();
  }
  
  //update background each time
  background(0);
  float soundLevel=in.mix.level();
  
  if (video.available() == true){
    video.read();
  }
  
  //the position to place the capture view from the camera
  image(video, 320, 180);
  
  video.start();
  
  //edge detection
  opencv.loadImage(video); 
  
  opencv.updateBackground();
  opencv.dilate();
  opencv.erode();

  opencv.findCannyEdges(75,125);
  canny = opencv.getSnapshot();
  image(canny, 320,180); 
  
  canny.loadPixels();
  int totalPixels = canny.width * canny.height;
  
  //read the sound value and map the value to a certain range
  sound = map(soundLevel,0,1,10,200);
  
  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////
  // draw dragonflyies and the shapes changes according to the sound
  df.display(centerdfx,centerdfy1,sound);
  
  // when the sound reaches target level
    if(soundLevel > targetSoundLevel){

      for (int i = 0; i < totalPixels; i++){
        //since the edge is white, so we can recognise by colour
        if (canny.pixels[i] == color(255,255,255) ){
          
          int x = i % canny.width;
          int y = i / canny.width;
          
          if(x<width/4 && y<height/4){
            
            pushMatrix();
            translate(320,180);
            //red contour
            stroke(255,0,0);
            ellipse(x-sound,y-sound,1.5,1.5);
            
            //coloured cotour
            stroke(random(255),random(255),random(255));
            ellipse(x-sound*2,y-sound*2,1.5,1.5);
  
            popMatrix();
            }
            
            
            if (x>width/4 && y<height/4){
              pushMatrix();
              translate(320,180);
              stroke(255,0,0);
              ellipse(x+sound*2,y-sound*2,1.5,1.5);
              
              stroke(random(255),random(255),random(255));
              ellipse(x+sound*4,y-sound*4,1.5,1.5);
              popMatrix();

            }
            
            if (x>width/4 && y>height/4){
              pushMatrix();
              translate(320,180);
              stroke(255,0,0);
              ellipse(x+sound*2,y+sound*2,1.5,1.5);
              stroke(random(255),random(255),random(255));
              ellipse(x+sound*4,y+sound*4,1.5,1.5);
              popMatrix();

            }
            
            if (x<width/4 && y>height/4){
              pushMatrix();
              translate(320,180);            
              stroke(255,0,0);
              ellipse(x-sound*2,y+sound*2,1.5,1.5);
              stroke(random(255),random(255),random(255));
              ellipse(x-sound*4,y+sound*4,1.5,1.5);
              popMatrix();

            }
        }        
    }  
    //add one score
    count++; 
    println("Well Done!" + '\n' + "You have reached the target " + count + " times!!!" );
    text("Well Done!",640,630);
    } 
    
    text("Score " + count,640,650);
    updatePixels();


}


void drawTextCrazy(){
    text("WELL DONE !!", (int)random(0,1200), (int)random(0,700));
}

//control when to stop by using mouse click
void mousePressed() {
    video.stop();
    
    text("Well Done! " + "You got " + count + " points !!",500,350);
    noLoop();
    for (int i = 0; i < 50; i++){
      drawTextCrazy();
    }    
    
}

void keyPressed(){
  println("keypress");
  if (key == 'q'){exit();}
}

class dragonfly{
  dragonfly(){
  }
  // draw one dragonfly
  void drawdf(int x, int y, float s){
    float tr = s/8;
    pushMatrix();
    noStroke();
    fill(255,0,0);
    quad(x,y,x-4*tr,y-4*tr,x,y-8*tr,x+4*tr,y-4*tr);
    triangle(x-4*tr,y+4*tr,x+4*tr,y+4*tr,x,y+40*tr); 
    quad(x-28*tr,y-8,x-8,y-4,x-24*tr,y,x-36*tr,y-4);
    quad(x+28*tr,y-8,x+8,y-4,x+24*tr,y,x+36*tr,y-4);
    quad(x-20*tr,y+4,x-8,y+8,x-16*tr,y+12,x-36*tr,y+8);
    quad(x+20*tr,y+4,x+8,y+8,x+16*tr,y+12,x+36*tr,y+8);
    popMatrix();
  }

  //display all the dragonflies needed
  void display(int x, int y, float sound){
    
    x = centerdfx;
    y = centerdfy1;
    
    drawdf(x,y,sound);
    drawdf(x+2*d,y,sound);
    drawdf(x+4*d,y,sound);
    drawdf(x-2*d,y,sound);
    drawdf(x-4*d,y,sound);
  }
}  
