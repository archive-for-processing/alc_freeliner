/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */

import oscP5.*;
import netP5.*;

FreeLiner freeliner;

// fonts
PFont font;
PFont introFont;

// OSC parts
OscP5 oscP5;
// where to send a sync message
NetAddress toPDpatch;
OscMessage tickmsg = new OscMessage("/freeliner/tick");

////////////////////////////////////////////////////////////////////////////////////
///////
///////     OPTIONS!
///////
////////////////////////////////////////////////////////////////////////////////////

// are you using OSX? I do not, I use GNU/Linux
boolean OSX = false; // should set itself to true if OSX

// invert colors
final boolean INVERTED_COLOR = false;

// disable splash logo
boolean doSplash = true;

// UDP Port for incomming messages
final int OSC_IN_PORT = 6667;

// UDP Port for outgoing sync message
final int OSC_OUT_PORT = 6668;

// IP address to send sync messages to
final String OSC_OUT_IP = "127.0.0.1";

// lovely new feature of p3! set your graphics preferences.
void settings(){
  // set the resolution, or fullscreen and display
  size(1024, 768, P2D);
  //fullScreen(P2D, 2);
  smooth();
  //noSmooth();
}

// Your color pallette!

// customize your colors
// final color[] colorPallet = {
//                   color(255),
//                   color(0),
//                   color(255,0,0),
//                   color(0,255,0),
//                   color(0,0,255),
//                   // customize these colors!
//                   color(0,255,255),
//                   color(255,255,0),
//                   color(0,100,0),
//                   color(100,3,255),
//                   color(255,0,255),
//                 };

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Setup
///////
////////////////////////////////////////////////////////////////////////////////////

void setup() {
  surface.setResizable(false); // needs to scale other PGraphics
  //surface.setAlwaysOnTop(boolean);
  noCursor();
  hint(ENABLE_KEY_REPEAT); // usefull for performance

  // load fonts
  introFont = loadFont("MiniKaliberSTTBRK-48.vlw");
  font = loadFont("Arial-BoldMT-48.vlw");
  splash();

  // pick your flavour of freeliner
  freeliner = new FreeLiner();
  //freeliner = new FreelinerLED(this, "ledstarmap.xml");
  //freeliner = new FreelinerSyphon(this);

  // osc setup
  oscP5 = new OscP5(this, OSC_IN_PORT);
  toPDpatch = new NetAddress(OSC_OUT_IP, OSC_OUT_PORT);

  // set OS
  if(System.getProperty("os.name").charAt(0) == 'M') OSX = true;
  else OSX = false;
}

// splash screen!
void splash(){
  background(0);
  stroke(100);
  fill(150);
  textMode(CENTER);
  textFont(introFont);
  text("a!Lc freeLiner", 10, height/2);
  textSize(24);
  fill(255);
  text("V0.03 - made with PROCESSING", 10, (height/2)+20);
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Draw
///////
////////////////////////////////////////////////////////////////////////////////////

// do the things
void draw() {
  background(0);
  if(doSplash) splash();
  freeliner.update();
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    Input
///////
////////////////////////////////////////////////////////////////////////////////////

// relay the inputs to the mapper
void keyPressed() {
  freeliner.getKeyboard().processKey(key, keyCode);
  if (key == 27) key = 0;       // dont let escape key, we need it :)
}

void keyReleased() {
  freeliner.getKeyboard().processRelease(key, keyCode);
}

void mousePressed(MouseEvent event) {
  doSplash = false;
  freeliner.getMouse().press(mouseButton);
}

void mouseDragged() {
  freeliner.getMouse().drag(mouseButton, mouseX, mouseY);
}

void mouseMoved() {
  freeliner.getMouse().move(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) {
  freeliner.getMouse().wheeled(event.getCount());
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////    OSC
///////
////////////////////////////////////////////////////////////////////////////////////

void oscEvent(OscMessage theOscMessage) {  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern("/freeliner/tweak")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ssi")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String tags = theOscMessage.get(0).stringValue();
      char kay = theOscMessage.get(1).stringValue().charAt(0);
      int val = theOscMessage.get(2).intValue();
      freeliner.keyboard.oscDistribute(tags, kay, val);
    }
  }

  if(theOscMessage.checkAddrPattern("/freeliner/trigger")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("s")) {
      String tags = theOscMessage.get(0).stringValue();
      freeliner.templateManager.oscTrigger(tags, -1);
    }
    if(theOscMessage.checkTypetag("si")) {
      String tags = theOscMessage.get(0).stringValue();
      freeliner.templateManager.oscTrigger(tags, theOscMessage.get(1).intValue());
    }
  }
  if(theOscMessage.checkAddrPattern("/freeliner/color")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("siiii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      String tags = theOscMessage.get(0).stringValue();
      color col = color(
        theOscMessage.get(1).intValue(),
        theOscMessage.get(2).intValue(),
        theOscMessage.get(3).intValue(),
        theOscMessage.get(4).intValue());
      freeliner.templateManager.setCustomColor(tags, col);
    }
  }
  if(theOscMessage.checkAddrPattern("/freeliner/trails") == true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("i")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int tval = theOscMessage.get(0).intValue();
      freeliner.oscSetTrails(tval);
    }
  }
}

void oscTick(){
  oscP5.send(tickmsg, toPDpatch);
}
