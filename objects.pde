public static boolean collide(sprite obj, sprite target) {//checks collision between 2 sprites
  //hit box, get edge from top left corner coordinates
  int Redge=(int)obj.getX()+obj.w, Ledge=(int)obj.getX(), Uedge=(int)obj.getY(), Dedge=(int)obj.getY()+obj.h;
  int Redge2=(int)target.getX()+target.w, Ledge2=(int)target.getX(), Uedge2=(int)target.getY(), Dedge2=(int)target.getY()+target.h;
  boolean RinRange=Redge<Redge2 && Redge>Ledge2;//pretty self explanatory
  boolean LinRange=Ledge<Redge2 && Ledge>Ledge2;
  boolean UinRange=Uedge<Dedge2 && Uedge>Uedge2;
  boolean DinRange=Dedge<Dedge2 && Dedge>Uedge2;
  /*if(RinRange&&UinRange||RinRange&&DinRange||LinRange&&UinRange||LinRange&&DinRange)
   System.out.println(RinRange+" "+LinRange+" "+UinRange+" "+DinRange);*/
  return RinRange&&UinRange||RinRange&&DinRange||LinRange&&UinRange||LinRange&&DinRange;
}
class sprite {
  int w, h;
  float x, y, dx=0, dy=0;//x,y represents the left top corner
  PImage img;
  public sprite(float xx, float yy, PImage imgg) {
    x=xx;
    y=yy;
    img=imgg;
    w=img.width;
    h=img.height;
  }
  //coordinate values
  public int getH() {
    return h;
  }
  public int getW() {
    return w;
  }
  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public void setX(float xx) {
    x=xx;
  }
  public void setY(float yy) {
    y=yy;
  }
  //amount of coordinate change
  public float getdX() {
    return dx;
  }
  public float getdY() {
    return dy;
  }
  public void setdX(float xx) {
    dx=xx;
  }
  public void setdY(float yy) {
    dy=yy;
  }
  //update coordinate values
  public void updateX() {
    x+=dx;
  }
  public void updateY() {
    y+=dy;
  }

  public boolean check_collide(sprite S) {
    return collide(this, S)||collide(S, this);//since we do not know which one is larger, it is true if just one is true
  }
  public void show() {
    int scrX=(int)(x-player.getX()+(width-player.getW())/2.0), scrY=(int)(y-player.getY()+(height-player.getH())/2.0);//show sprite relative to player location, AKA screen scroll
    image(img, scrX, scrY);
  }
}
class entity extends sprite {
  boolean friction=true;
  boolean touching=false;
  float resist=0.5;
  public entity(float x, float y, PImage img) {
    super(x, y, img);//call the original class's constructor
  }
  public int touching_obstacles(ArrayList<sprite>obstacles) {//gets the index of the obstacle that the entity collides with
    for (int i=0; i<obstacles.size(); i++)
      if (check_collide(obstacles.get(i)))
        return i;
    return -1;
  }
  public void setFriction(boolean stat){
    friction=stat;
  }
  public void setResist(float val){
    resist=val;
  }
  public void legal_update() {//update according to physical laws of the game
    //assume that the world is composed of purely horizontal and vertical components, no diagonal or anything like that, so we can check independently as long as they don't step too much to go through walls
    //maintain vertical
    touching=false;
    updateY();//try and change position
    int pos=touching_obstacles(obstacles);//it does not include shared edges as touching, else since when standing it always touches the ground, you will be moved to the very edge even if being legal
    if (pos!=-1) {
      if (dy>0){
        y=obstacles.get(pos).getY()-h;//if not legal then go to the limit that you can go
        dy=-acc;
      }
      else{
        y=obstacles.get(pos).getY()+obstacles.get(pos).getH();
        dy=-acc+1;
      }
      touching=true;
    }
    else{
      dy+=acc;//gravity
    }
    //maintain horizontal, very much similar to the vertical part so comments are ommitted
    updateX();
    pos=touching_obstacles(obstacles);
    if (pos!=-1) {
      if (dx>0)x=obstacles.get(pos).getX()-w;
      else x=obstacles.get(pos).getX()+obstacles.get(pos).getW();
      dx=0;
      touching=true;
    }
    if(friction){
      if (dx<0 && dx+resist>0 || dx>0 && dx-resist<0)dx=0;//or has lower precedence than and
      else if (dx>0)dx-=resist;//friction
      else if (dx<0)dx+=resist;
    }
  }
}
public float getAng(float xx,float yy){//get angle from x and y values
  float ang=pi/2;
  if(xx==0){
    if(yy<0)ang+=pi;
  }
  else{
    ang=atan(yy/xx);
    if(xx<0)ang+=pi;
  }
  return ang;
}
