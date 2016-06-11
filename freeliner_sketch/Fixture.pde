/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-06-10
 */

// DMX fixture objects


class Fixture {
  String name;
  String description;
  int address;
  int channelCount;
  byte[] buffer;
  // position on the canvas;
  PVector position;
  public Fixture(int _adr){
    name = "genericFixture";
    description = "describe fixture";
    address = _adr;
    channelCount = 3;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }

  // to override
  public void parseGraphics(PGraphics _pg){

  }

  // to override
  void drawFixtureOverlay(PGraphics _pg){

  }

  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      _buff[address+i] = buffer[i];
      // println(address+i+" -> "+int(buffer[i]));
    }
  }

  void setPosition(int _x, int _y){
    position.set(_x, _y);
  }

  int getAddress(){
    return address;
  }

  PVector getPosition(){
    return position.get();
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     Mpanel
///////
////////////////////////////////////////////////////////////////////////////////////

// class for RGB ledStrips
class MPanel extends Fixture{
  ArrayList<Fixture> subFixtures;
  final int PAN_CHANNEL = 0;
  final int TILT_CHANNEL = 2;
  final int MPANEL_SIZE = 128;

  public MPanel(int _adr, int _x, int _y){
    super(_adr);
    name = "MPanel";
    description = "Neto's crazy MPanel fixture";
    channelCount = 121;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(_x, _y);
    subFixtures = new ArrayList<Fixture>();
    addMatrix();
  }

  private void addMatrix(){
    RGBWStrip _fix;
    int _gap = MPANEL_SIZE/5;
    int _adr = 0;
    for(int i = 0; i < 5; i++){
      _adr = address+20+(i*20);
      _fix = new RGBWStrip(_adr, 5, int(position.x), int(position.y+(i*_gap)), int(position.x)+MPANEL_SIZE, int(position.y+(i*_gap)));
      subFixtures.add(_fix);
    }
  }

  public void parseGraphics(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.parseGraphics(_pg);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    for(Fixture _fix : subFixtures)
      _fix.drawFixtureOverlay(_pg);
  }

  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      _buff[address+i] = buffer[i];
    }
    mpanelRules();
    for(Fixture _fix : subFixtures)
      _fix.bufferChannels(_buff);
  }

  public void mpanelRules(){
    buffer[0] = byte(map(mouseX, 0, width, 0, 255));
    buffer[2] = byte(map(mouseY, 0, height, 0, 255));

    buffer[1] = byte(127);
    buffer[15] = byte(255);
    // buffer[19] = byte(255);

    // buffer[118] = byte(255);
    //
    // buffer[118] = byte(255);
    // buffer[119] = byte(255);


  }
}


////////////////////////////////////////////////////////////////////////////////////
///////
///////     Strip
///////
////////////////////////////////////////////////////////////////////////////////////
// class for RGB ledStrips
class RGBWStrip extends RGBStrip{

  public RGBWStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by){
    super(_adr, _cnt, _ax, _ay, _bx, _by);
    name = "RGBWStrip";
    description = "A series of RGBFixtures";
    ledCount = _cnt;
    ledChannels = 4;
    channelCount = ledCount * ledChannels;
    buffer = new byte[channelCount];
    position = new PVector(_ax, _ay);

    subFixtures = new ArrayList<RGBFixture>();
    addRGBFixtures(ledCount, _ax, _ay, _bx, _by);
  }
}

// class for RGB ledStrips
class RGBStrip extends Fixture{
  ArrayList<RGBFixture> subFixtures;
  int ledCount;
  int ledChannels;

  public RGBStrip(int _adr, int _cnt, int _ax, int _ay, int _bx, int _by){
    super(_adr);
    name = "RGBStrip";
    description = "A series of RGBFixtures";
    ledCount = _cnt;
    ledChannels = 3;
    channelCount = ledCount * ledChannels;
    buffer = new byte[channelCount];
    position = new PVector(_ax, _ay);

    subFixtures = new ArrayList<RGBFixture>();
    addRGBFixtures(ledCount, _ax, _ay, _bx, _by);
  }

  protected void addRGBFixtures(int _cnt, float _ax, float _ay, float _bx, float _by){
    float gap = 1.0/_cnt;
    int ind;
    int x;
    int y;
    // if(from == to) leds.add(new RGBled(from, int(_ax), int(_ay)));
    // else {
    RGBFixture _fix;
    for(int i = 0; i < _cnt; i++){
      ind = int(lerp(0, _cnt, i*gap));
      x = int(lerp(_ax, _bx, i*gap));
      y = int(lerp(_ay, _by, i*gap));
      _fix = new RGBFixture(address+(i*ledChannels));
      _fix.setPosition(x,y);
      subFixtures.add(_fix);
    }
    // }
  }

  public void parseGraphics(PGraphics _pg){
    for(RGBFixture _fix : subFixtures)
      _fix.parseGraphics(_pg);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    for(RGBFixture _fix : subFixtures)
      _fix.drawFixtureOverlay(_pg);
  }

  public void bufferChannels(byte[] _buff){
    for(RGBFixture _fix : subFixtures)
      _fix.bufferChannels(_buff);
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////
///////     RGBFixture
///////
////////////////////////////////////////////////////////////////////////////////////

// a base class for RGB fixture.
class RGBFixture extends Fixture {
  boolean correctGamma = true;
  color col;
  public RGBFixture(int _adr){
    super(_adr);
    name = "RGBFixture";
    description = "a RGB light fixture";
    channelCount = 3;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }

  // override
  public void parseGraphics(PGraphics _pg){
    int ind = int(position.x + (position.y*width));
    int max = _pg.width*_pg.height;
    if(ind < max) setColor(_pg.pixels[ind]);
  }

  // override
  void drawFixtureOverlay(PGraphics _pg){
    _pg.stroke(255, 100);
    _pg.noFill();
    _pg.ellipseMode(CENTER);
    _pg.ellipse(position.x, position.y, 10, 10);
    _pg.textSize(10);
    _pg.fill(255);
    _pg.text(str(address), position.x, position.y);
  }

  // RGBFixture specific
  public void setColor(color _c){
    col = _c;
    // buffer[0] = byte((col >> 16) & 0xFF);
    // buffer[1] = byte((col >> 8) & 0xFF);
    // buffer[2] = byte(col & 0xFF);
    int red = (col >> 16) & 0xFF;
    int green = (col >> 8) & 0xFF;
    int blue = col & 0xFF;
    buffer[0] = byte(correctGamma ? red : gammatable[red]);
    buffer[1] = byte(correctGamma ? green : gammatable[green]);
    buffer[2] = byte(correctGamma ? blue : gammatable[blue]);
    // println(buffer[0]+" "+buffer[1]+" "+buffer[2]);
  }

  public color getColor(){
    return col;
  }

  public int getX(){
    return int(position.x);
  }
  public int getY(){
    return int(position.y);
  }
}

// for other light channels
class ColorFlexWAUV extends RGBFixture{
  public ColorFlexWAUV(int _adr){
    super(_adr);
    name = "ColorFlexUVW";
    description = "fixture for uv and whites for Neto ColorFlex";
    channelCount = 3;
    address = _adr;
    buffer = new byte[channelCount];
    position = new PVector(0,0);
  }
  public void bufferChannels(byte[] _buff){
    for(int i = 0; i < channelCount; i++){
      _buff[address+i+3] = buffer[i];
      // println(address+i+" -> "+int(buffer[i]));
    }
  }
}
