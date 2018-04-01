import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;

// timing
TimingTask spinningTask;
boolean yDirection;

// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;
boolean raster = true;
boolean aliasing = false;
boolean shading = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  //frameRate(1);
  size(512, 512, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  if(raster) triangleRaster();
  if(aliasing) multisampling();
  popStyle();
  popMatrix();
  
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  stroke(0, 0, 255);

  Vector pv1 = frame.coordinatesOf(v1);
  Vector pv2 = frame.coordinatesOf(v2);
  Vector pv3 = frame.coordinatesOf(v3);
  float determinante =(((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  //println(determinante);
 
  
  for (float i = -(pow(2,n-1));i<(pow(2,n-1));i++){
    for (float j = -(pow(2,n-1));j<(pow(2,n-1)); j++){
      float pointx = i  + 0.5;
      float pointy = j + 0.5;
      //circleCenter(pointx,pointy);
      float Cond1 =  (((pv1.y()) -(pv2.y()))*pointx) + (((pv2.x()) -(pv1.x()))*pointy) + ((pv1.x())*(pv2.y())) - ((pv1.y())*(pv2.x()));
      float Cond2 =  (((pv2.y()) -(pv3.y()))*pointx) + (((pv3.x()) -(pv2.x()))*pointy) + ((pv2.x())*(pv3.y())) - ((pv2.y())*(pv3.x()));
      float Cond3 =  (((pv3.y()) -(pv1.y()))*pointx) + (((pv1.x()) -(pv3.x()))*pointy) + ((pv3.x())*(pv1.y())) - ((pv3.y())*(pv1.x()));
      //println  (v1.y() +" "+Cond2+" " + Cond3 + " "+i+" "+j);
      color c = round(colorFun(pv1, pv2, pv3, pointx , pointy));
      if ((Cond1>=0) && (Cond2>=0) && (Cond3>=0)  && (determinante>0)){
        circleRaster(pointx,pointy,red(c),green(c),blue(c));
      }
      else if ((Cond1<=0) && (Cond2<=0) && (Cond3<=0) && (determinante<0)){
        circleRaster(pointx,pointy,red(c),green(c),blue(c));
      }  
    }
  }
}

void multisampling( ){
  
  int size = (int) pow( 2, n-1);
  Vector pv1 = frame.coordinatesOf(v1);
  Vector pv2 = frame.coordinatesOf(v2);
  Vector pv3 = frame.coordinatesOf(v3);
  color c;
  float determinante = (((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  for ( int x = -size; x <= size; x++ ) {
    for (  int y = -size; y <= size; y++ ) {
      float centerx = x  + 0.5;
      float centery = y + 0.5;
      int contador = 0;
      
      //circleCenter(pointx,pointy);
      for ( float i = 0; i < 2; i++ ) {
        for ( float j = 0; j < 2; j++ ) {
          float pointx = x + i / 2 + 0.25;
          float pointy = y + j / 2 + 0.25;
          float Cond1 =  (((pv1.y()) - (pv2.y()))*pointx) + (((pv2.x()) - (pv1.x()))*pointy) + ((pv1.x())* (pv2.y())) - ((pv1.y())*(pv2.x()));
          float Cond2 =  (((pv2.y()) - (pv3.y()))*pointx) + (((pv3.x()) - (pv2.x()))*pointy) + ((pv2.x())* (pv3.y())) - ((pv2.y())*(pv3.x()));
          float Cond3 =  (((pv3.y()) - (pv1.y()))*pointx) + (((pv1.x()) - (pv3.x()))*pointy) + ((pv3.x())* (pv1.y())) - ((pv3.y())*(pv1.x()));
          c = round(colorFun(pv1, pv2, pv3, pointx , pointy));
          if ((Cond1>=0) && (Cond2>=0) && (Cond3>=0)  && (determinante>0)){
            contador = contador+1;
            circleCenter(centerx,centery,red(c),green(c),blue(c));       
            circleAliasing(pointx,pointy,red(c),green(c),blue(c) );
          }
          else if ((Cond1<0) && (Cond2<0) && (Cond3<0) && (determinante<0)){
            contador = contador+1;
            circleCenter(centerx,centery,red(c),green(c),blue(c));
            circleAliasing( pointx,pointy,red(c),green(c),blue(c));
          }
            
        }   
      }
      //si en un cuadrado algun punto quedo por dentro y algun otro por fuera
      if (contador>0 && contador<4){
       for ( float i = 0; i < 2; i++ ) {
          for ( float j = 0; j < 2; j++ ) {
            float pointx = x + i / 2 + 0.25;
            float pointy = y + j / 2 + 0.25;
            c = round(colorFun(pv1, pv2, pv3, pointx , pointy));
            circleAliasing( pointx,pointy,red(c),green(c),blue(c));
          }
        }      
      }
    }
  }
}

float colorFun(Vector pv1, Vector pv2, Vector pv3, float pointx , float pointy){
  float e1 = eFun(pv1.x(),pv1.y(),pointx,pointy,pv2.x(),pv2.y()) ;
  float e2 = eFun(pv1.x(),pv1.y(),pointx,pointy,pv2.x(),pv2.y()) ;
  float e3 = eFun(pv1.x(),pv1.y(),pointx,pointy,pv3.x(),pv3.y());
  float e4 = eFun(pv1.x(),pv1.y(),pv2.x(),pv2.y(),pv3.x(),pv3.y());
  float u = e1/e4;
  float v = e2/e4;
  float w = e3/e4;
  color c = color(u*255,v*255,w*255);
  //println(red(c));
  return c;
}

float eFun (float x1, float y1,float x2,float y2, float x3, float y3){
    return abs((x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3));
}

void circleCenter( float pointx, float pointy ,float red, float green, float blue) {
  pushStyle();
  if(shading) stroke(red, green, blue,50);
  else stroke(255, 255, 0,50);
  strokeWeight(1);
  point( pointx, pointy);
  popStyle();
}

void circleRaster( float pointx, float pointy, float red, float green, float blue ) {
  pushStyle();
  if(shading) stroke(red, green, blue);
  else stroke(255, 255, 0);
  strokeWeight(1);
  point( pointx, pointy);
  popStyle();
  pushStyle();
  stroke(0, 0, 243);
  strokeWeight(0.15);
  point( pointx, pointy);
  popStyle();
}

void circleAliasing( float pointx, float pointy, float red, float green, float blue ) {
  pushStyle();
  if(shading) stroke(red, green, blue);
  else stroke(0, 0, 200);
  strokeWeight(0.15);
  point( pointx, pointy);
  popStyle();
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  //v1 = new Vector (90,240);
  //v2 = new Vector (200,180);
  //v3 = new Vector (120,60);
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 0, 255);
  point(v1.x(), v1.y());
  stroke(0, 255, 0);
  point(v2.x(), v2.y());
  stroke(255, 0, 0);
  point(v3.x(), v3.y());
  
  
  stroke (255,255,255);
  point(0,0);
  popStyle();
  
  
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
  if(key == 'a')
    aliasing = !aliasing;
  if(key == 's')
    shading = !shading;
  if(key == 'z')
    raster = !raster;
}
