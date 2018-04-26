abstract class Spline{
  protected float[][] points;
  protected int subdivisions;
  public Spline(float[][] points, int subdivisions) {
    this.points = points;
    this.subdivisions = subdivisions;
  }
  
  public void Draw(){}
}