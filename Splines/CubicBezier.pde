class CubicBezier extends Spline {
  public CubicBezier(float[][]points, int subdivisions) {
    super(points, subdivisions);
  }

  @Override
    public void Draw() {
    for (int k = 0; k+4<=points.length; k+=3) {
      float[] prev = new float[3];
      for (int i = 0; i<3; i++)
        prev[i] = points[k][i];  
      for (float s = 0; s<=subdivisions; s+=1) {
        float t = s*1/subdivisions;
        float t2 = t*t;
        float t3 = t2*t;
        float[] p = new float[3];
        for (int i = 0; i<3; i++)
          p[i] = pow(1-t, 3)*points[k][i]+3*t*pow(1-t, 2)*points[k+1][i]+3*t2*(1-t)*points[k+2][i]+t3*points[k+3][i];

        line(prev[0], prev[1], prev[2], p[0], p[1], p[2]);
        for (int i = 0; i<3; i++)
          prev[i] = p[i];
      }
    }
  }
}