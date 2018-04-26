class BezierDegreeN extends Spline {
  int degree;
  public BezierDegreeN(float[][]points, int subdivisions, int degree) {
    super(points, subdivisions);
    this.degree = degree;
  }

  float[] rec(float[][] points, float t) {
    if (points.length==1) {
      return points[0];
    }
    float[][] p = new float[points.length-1][3];
    for (int i = 0; i<points.length-1; i++) {
      for (int k = 0; k<3; k++) {
        p[i][k]=points[i+1][k]-points[i][k];
        p[i][k]*=t;
        p[i][k]+=points[i][k];
      }
    }
    return rec(p, t);
  }
  @Override
    public void Draw() {
    for (int j = 0; j+degree-1<points.length; j+=degree-1) {
      float[][] pts = new float[degree][3];
      for (int k = 0; k<degree; k++) {
        for (int i =  0; i<3; i++)
          pts[k][i]=points[k+j][i];
      }
      float[] prev = new float[3];
      for (int k = 0; k<3; k++) {
        prev[k]=pts[0][k];
      }
      for (int i = 0; i<=subdivisions; i++) {
        float t = (1/(float)subdivisions)*i;
        float[] p = rec(pts, t);
        line(prev[0], prev[1], prev[2], p[0], p[1], p[2]);
        for (int k =0; k<3; k++) {
          prev[k]=p[k];
        }
      }
    }
  }
}