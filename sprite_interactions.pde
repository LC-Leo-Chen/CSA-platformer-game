void moveNPC(ArrayList<entity>guys, boolean type){
  for(int i=0; i<guys.size(); i++){
    if(guys.get(i).check_collide(player)){
      guys.remove(i);
      i--;//as the next step will use the same index due to the deletion
      if(type)points++;
      else points--;
      continue;
    }
    boolean sstat=false;//assume that the entity does not collide with any of the bombs
    for(int j=0; j<bombs.size(); j++){
      if(guys.get(i).check_collide(bombs.get(j))){
        guys.remove(i);
        bombs.remove(j);
        i--;
        sstat=true;
        break;
      }
    }
    if(sstat)continue;//do not continue or else it will cause bugs
    float cx1=guys.get(i).getX()+guys.get(i).getW()/2,cy1=guys.get(i).getY()+guys.get(i).getH()/2;
    float cx2=player.getX()+player.getW()/2,cy2=player.getY()+player.getH()/2;
    if(dist(cx1,cy1,cx2,cy2)>400)continue;//do not react to player unless the player is close enough
    if(!type && abs(cx1-cx2)<50)guys.get(i).setdX((cx2-cx1)*0.1);
    else if(cx1<cx2)guys.get(i).setdX(7*((type)?-1:1));
    else if(cx1>=cx2)guys.get(i).setdX(-7*((type)?-1:1));
    boolean jump_stat=false;
    guys.get(i).setX(guys.get(i).getX()+guys.get(i).getdX());//temporarily update position to check whether the entity is touching an obstacle or not
    if(guys.get(i).touching_obstacles(obstacles)!=-1)//need to jump over wall
      jump_stat=true;
    guys.get(i).setX(guys.get(i).getX()-guys.get(i).getdX());//reset to original position
    if(jump_stat){
      guys.get(i).setY(guys.get(i).getY()+1);//temporary update similar to the horizontal one
      if(guys.get(i).touching_obstacles(obstacles)!=-1)//if touching ground also
        guys.get(i).setdY(-25);//jump
      guys.get(i).setY(guys.get(i).getY()-1);//reset position
    }
  }
}
boolean right=false,left=false,jump=false,shoot=false;
boolean prv_shoot=false;

void keyPressed(){//user control
  if(keyCode==LEFT || key=='a')left=true;
  if(keyCode==RIGHT || key=='d')right=true;
  if(keyCode==UP || key=='w')jump=true;
  if(right&&left)player.setdX(0);//stop characer
  else if(right)player.setdX(10);//move right
  else if(left)player.setdX(-10);//move left
  if(jump){
    player.setY(player.getY()+1);//temporary update for status check
    if(player.touching_obstacles(obstacles)!=-1)//if it is legal to jump
      player.setdY(-25);//jump
    player.setY(player.getY()-1);//reset position
  }
}
void keyReleased(){//reset control status when not pressing
  if(keyCode==LEFT || key=='a')left=false;
  if(keyCode==RIGHT || key=='d')right=false;
  if(keyCode==UP || key=='w')jump=false;
  key=0;
  keyCode=0;
}
void mousePressed(){
  bombs.add(new entity(player.getX()+(player.getW()-bombImage.width)/2.0,player.getY()+(player.getH()-bombImage.height)/2.0,bombImage));
  float xx=mouseX-width/2,yy=mouseY-height/2;
  float ang=getAng(xx,yy);
  bombs.get(bombs.size()-1).setdX(power*cos(ang));//x component of bomb movement
  bombs.get(bombs.size()-1).setdY(power*sin(ang));//y component of bomb movement
  bombs.get(bombs.size()-1).setResist(2.0);//sets the friction of the bomb
}
