PShader fract;
//PShader fxaa;
int current_fractal;
String[] all_fractals;

PVector cam_position;
PMatrix3D cam_rotation;
float cam_distance = 8.;
float rotX = -PI*.15;
float rotY = PI*.2;
float rot2X = 0;
float rot2Y = 0;

PVector light_direction = new PVector();
float light_rotX = PI*.35;
float light_rotY = -PI*.35;

int iterations = 5;
int reflection_bounces = 2;

void setup() {
  //size(1920, 1080, P3D);
  size(1300, 1000, P3D);
  //fullScreen(P3D);
  noStroke();
  fill(204);
  //fxaa = loadShader("aliasfrag.glsl", "aliasvert.glsl");
  // fract = loadShader("frag.glsl", "vert.glsl");
  all_fractals = listFileNames(sketchPath()+"/fractals/");
  current_fractal = 0;
  reloadShaders();
    
  cam_position = new PVector(0, 0, -8);
  cam_rotation = new PMatrix3D();
  cam_rotation.reset();
}

void reloadShaders(){
  fract = new PShader(this,
    load_vertex_shader(),
    load_fragment_shader(all_fractals[current_fractal])
  );
  fract.set("screen_ratio", (float)width/height);
}

void mouseDragged(){
  if (keyPressed && (key == 'l' || key == 'L')){
   light_rotY += (mouseX-pmouseX)*-.003; 
   light_rotX += (mouseY-pmouseY)*-.003;  
  }else if(keyPressed && (key == 'R' || key == 'r')){
    rot2Y += (mouseX-pmouseX)*-.003; 
    rot2X += (mouseY-pmouseY)*-.003;  
  }else{
   rotY += (mouseX-pmouseX)*-.003; 
   rotX += (mouseY-pmouseY)*-.003;  
  }
}
void mouseWheel(MouseEvent event) {
  if (keyPressed && (key == 'i' || key == 'I')){
    iterations += event.getCount();
  }else if(keyPressed && (key == 'r' || key == 'R')){
    reflection_bounces += event.getCount();
  }else{
    cam_distance *= pow(2., event.getCount());
  }
}
void keyPressed(){
  if(keyCode == 'S' || keyCode=='s'){
    reloadShaders();
  }else if(keyCode == 'C' || keyCode=='c'){
    print("taking screenshot");
    saveFrame("screenshots/screen-"+random(1000000000000L)+".png");
  }else if(keyCode == RIGHT || keyCode == LEFT){
    current_fractal += keyCode == RIGHT ? 1 : -1;
    if(current_fractal < 0) current_fractal += all_fractals.length;
    current_fractal %= all_fractals.length;
    reloadShaders();
  }
}

void draw() {
  cam_rotation.reset();
  cam_rotation.rotateX(rotX+rot2X);
  cam_rotation.rotateY(rotY+rot2Y);
  fract.set("cam_direction", cam_rotation);
  
  cam_position.set(0, 0, -cam_distance-1.5);
  cam_rotation.reset();
  cam_rotation.rotateX(rotX);
  cam_rotation.rotateY(rotY);
  cam_rotation.invert();
  cam_position = cam_rotation.mult(cam_position, null);
  fract.set("cam_position", cam_position);
  
  light_direction.set(0, 0, -1);
  cam_rotation.reset();
  cam_rotation.rotateY(light_rotY);
  cam_rotation.rotateX(light_rotX);
  light_direction = cam_rotation.mult(light_direction, null);
  
  fract.set("light_direction", light_direction);
  
  //fract.set("iterations", 5+int(1/cam_distance));
  fract.set("iterations", iterations);
  fract.set("reflection_bounces", reflection_bounces);
  fract.set("time", (float)millis()/1000.);
  
  shader(fract);
  background(0);
  quad(0, 0, width, 0, width, height, 0, height);
  //filter(fxaa);
}
