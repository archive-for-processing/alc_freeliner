/**
 *
 * ##copyright##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.1
 * @since     2014-12-01
 */

// subclass for dedicated mouse hacks from architext?

/**
 * Manages the mouse input, the cursor movement and the clicks
 * <p>
 * 
 *
 */
class Mouse{
  // other mouse buttons than LEFT and RIGHT
  final int MIDDLE = 3;
  final int FOURTH_BUTTON = 0;

  // dependecy injection
  GroupManager groupManager;
  Keyboard keyboard;

  boolean mouseEnabled;
  boolean snapping;
  boolean snapped;  
  boolean fixedAngle;
  boolean fixedLength;
  boolean invertMouse;
  boolean grid;
  int lineLenght = 50;
  int gridSize = 64;

  //mouse crosshair stuff
  PVector position;
  PVector mousePos;
  PVector previousPosition;
  PVector mouseOrigin;

/**
 * Constructor, receives references to the groupManager and keyboard instances. This is for operational logic.
 * inits default values
 * @param GroupManager dependency injection
 * @param Keyboard dependency injection
 */

  public Mouse(){

    // init vectors
  	position = new PVector(0, 0);
    mousePos = new PVector(0, 0);
    previousPosition = new PVector(0, 0);
    mouseOrigin = new PVector(0,0);

    // init booleans
    mouseEnabled = true;
    snapping = true;
    snapped = false;
    fixedLength = false;
    fixedAngle = false;
    invertMouse = false;
  }

  public void inject(GroupManager _gm, Keyboard _kb){
    groupManager = _gm;
    keyboard = _kb;
  }

/**
 * Handles mouse button press. Buttons are
 *
 * @param int mouseButton
 */
  public void press(int mb) { // perhaps move to GroupManager
    if (groupManager.isFocused()) {
      if (mb == LEFT || mb == MIDDLE) previousPosition = position.get();
      else if (mb == RIGHT) previousPosition = groupManager.getPreviousPosition();
      groupManager.getSelectedGroup().mouseInput(mb, position);
      if (mb == MIDDLE && fixedLength) previousPosition = mousePos.get();
    }
    else if (mb == FOURTH_BUTTON) groupManager.newItem();
  }

/**
 * Simulate mouse actions!
 *
 * @param int mouseButton
 * @param PVector position
 */
  void fakeMouse(int mb, PVector p) { 
    position = p.get();
    //mousePress(mb);
  }

/**
 * Handles mouse movements
 *
 * @param int X axis (mouseX)
 * @param int Y axis (mouseY)
 */
  public void move(int _x, int _y) {  
    mousePos.set(_x, _y);
    if (mouseEnabled) { 
      if(invertMouse) _x = abs(width - _x); 
      if (grid) position = gridMouse(mousePos, gridSize);
      else if (fixedLength) position = constrainMouse(mousePos, previousPosition, lineLenght);
      else if (keyboard.isCtrled()) position = featherMouse(mousePos, mouseOrigin, 0.2);

      else if (snapping) position = snapMouse(mousePos);
      else position = mousePos.get();
    }
    //gui.resetTimeOut();
  }

/**
 * Handles mouse dragging, currently works with the fixedLength mode to draw curve approximations.
 *
 * @param int mouseButton
 * @param int X axis (mouseX)
 * @param int Y axis (mouseY)
 */
  public void drag(int b, int x, int y) {
    if (fixedLength) {
      move(x, y);
      if (previousPosition.dist(position) < previousPosition.dist(mousePos)) press(b);
    }
  }


/**
 * Scroll wheel input, currently unused, oooooh possibilities :)
 * 
 * @param int positive or negative value depending on direction
 */
  public void wheeled(int n) {
    //println(n);
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Methods to modify the mouse movement
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

/**
 * Snaps to the nearest intersection of a grid
 *
 * @param PVector of mouse position
 * @param int size of grid
 * @return PVector of nearest intersection to position provided
 */  
  public PVector gridMouse(PVector _pos, int _grid){
    return new PVector(round(_pos.x/_grid)*_grid, round(_pos.y/_grid)*_grid);
  }

/**
 * constrain mouse to fixed length and optionaly at an angle of 60deg
 * <p>
 * This is usefull when aproximating curves, all segments will be of same length. 
 * Constraining angle allows to create fun geometry, for VJ like visuals
 *
 * @param PVector of mouse position
 * @param PVector of the previous place clicked
 * @return PVector constrained to length and possibly angle
 */  
  public PVector constrainMouse(PVector _pos, PVector _prev, int _len){
    
    float ang = PVector.sub(_prev, _pos).heading()+PI;
    if (fixedAngle) ang = radians(int(degrees(ang)/30)*30);
    return new PVector((cos(ang)*_len)+_prev.x, (sin(ang)*_len)+_prev.y, 0);
  }

/**
 * Feather mouse for added accuracy, happens when ctrl is held
 *
 * @param PVector of mouse position
 * @param PVector of where the mouse when ctrl was pressed.
 * @return PVector feathered from origin
 */  
  public PVector featherMouse(PVector _pos, PVector _origin, float _sensitivity){
    PVector fthr = PVector.mult(PVector.sub(_pos, _origin), _sensitivity);
    return PVector.add(_origin, fthr);
  }


/**
 * Snap to other vertices! Toggles the snapped boolean
 *
 * @param PVector of mouse position
 * @return PVector of snapped location, or if it did not snap, the position provided
 */  
  public PVector snapMouse(PVector _pos){
    PVector snap_ = groupManager.snap(_pos);
    if(snap_ == _pos) snapped = false;
    else snapped = true;
    return snap_;
  }


/**
 * Move the cursor around with arrow keys, to a greater amount if shift is pressed.
 *
 */  
  private void positionUp() {
    if (keyboard.isShifted()) position.y -= 10;
    else position.y--;
    position.y=position.y%width;
  }

  private void positionDown() {
    if (keyboard.isShifted()) position.y += 10;
    else position.y++;
    if (position.y<0) position.y=height;
  }

  private void positionLeft() {
    if (keyboard.isShifted()) position.x -= 10;
    else position.x--;
    if (position.x<0) position.x=width;
  }

  private void positionRight() {
    if (keyboard.isShifted()) position.x += 10;
    else position.x++;
    position.x=position.x%height;
  }



  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Modifiers
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public void setOrigin(){
    mouseOrigin = mousePos.get();
  }

  public boolean toggleInvertMouse(){
    invertMouse = !invertMouse;
    return invertMouse;
  }

  public boolean toggleFixedLength(){
    fixedLength = !fixedLength;
    return fixedLength;
  }

  public int setLineLenght(int v) {
    lineLenght = numTweaker(v, lineLenght);
    return lineLenght;
  }

  public boolean toggleSnapping(){
    snapping = !snapping;
    return snapping;
  }

  public boolean toggleFixedAngle(){
    fixedAngle = !fixedAngle;
    return fixedAngle;
  }
  //Set the size of grid and generate a PImage of the grid.
  public int setGridSize(int _v) {
    if(_v >= 10 || _v==-1 || _v==-2){
      gridSize = numTweaker(_v, gridSize);
    }
    return gridSize;
  }
  private boolean toggleGrid() {
    grid = !grid;   
    return grid;
  }


  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////     Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public int getGridSize(){
    return gridSize;
  }

  public boolean useGrid(){
    return grid;
  }

  public PVector getPosition(){
    return position;
  }

  public boolean isSnapped(){
    return snapped;
  }

}