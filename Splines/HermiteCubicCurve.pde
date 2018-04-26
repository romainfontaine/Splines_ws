class HermiteCubicCurve extends Spline {
  public HermiteCubicCurve(float[][]points, int subdivisions) {
    super(points, subdivisions);
  }
  @Override
    public void Draw() {
    for (int i = 0; i<points.length-1; i++) {
      float[] p0 = new float[3];
      float[] p1 = new float[3];
      for (int k = 0; k<3; k++) {
        p0[k]=points[i][k];
        p1[k]=points[i+1][k];
      }

      float[] m0 = new float[3];
      float[] m1 = new float[3];
      for (int k = 0; k<3; k++) {
        if (i == 0) {
          m0[k] = points[i+1][k]-points[i][k];
          m1[k] = (points[i+2][k]-points[i][k])/2;
        } else if (i == points.length-2) {
          m0[k] = (points[i+1][k]-points[i-1][k])/2;
          m1[k] = (points[i+1][k]-points[i][k]);
        } else {
          m0[k] = (points[i+1][k]-points[i-1][k])/2;
          m1[k] = (points[i+2][k]-points[i][k])/2;
        }
      }

      float[] prev = new float[3];
      for (int k = 0; k<3; k++) {
        prev[k]=points[i][k];
      }
      for (float s = 0; s<=subdivisions; s+=1) {
        float t = s*1/subdivisions;
        float t2 = t*t;
        float t3 = t2*t;
        float[] p = new float[3];
        for (int k = 0; k<3; k++) {
          p[k] = (2*t3-3*t2+1)*p0[k] + (t3-2*t2+t)*m0[k] + (-2*t3+3*t2)*p1[k] + (t3-t2)*m1[k];
        }
        line(prev[0], prev[1], prev[2], p[0], p[1], p[2]);
        for (int k = 0; k<3; k++) {
          prev[k]=p[k];
        }
      }
    }
  }
}