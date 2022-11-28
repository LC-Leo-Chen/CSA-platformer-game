//declare variables global to the game
PImage smileyFace, blake, playerImage, brick, goalImage, bombImage, circle;//images
//characters and objects
entity player, goal;
ArrayList<entity>enemies = new ArrayList(), friendlies = new ArrayList(), bombs = new ArrayList();
ArrayList<sprite>obstacles = new ArrayList(), aim_assist = new ArrayList();
//display parameters and physics parameters
int INTERVAL=60;
int points=0, level=1;
float acc=0.8, power=20;
final int MAX_LVL=3;
final float pi=acos(-1);//for convenience and also that I do not have to recalculate everytime (trivial problem though)

void loadMap(int lvl) {
  //load map
  friendlies.clear();
  enemies.clear();
  obstacles.clear();
  bombs.clear();
  goal=null;
  String[] lines = loadStrings("MAP#"+lvl+".csv");
  for (int i=0; i<lines.length; i++) {//converts CSV to character objects
    String[] val = split(lines[i], ",");
    for (int j=0; j<val.length; j++) {
      if (val[j].equals("1"))
        obstacles.add(new sprite(j*INTERVAL, i*INTERVAL, brick));
      else if (val[j].equals("2"))
        friendlies.add(new entity(j*INTERVAL+(INTERVAL-smileyFace.width)/2.0, i*INTERVAL+(INTERVAL-smileyFace.height)/2.0, smileyFace));
      else if (val[j].equals("3"))
        enemies.add(new entity(j*INTERVAL+(INTERVAL-blake.width)/2.0, i*INTERVAL+(INTERVAL-blake.height)/2.0, blake));
      else if (val[j].equals("player"))
        player = new entity(j*INTERVAL+(INTERVAL-playerImage.width)/2.0, i*INTERVAL+(INTERVAL-playerImage.height)/2.0, playerImage);
      else if (val[j].equals("goal"))
        goal = new entity(j*INTERVAL+(INTERVAL-goalImage.width)/2.0, i*INTERVAL+(INTERVAL-goalImage.height)/2.0, goalImage);
    }
  }
}
void setup() {//initialization
  size(1500, 1000);//size of screen
  //load images for characters
  brick = loadImage("pictures/red_brick.png");
  smileyFace = loadImage("pictures/smiley.png");
  blake = loadImage("pictures/Blake.png");
  playerImage = loadImage("pictures/player.png");
  goalImage = loadImage("pictures/crate.png");
  bombImage = loadImage("pictures/bomb.png");
  circle = loadImage("pictures/snow.png");
  //resize
  brick.resize(INTERVAL, INTERVAL);
  bombImage.resize(INTERVAL+1, INTERVAL+1);
  circle.resize(5, 5);
  //parabola construction
  for (int i=0; i<100; i++) {
    aim_assist.add(new sprite(0, 0, circle));
  }
  loadMap(level);
}
void draw() {
  background(255, 255, 255);
  //show sprites
  for (int i=0; i<enemies.size(); i++)
    enemies.get(i).show();
  for (int i=0; i<obstacles.size(); i++)
    obstacles.get(i).show();
  for (int i=0; i<friendlies.size(); i++)
    friendlies.get(i).show();
  for (int i=0; i<bombs.size(); i++)
    bombs.get(i).show();
  if (goal!=null && goal.check_collide(player))
    loadMap(++level);//simply don't put a goal at the last level to ensure it will not have an error
  //show aim assist parabola
  aim_assist.get(0).setX(player.getX()+(player.getW()-circle.width)/2.0);
  aim_assist.get(0).setY(player.getY()+(player.getH()-circle.height)/2.0);
  float ang=getAng(mouseX-width/2, mouseY-height/2);
  aim_assist.get(0).setdX(cos(ang)*power);
  aim_assist.get(0).setdY(sin(ang)*power);
  aim_assist.get(0).show();
  for (int i=1; i<aim_assist.size(); i++) {
    aim_assist.get(i).setX(aim_assist.get(i-1).getX()+aim_assist.get(i-1).getdX());
    aim_assist.get(i).setY(aim_assist.get(i-1).getY()+aim_assist.get(i-1).getdY());
    aim_assist.get(i).setdX(aim_assist.get(i-1).getdX());//x component is not affected by gravity
    aim_assist.get(i).setdY(aim_assist.get(i-1).getdY()+acc);//y component follows gravity
    aim_assist.get(i).show();
  }
  player.show();
  if (goal!=null)goal.show();
  textSize(30);
  textAlign(CENTER);
  fill(0, 0, 0);
  text("level: "+level+"\npoints: "+points, width/2, height/2-100);
  //update positions
  player.legal_update();
  if (goal!=null)goal.legal_update();
  for (int i=0; i<friendlies.size(); i++)
    friendlies.get(i).legal_update();
  for (int i=0; i<enemies.size(); i++)
    enemies.get(i).legal_update();
  for (int i=0; i<bombs.size(); i++) {
    if (bombs.get(i).touching)
      bombs.get(i).setFriction(true);
    else bombs.get(i).setFriction(false);
    bombs.get(i).legal_update();
  }
  //update moves
  keyPressed();
  moveNPC(enemies, false);
  moveNPC(friendlies, true);
}
