/**
 * Splines.
 *
 * Here we use the interpolator.keyFrames() nodes
 * as control points to render different splines.
 *
 * Press ' ' to change the spline mode.
 * Press 'g' to toggle grid drawing.
 * Press 'c' to toggle the interpolator path drawing.
 */

import frames.input.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// global variables
// modes: 0 natural cubic spline; 1 Hermite;
// 2 (degree 7) Bezier; 3 Cubic Bezier
int mode;

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;

//Choose P3D for a 3D scene, or P2D or JAVA2D for a 2D scene
String renderer = P3D;

void setup() {
  size(800, 800, renderer);
  scene = new Scene(this);
  eye = new OrbitNode(scene);
  eye.setDamping(0);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(150);
  scene.fitBallInterpolation();
  interpolator = new Interpolator(scene, new Frame());
  // framesjs next version, simply go:
  //interpolator = new Interpolator(scene);

  // Using OrbitNodes makes path editable
  for (int i = 0; i < 13; i++) {
    Node ctrlPoint = new OrbitNode(scene);
    ctrlPoint.randomize();
    interpolator.addKeyFrame(ctrlPoint);
  }
}

void boid(float x, float y, float z) {
  pushMatrix();
  pushStyle();
  rotateX(PI/2);
  translate(x, y, z);

  stroke(0, 0, 255);
  float[][][] splines = new float[][][]{
    {{30, 0, 0}, {0, 15, 0}, {-30, 20, 0}}, 
    {{30, 0, 0}, {0, -15, 0}, {-30, -20, 0}}, 
    {{30, 0, 0}, {0, 0, 15}, {-30, 0, 20}}, 
    {{-30, 20, 0}, {-30, 0, 20}, {-30, -20, 0}}, 
    {{-30, -20, 0}, {-30, 20, 0}}
  }; 
  for (int i = 0; i<splines.length; i++) {
    new NaturalCubicCurve(splines[i], 10).Draw();
  }
  popStyle();
  popMatrix();
}

void draw() {
  background(175);
  if (drawGrid) {
    stroke(255, 255, 0);
    scene.drawGrid(200, 50);
  }
  if (drawCtrl) {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    for (Frame frame : interpolator.keyFrames())
      scene.drawPickingTarget((Node)frame);
  } else {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    scene.drawPath(interpolator);
  }

  float[][] points = new float[interpolator.keyFrames().size()][3];

  for (int i = 0; i<interpolator.keyFrames().size(); i++) {
    Frame f = interpolator.keyFrames().get(i);
    points[i][0] = f.position().x();
    points[i][1] = f.position().y();
    points[i][2] = f.position().z();
  }
  int subdivisions = 100;

  Spline[] s = new Spline[]{new NaturalCubicCurve(points, subdivisions), 
    new HermiteCubicCurve(points, subdivisions), 
    new BezierDegreeN(points, subdivisions, 7), 
    new CubicBezier(points, subdivisions)};
  s[mode].Draw();

  boid(50, 100, 50);
}

void keyPressed() {
  if (key == ' ')
    mode = mode < 3 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
}