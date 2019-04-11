/*module state visualizer
 only shows the modules in the order of given route number
 represented colors: (grey - offline) (red - locked) (green - unlocked)
 checks whether modules are online every 10-15 sec
 if received oocsi event and a module is unlocked, it stays unlocked on the interface. 
 
 because of the delay in checking online states of the module, println functions sometimes glitches
 */


import nl.tue.id.oocsi.*;
OOCSI oocsi;

//define modules as objects
module T01;
module T02;
module T03;
module T04;
module T05;

//variables to check online state
boolean T01_online;
boolean T02_online;
boolean T03_online;
boolean T04_online;
boolean T05_online;

//variables to check unlock state
boolean T01_unlocked = false;
boolean T02_unlocked = false;
boolean T03_unlocked = false;
boolean T04_unlocked = false;
boolean T05_unlocked = false;


//order of all modules in each route
String routeOrder [] []= { 
  {"T04", "T05", "T01", "T02", "T03"}, 
  {"T02", "T04", "T05", "T03", "T01"}, 
  {"T03", "T05", "T04", "T01", "T02"}
};

int currentRouteNumber = 0;
Boolean World_unlocked = false;

//used for time interval of checking online status
int currentTime;



void setup() {
  size(1000, 500);
  background(50);

  //bootup message
  textSize(60);
  fill(255);
  text("please wait 5 sec to boot up", 0, 0.9 * height);

  T01 = new module("T01");
  T02 = new module("T02");
  T03 = new module("T03");
  T04 = new module("T04");
  T05 = new module("T05");

  //name is randomized, so others could use the same interface to check the system
  oocsi = new OOCSI(this, "Simple_UI_v3_id" + str(int(random(10000))), "oocsi.id.tue.nl");
  oocsi.subscribe("Tyria");  

  millis();
}







void draw() {

  background(50);

  //checks whether the module is online or not every 10-15 sec
  if (millis() > currentTime) {
    println("refresh online status. praise the 5 sec lag");

    T01_online = oocsi.getClients().contains("T01");
    T02_online = oocsi.getClients().contains("T02");
    T03_online = oocsi.getClients().contains("T03");
    T04_online = oocsi.getClients().contains("T04");
    T05_online = oocsi.getClients().contains("T05");

    println("refresh completed");

    currentTime = millis() + 10000;
  }


  //display all modules in its order
  T01.define(T01_online, T01_unlocked, currentRouteNumber);
  T01.display();
  T02.define(T02_online, T02_unlocked, currentRouteNumber);
  T02.display();
  T03.define(T03_online, T03_unlocked, currentRouteNumber);
  T03.display();
  T04.define(T04_online, T04_unlocked, currentRouteNumber);
  T04.display();
  T05.define(T05_online, T05_unlocked, currentRouteNumber);
  T05.display();


  //show routenumber on the right bottom corner
  textMode(CORNER);
  textSize(60);
  text(currentRouteNumber, 0.97 * width, 0.98 * height);
}







class module {

  color rectC;
  color textC = color(255);

  float xposRatioAll;
  float yposRatioRect = 0.8;
  float yposRatioText = 0.9;

  float rectSize = 50;
  float cornerSize = 5;

  String moduleName;
  int myRoutePosition;

  boolean onlineState = false;
  boolean unlockedState = false;



  module(String myName) {
    moduleName = myName;
  }



  void define(boolean onlineState, boolean unlockedState, int currentRouteNumber) {

    //defining the position within the route order
    for (int i = 0; i < routeOrder[0].length; i++) {                                  
      if ( moduleName.equals( routeOrder[currentRouteNumber][i] ) == true ) {
        myRoutePosition = i;
      } else {
        //do nothing
      }
    }


    //define the x-position based on the route order position
    xposRatioAll = (float(myRoutePosition) + 1) / (routeOrder[0].length + 1);


    //defining the color of online/offline
    if (onlineState == true) {
      //when online, define the color of unlocked state
      if (unlockedState == true) {
        rectC = color(0, 255, 0);
      } else {
        rectC = color(255, 0, 0);
      }
      //when offline
    } else {
      rectC = color(100);
    }
  }



  void display() {

    //drawing the module as rectangle
    noStroke();
    fill(rectC);
    rectMode(CENTER);
    rect( 1000 * xposRatioAll, height/2, rectSize, rectSize, cornerSize );

    //drawing the module names as text
    fill(textC);
    textSize(18);
    textAlign(CENTER);
    text( moduleName, 1000 * xposRatioAll, height/2 + 50 );
  }
}




void Tyria(OOCSIEvent event) {

  //only capture this module's info when this module is not unlocked
  //if it is true, it will stay true and not ask for new status
  if ( !T01_unlocked ) 
    T01_unlocked = event.getBoolean("T01_unlocked", false);

  if ( !T02_unlocked ) 
    T02_unlocked = event.getBoolean("T02_unlocked", false);

  if ( !T03_unlocked ) 
    T03_unlocked = event.getBoolean("T03_unlocked", false);

  if ( !T04_unlocked ) 
    T04_unlocked = event.getBoolean("T04_unlocked", false);

  if ( !T05_unlocked ) 
    T05_unlocked = event.getBoolean("T05_unlocked", false);

  currentRouteNumber = event.getInt("currentRouteNumber", 0);
  World_unlocked = event.getBoolean("World_unlocked", false);

  //everytime an event occurs, check and print about the route number and system unlock state
  println("current route number: " + currentRouteNumber);
  println("world unlocked: " + World_unlocked);
}  





void mousePressed() {
  println(oocsi.getClients());
}
