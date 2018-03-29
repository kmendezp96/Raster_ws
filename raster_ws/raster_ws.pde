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

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

//Triangle coordinates x and y
float v1x = 0.0;
float v2x = 0.0;
float v3x = 0.0;
float v1y = 0.0;
float v2y = 0.0;
float v3y = 0.0;

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
  triangleRaster();
  multisampling();
  //antialiasing();
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
  int determinante = round(((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  //println(determinante);
  
  for (int i = - round(pow(2,n-1));i<round(pow(2,n-1));i++){
    for (int j = - round(pow(2,n-1));j<round(pow(2,n-1)); j++){
      int Cond1 =  ((round(pv1.y()) - round(pv2.y()))*i) + ((round(pv2.x()) - round(pv1.x()))*j) + (round(pv1.x())* round(pv2.y())) - (round(pv1.y())*round(pv2.x()));
      int Cond2 =  ((round(pv2.y()) - round(pv3.y()))*i) + ((round(pv3.x()) - round(pv2.x()))*j) + (round(pv2.x())* round(pv3.y())) - (round(pv2.y())*round(pv3.x()));
      int Cond3 =  ((round(pv3.y()) - round(pv1.y()))*i) + ((round(pv1.x()) - round(pv3.x()))*j) + (round(pv3.x())* round(pv1.y())) - (round(pv3.y())*round(pv1.x()));
      //println  (v1.y() +" "+Cond2+" " + Cond3 + " "+i+" "+j);
      if ((Cond1>0) && (Cond2>0) && (Cond3>0)  && (determinante>0)){
        point(i,j);
      }
      else if ((Cond1<0) && (Cond2<0) && (Cond3<0) && (determinante<0)){
        point(i,j);
      }
      
    }
  
  }
  /*if (debug) {
    pushStyle();
    stroke(255, 255, 0, 125);
    Vector projection = frame.coordinatesOf(v1);
    point(round(projection.x()), round(projection.y()));
    popStyle();
  }*/
}

void multisampling( ){
  
  int size = (int) pow( 2, n ) / 2;
  //Vector pv1 = (v1);
  //Vector pv2 = (v2);
  //Vector pv3 = (v3);
  Vector pv1 = frame.coordinatesOf(v1);
  Vector pv2 = frame.coordinatesOf(v2);
  Vector pv3 = frame.coordinatesOf(v3);
  float determinante = (((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  for ( int x = -size; x <= size; x++ ) {
    for (  int y = -size; y <= size; y++ ) {
      int contador = 0;
      for ( float i = 0; i < 2; i++ ) {
        for ( float j = 0; j < 2; j++ ) {
          float pointx = x + i / 2 + 0.25;
          float pointy = y + j / 2 + 0.25;
          float Cond1 =  (((pv1.y()) - (pv2.y()))*pointx) + (((pv2.x()) - (pv1.x()))*pointy) + ((pv1.x())* (pv2.y())) - ((pv1.y())*(pv2.x()));
          float Cond2 =  (((pv2.y()) - (pv3.y()))*pointx) + (((pv3.x()) - (pv2.x()))*pointy) + ((pv2.x())* (pv3.y())) - ((pv2.y())*(pv3.x()));
          float Cond3 =  (((pv3.y()) - (pv1.y()))*pointx) + (((pv1.x()) - (pv3.x()))*pointy) + ((pv3.x())* (pv1.y())) - ((pv3.y())*(pv1.x()));
          if ((Cond1>0) && (Cond2>0) && (Cond3>0)  && (determinante>0)){
            contador = contador+1;
            circle_raster( pointx, pointy );
          }
          else if ((Cond1<0) && (Cond2<0) && (Cond3<0) && (determinante<0)){
            contador = contador+1;
            circle_raster( pointx, pointy );
          }
            
        }   
      }
      //si en un cuadrado algun punto quedo por dentro y algun otro por fuera
      if (contador>0 && contador<4){
        float pointx = x  + 0.5;
        float pointy = y + 0.5;
        stroke(0, 0, 255);
        strokeWeight(0.5);
        point( pointx, pointy);
        //vuelvo a recorrer pintando todo de azul, cambiar estos dos ciclos por un pintado en el centro del cuadrado
        /*for ( float i = 0; i < 2; i++ ) {
          for ( float j = 0; j < 2; j++ ) {
            float pointx = x + i / 2 + 0.25;
            float pointy = y + j / 2 + 0.25;
            stroke(0, 0, 255);
            strokeWeight(0.5);
            point( pointx, pointy);
            
            }
        }*/
      
      }
    }
  }
}

void antialiasing(){
  int size = (int) pow( 2, n ) / 2;
  Vector pv1 = (v1);
  Vector pv2 = (v2);
  Vector pv3 = (v3);
  //Vector pv1 = frame.coordinatesOf(v1);
  //Vector pv2 = frame.coordinatesOf(v2);
  //Vector pv3 = frame.coordinatesOf(v3);
  float determinante = (((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  for ( int x = -size; x <= size; x++ ) {
    for (  int y = -size; y <= size; y++ ) {
      for ( float i = 0; i < 2; i++ ) {
        for ( float j = 0; j < 2; j++ ) {
          float pointx = x + i / 2 + 0.25;
          float pointy = y + j / 2 + 0.25;
          float Cond1 =  (((pv1.y()) - (pv2.y()))*pointx) + (((pv2.x()) - (pv1.x()))*pointy) + ((pv1.x())* (pv2.y())) - ((pv1.y())*(pv2.x()));
          float Cond2 =  (((pv2.y()) - (pv3.y()))*pointx) + (((pv3.x()) - (pv2.x()))*pointy) + ((pv2.x())* (pv3.y())) - ((pv2.y())*(pv3.x()));
          float Cond3 =  (((pv3.y()) - (pv1.y()))*pointx) + (((pv1.x()) - (pv3.x()))*pointy) + ((pv3.x())* (pv1.y())) - ((pv3.y())*(pv1.x()));
          if ((1>Cond1 && Cond1>-1) || (1>Cond1 && Cond1>-1) || (1>Cond1 && Cond1>-1)){
            circle_raster( pointx, pointy );
          }
            
        }   
      }
    }
  }

}

void circle_raster( float pointx, float pointy ) {
  pushStyle();
  stroke(247, 176, 243);
  //point( pointx, pointy);
  popStyle();
  pushStyle();
  stroke(0, 0, 255);
  strokeWeight(0.5);
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
}