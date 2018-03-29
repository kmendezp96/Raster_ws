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
  TriangleAntiAliassing();
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

void TriangleAntiAliassing(){
  stroke(255, 0, 0);

  Vector pv1 = frame.coordinatesOf(v1);
  Vector pv2 = frame.coordinatesOf(v2);
  Vector pv3 = frame.coordinatesOf(v3);
  float determinante = (((pv2.x() - pv1.x())*(pv3.y() - pv1.y())) - ((pv2.y() - pv1.y())*(pv3.x() - pv1.x())));
  //println(determinante);
  int cercania = 15;
  for (int i = - round(pow(2,n-1));i<round(pow(2,n-1));i++){
    for (int j = - round(pow(2,n-1));j<round(pow(2,n-1)); j++){
      float Cond1 =  (((pv1.y()) - (pv2.y()))*i) + (((pv2.x()) - (pv1.x()))*j) + ((pv1.x())* (pv2.y())) - ((pv1.y())*(pv2.x()));
      float Cond2 =  (((pv2.y()) - (pv3.y()))*i) + (((pv3.x()) - (pv2.x()))*j) + ((pv2.x())* (pv3.y())) - ((pv2.y())*(pv3.x()));
      float Cond3 =  (((pv3.y()) - (pv1.y()))*i) + (((pv1.x()) - (pv3.x()))*j) + ((pv3.x())* (pv1.y())) - ((pv3.y())*(pv1.x()));
      /*int Cond1 =  ((round(pv1.y()) - round(pv2.y()))*i) + ((round(pv2.x()) - round(pv1.x()))*j) + (round(pv1.x())* round(pv2.y())) - (round(pv1.y())*round(pv2.x()));
      int Cond2 =  ((round(pv2.y()) - round(pv3.y()))*i) + ((round(pv3.x()) - round(pv2.x()))*j) + (round(pv2.x())* round(pv3.y())) - (round(pv2.y())*round(pv3.x()));
      int Cond3 =  ((round(pv3.y()) - round(pv1.y()))*i) + ((round(pv1.x()) - round(pv3.x()))*j) + (round(pv3.x())* round(pv1.y())) - (round(pv3.y())*round(pv1.x()));*/
      
      //prueba 1, no funciona la idea es determinar un rango en el que puedan estar los valores, las pruebas muestran demasiado error
      //println  (v1.y() +" "+Cond2+" " + Cond3 + " "+i+" "+j);
      //if ((cercania>=Cond1 && Cond1>=-cercania) && (cercania>=Cond1 && Cond2>=-cercania) && (cercania>=Cond3 && Cond3>=-cercania)  && (cercania>=determinante && determinante>=-cercania)){
      //if ((Cond1==1 || Cond1==0 || Cond1==-1) && (Cond2==1 || Cond2==0 || Cond2==-1) && (Cond3==1 || Cond3==0 || Cond3==-1)  && (determinante==1 || determinante==0 || determinante==-1)){
        //println  (Cond1 +" "+Cond2+" " + Cond3 + " "+i+" "+j);
        //point(i,j);
      //}else if ((i==7) && (j==3)){
        //println  (Cond1 +" "+Cond2+" " + Cond3 + " "+determinante);
      //}
      //else if ((Cond1==0) && (Cond2==0) && (Cond3==0) && (determinante<=0)){
        //point(i,j);
      //}
      // si cumplen al menos dos de las 3 condiciones, es aun mas inexacto
      if (determinante>0){
        if  (((Cond1>=0) && (Cond2>=0) && (Cond3<=0)) || ((Cond1>=0) && (Cond3>=0) && (Cond2<=0)) || ((Cond2>=0) && (Cond3>=0) && (Cond1<=0))){
          point(i,j);
        }
      
      }else{
        if  (((Cond1<=0) && (Cond2<=0) && (Cond3>=0)) || ((Cond1<=0) && (Cond3<=0) && (Cond2>=0)) || ((Cond2<=0) && (Cond3<=0) && (Cond1>=0))){
          point(i,j);
        }
      }
      
    }
  
  }

}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector (90,240);
  v2 = new Vector (200,180);
  v3 = new Vector (120,60);
  //v1 = new Vector(random(low, high), random(low, high));
  //v2 = new Vector(random(low, high), random(low, high));
  //v3 = new Vector(random(low, high), random(low, high));
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