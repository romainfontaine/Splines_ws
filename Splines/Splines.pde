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
boolean draw_surfaces;

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
  adaptContinuityC1CubicBezier();
}

void adaptContinuityC1CubicBezier() {
  for (int i = 3; i<interpolator.keyFrames().size()-3; i+=3) {
    Frame f = interpolator.keyFrames().get(i);
    Vector p2 = interpolator.keyFrames().get(i).position();
    Vector p1 = interpolator.keyFrames().get(i-1).position();
    p2.multiply(2);
    p1.multiply(-1);
    p2.add(p1);
    interpolator.keyFrames().get(i+1).setPosition(p2); // P2-P1+P2
  }
}

void boid(float x, float y, float z) {
  pushMatrix();
  pushStyle();
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

void v3darr(float[] a) {
  vertex(a[0], a[1], a[2]);
}

void interpolateFace(float[][][] face, int subdivisions) {
  float [][][] interpolated_splines = new float[face.length][subdivisions][3];
  for (int i = 0; i<face.length; i++) {
    interpolated_splines[i] = new NaturalCubicCurve(face[i], subdivisions).getPoints();
  }

  float[][] prev = new float[interpolated_splines.length*subdivisions][3];
  for (int i = 0; i<interpolated_splines.length*subdivisions; i++) {
    prev[i]=face[0][0];
  }

  for (int i = 0; i<interpolated_splines[0].length; i++) {
    float[][] control_points = new float[interpolated_splines.length][3];
    for (int k = 0; k<face.length; k++) {
      control_points[k]=interpolated_splines[k][i];
    }

    float [][] pts = new NaturalCubicCurve(control_points, subdivisions).getPoints();
    for (int k = 0; k<pts.length-1; k++) {
      beginShape(TRIANGLES);
      v3darr(pts[k]);
      v3darr(prev[k]);
      v3darr(pts[k+1]);


      v3darr(pts[k+1]);
      v3darr(prev[k]);
      v3darr(prev[k+1]);
      endShape();
    }
    prev = pts;
  }
}

void boidSurface(int x, int y, int z, int subdiv, boolean nofill) {
  pushMatrix();
  translate(x, y, z);
  pushStyle();
  if (!nofill)
    fill(255, 0, 0);
  else
    noFill();
  stroke(0, 0, 255);
  interpolateFace(new float[][][]{
    {{30, 0, 0}, {0, 15, 0}, {-30, 20, 0}}, 
    {{30, 0, 0}, {0, 0, 15}, {-30, 0, 20}}, 
    {{30, 0, 0}, {0, -15, 0}, {-30, -20, 0}}
    }, subdiv);

  interpolateFace(new float[][][]{
    {{30, 0, 0}, {0, 15, 0}, {-30, 20, 0}}, 
    {{30, 0, 0}, {0, -15, 0}, {-30, -20, 0}}
    }, subdiv);

  interpolateFace(new float[][][]{
    {{-30, 20, 0}, {-30, 0, 20}, {-30, -20, 0}}, 
    {{-30, -20, 0}, {-30, 0, 0}, {-30, 20, 0}}
    }, subdiv);
  popStyle();
  popMatrix();
}

void surface(int subdiv) {
  pushMatrix();
  pushStyle();
  translate(-100, 0, 0);
  fill(0, 150, 0);
  stroke(0, 255, 0);
  interpolateFace(new float[][][]{
    {{-60, -60, 0}, {-30, -60, 0}, {0, -60, 0}, {30, -60, 0}, {60, -60, 0}}, 
    {{-60, -30, 0}, {-30, -30, 0}, {0, -30, 0}, {30, -30, 0}, {60, -30, 0}}, 
    {{-60, 0, 0}, {-30, 0, 0}, {0, 0, 30}, {30, 0, 0}, {60, 0, 0}}, 
    {{-60, 30, 0}, {-30, 30, 0}, {0, 30, 0}, {30, 30, 0}, {60, 30, 0}}, 
    {{-60, 60, 0}, {-30, 60, 0}, {0, 60, 0}, {30, 60, 0}, {60, 60, 0}}, 
    }, subdiv);
  popMatrix();
  popStyle();
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

  scene.beginScreenCoordinates();
  textSize(32);
  text(s[mode].getClass().getName(), 0, 32);
  scene.endScreenCoordinates();

  if (draw_surfaces) {
    boid(100, 0, 0);
    int subdivSurface = 10;
    boidSurface(0, -30, 0, subdivSurface, true);
    boidSurface(0, 30, 0, subdivSurface, false);

    surface(10);
  }
}

void keyPressed() {
  if (key == ' ')
    mode = mode < 3 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
  if (key == 's')
    draw_surfaces = !draw_surfaces;
    
}