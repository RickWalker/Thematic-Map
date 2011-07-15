import geomerative.*;

RShape mapShape;
PImage backgroundMap;
Set<String> countriesInEurope;

ProgramState currentState = ProgramState.WHOLEMAP;
String zoomedCountry = "";
RShape zoomedCountryShape;
Integrator offsetX, offsetY, countryScale, mapAlpha;
color waterColour = color(#B3E6EF);

void setup() {
  smooth();
  size(940, 477);
  countriesInEurope = new HashSet<String>(Arrays.asList(new String[] 
{"BE",
"BY",
"BG",
"CZ",
"DK",
"DE",
"EE",
"IE",
"GR",
"ES",
"FR",
"IT",
"CY",
"LV",
"LT",
"LU",
"HU",
"MT",
"NL",
"AT",
"PL",
"PT",
"RO",
"SI",
"SK",
"FI",
"SE",
"GB", "UA", "NO"}));
  backgroundMap = loadImage("coloured_map.png");
  RG.init(this);

  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(0.5);

  mapShape = RG.loadShape("coloured_world_map.svg");
  float newscale = min(width/mapShape.getWidth(), height/mapShape.getHeight());
  mapShape.scale(newscale, mapShape.getCenter()); 
  mapShape.translate(-mapShape.getTopLeft().x, -mapShape.getTopLeft().y); //move to top left for positioning
  //now we want to zoom to the bit we want, which is lat 75 to 30, lon -40 to 30
  println("Center is " + mapShape.getCenter().x);
  //mapShape.translate(
  float xtrans = map(-40, -180, 180, 0, mapShape.getWidth());
  float ytrans = map(75, 90, -90, 0, mapShape.getHeight());
  mapShape.translate(-xtrans,-ytrans);
  float newxscale = 360/70.0;
  float newyscale = 180/45.0;
  //println("Center is " + mapShape.getCenter().x);
  mapShape.scale(newxscale, newyscale, 0, 0); //mapShape.getCenter() );


  //mapShape = RG.polygonize(mapShape);
  
  offsetX = new Integrator(0);
  offsetY = new Integrator(0);
  countryScale = new Integrator(1.0);
  mapAlpha = new Integrator(1.0);
  frameRate(25);
}

void draw() {
  //background(#B3E6EF);
  strokeWeight(1);
  offsetX.update();
  offsetY.update();
  countryScale.update();
  mapAlpha.update();
  
  checkState(); //see if we're done with transitions!
  
  image(backgroundMap, 0, 0, width, height);
  //println(mapAlpha.value);
  //noFill();
  //RG.shape(mapShape);
  fill(color(#B3E6EF, mapAlpha.value));
  rect(1, 1, width-2, height-2);
  
  switch(currentState){
    case WHOLEMAP:
      noFill();
      drawHighlight();
      break;
    case ZOOMING_IN:
    case ZOOMING_OUT:
    case ZOOMED:
      //transform shape!
      RShape temp = new RShape(zoomedCountryShape);
      temp.scale(countryScale.value, zoomedCountryShape.getCenter());
      temp.translate(offsetX.value, offsetY.value);
      strokeWeight(2);
      fill(#C0C1C5);
      RG.shape(temp);   
  }
  //saveFrame();
}

void checkState(){
  //println(floor(offset_x.value) +", " + floor(offset_y.value));
  switch(currentState){
    case ZOOMING_OUT:
      if(abs(offsetX.value) <= 0.25 && abs(offsetY.value)<=0.25)
        currentState = ProgramState.WHOLEMAP;
      break;
    case ZOOMING_IN:
      if (abs(offsetX.target - offsetX.value) <=1 && abs(offsetY.target - offsetY.value) <=1)
        currentState = ProgramState.ZOOMED;
      break;
  }
}

void drawHighlight() {
  //find the child we're over!
  //println(mapShape.children.length);
  for(String a: countriesInEurope){
    RShape toCheck = mapShape.getChild(a.toLowerCase());
    if(toCheck != null){
      if(toCheck.contains(mouseX, mouseY)){
        //fill(#C0C1C5);
        RG.ignoreStyles(true);
        strokeWeight(4);
        stroke(80);

        zoomedCountry = a;
        RG.shape(toCheck);
        RG.ignoreStyles(false);
      }
    }
  }
}

void mouseClicked(){
  //if(mouseEvent.getClickCount() == 2){
    //zoom in or out!
    switch(currentState){
      case WHOLEMAP:
        //do zoom!

        //get name of country we're over
        println("Zooming on " + zoomedCountry);
        zoomedCountryShape = new RShape(mapShape.getChild(zoomedCountry.toLowerCase())); //no permanent changes!
        println(zoomedCountryShape.getWidth() + " and height " + zoomedCountryShape.getHeight());
        float myscale = min (width/zoomedCountryShape.getWidth(), height/zoomedCountryShape.getHeight());
        //what's its current scale? 1.0?
        countryScale.set(1.0);
        countryScale.target(myscale);
        offsetX.set(0);
        offsetY.set(0);         
        offsetX.target(width/2 - zoomedCountryShape.getCenter().x);
        offsetY.target(height/2 - zoomedCountryShape.getCenter().y);
        mapAlpha.target(150.0);
        currentState = ProgramState.ZOOMING_IN;
        break;
      case ZOOMED:
      case ZOOMING_IN:
      case ZOOMING_OUT:
        //zoom out!
        //go the other way!
        mapAlpha.target(1.0);
        countryScale.target(1.0);
        //offsetX.set(offsetX.value);
        //offsetY.set(offset_y.value);
        offsetX.target(0);
        offsetY.target(0);
        currentState = ProgramState.ZOOMING_OUT;
    }
  //}
}
