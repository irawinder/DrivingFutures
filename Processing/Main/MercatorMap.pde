//PVector coord = mercatorMap.getScreenLocation(new PVector(localTowers.getFloat(i, "Lat"), localTowers.getFloat(i, "Lon")));

/**
 * Utility class to convert between geo-locations and Cartesian screen coordinates.
 * Can be used with a bounding box defining the map section.
 *
 * (c) 2011 Till Nagel, tillnagel.com
 */
public class MercatorMap {
  
  public static final float DEFAULT_TOP_LATITUDE = 80;
  public static final float DEFAULT_BOTTOM_LATITUDE = -80;
  public static final float DEFAULT_LEFT_LONGITUDE = -180;
  public static final float DEFAULT_RIGHT_LONGITUDE = 180;
  public static final float DEFAULT_ROTATION = 0;
  
  /** Horizontal dimension of this map, in pixels. */
  protected float mapScreenWidth;
  /** Vertical dimension of this map, in pixels. */
  protected float mapScreenHeight;

  /** Northern border of this map, in degrees. */
  protected float topLatitude;
  /** Southern border of this map, in degrees. */
  protected float bottomLatitude;
  /** Western border of this map, in degrees. */
  protected float leftLongitude;
  /** Eastern border of this map, in degrees. */
  protected float rightLongitude;

  private float topLatitudeRelative;
  private float bottomLatitudeRelative;
  private float leftLongitudeRadians;
  private float rightLongitudeRadians;
  
  private float rotation;
  
  // Dimensions for larger or equal-size canvas, perpendicular to north, that bounds and intersects 4 corners of original 
  private float lg_width;
  private float lg_height;

  public MercatorMap(float mapScreenWidth, float mapScreenHeight) {
    this(mapScreenWidth, mapScreenHeight, DEFAULT_TOP_LATITUDE, DEFAULT_BOTTOM_LATITUDE, DEFAULT_LEFT_LONGITUDE, DEFAULT_RIGHT_LONGITUDE, DEFAULT_ROTATION);
  }
  
  /**
   * Creates a new MercatorMap with dimensions and bounding box to convert between geo-locations and screen coordinates.
   *
   * @param mapScreenWidth Horizontal dimension of this map, in pixels.
   * @param mapScreenHeight Vertical dimension of this map, in pixels.
   * @param topLatitude Northern border of this map, in degrees.
   * @param bottomLatitude Southern border of this map, in degrees.
   * @param leftLongitude Western border of this map, in degrees.
   * @param rightLongitude Eastern border of this map, in degrees.
   */
  public MercatorMap(float mapScreenWidth, float mapScreenHeight, float topLatitude, float bottomLatitude, float leftLongitude, float rightLongitude, float rotation) {
    this.mapScreenWidth = mapScreenWidth;
    this.mapScreenHeight = mapScreenHeight;
    this.topLatitude = topLatitude;
    this.bottomLatitude = bottomLatitude;
    this.leftLongitude = leftLongitude;
    this.rightLongitude = rightLongitude;

    this.topLatitudeRelative = getScreenYRelative(topLatitude);
    this.bottomLatitudeRelative = getScreenYRelative(bottomLatitude);
    this.leftLongitudeRadians = getRadians(leftLongitude);
    this.rightLongitudeRadians = getRadians(rightLongitude);
    
    this.rotation = rotation;
    
    lg_width  = mapScreenHeight * sin( abs(getRadians(rotation)) ) + mapScreenWidth * cos( abs(getRadians(rotation)) );
    lg_height = mapScreenWidth * sin( abs(getRadians(rotation)) ) + mapScreenHeight * cos( abs(getRadians(rotation)) );
  }

  /**
   * Projects the geo location to Cartesian coordinates, using the Mercator projection.
   *
   * @param geoLocation Geo location with (latitude, longitude) in degrees.
   * @returns The screen coordinates with (x, y).
   */
  public PVector getScreenLocation(PVector geoLocation) {
    float latitudeInDegrees = geoLocation.x;
    float longitudeInDegrees = geoLocation.y;
    
    PVector loc = new PVector(getScreenX(longitudeInDegrees), getScreenY(latitudeInDegrees));
    loc.x -= lg_width/2;
    loc.y -= lg_height/2;
    loc.rotate(getRadians(rotation));
    loc.x += mapScreenWidth/2;
    loc.y += mapScreenHeight/2;
    
    return loc;
  }

  private float getScreenYRelative(float latitudeInDegrees) {
    return log(tan(latitudeInDegrees / 360f * PI + PI / 4));
  }

  private float getScreenY(float latitudeInDegrees) {
    return lg_height * (getScreenYRelative(latitudeInDegrees) - topLatitudeRelative) / (bottomLatitudeRelative - topLatitudeRelative);
  }
  
  private float getRadians(float deg) {
    return deg * PI / 180;
  }
  
  private float getDegrees(float rad) {
    return rad * 180 / PI;
  }

  private float getScreenX(float longitudeInDegrees) {
    float longitudeInRadians = getRadians(longitudeInDegrees);
    return lg_width * (longitudeInRadians - leftLongitudeRadians) / (rightLongitudeRadians - leftLongitudeRadians);
  }
  
  public PVector getGeo(PVector loc) {
    
    PVector screen = new PVector(loc.x, loc.y);
    screen.x -= mapScreenWidth/2;
    screen.y -= mapScreenHeight/2;
    screen.rotate(-getRadians(rotation));
    screen.x += lg_width/2;
    screen.y += lg_height/2;
    return new PVector(getLatitude(screen.y), getLongitude(screen.x));
    
    
  }
  
  private float getLatitude(float screenY) {
    //return topLatitude + (360f / PI) * (atan(exp(getLatitudeRelative(screenY))) - PI / 4);
    return topLatitude + (bottomLatitude - topLatitude) * screenY / lg_height;
  }
  
  private float getLongitude(float screenX) {
    return leftLongitude + (rightLongitude - leftLongitude) * screenX / lg_width;
  }
  
//  private float getLatitudeRelative(float screenY) {
//    return (bottomLatitudeRelative - topLatitudeRelative) * screenY / lg_height;
//  }
}
