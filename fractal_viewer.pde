import java.util.HashSet;

PShader fract;
//PShader fxaa;
int current_fractal;
String[] all_fractals;

PMatrix3D rotation_mat;

PVector cam_position;
float cam_distance = 8.;
PVector cam_rot = new PVector(-PI*.15, PI*.2);
PVector cam_rot2 = new PVector(0, 0);

PVector light_direction = new PVector();
PVector light_rot = new PVector(PI*.35, -PI*.35);

PVector cut_direction = new PVector();
PVector cut_rot = new PVector(PI/2, 0);
float cut_position = -1.2;

int iterations = 5;
int reflection_bounces = 2;

HashSet keys_pressed = new HashSet<Integer>();

void setup() {
  //size(1920, 1080, P3D);
  size(1300, 1000, P3D);
  frame.setResizable(true);
  //fullScreen(P3D);
  noStroke();
  fill(204);
  //fxaa = loadShader("aliasfrag.glsl", "aliasvert.glsl");
  // fract = loadShader("frag.glsl", "vert.glsl");
  all_fractals = listFileNames(sketchPath()+"/fractals/");
  current_fractal = 0;
  reloadShaders();
    
  rotation_mat = new PMatrix3D();
  rotation_mat.reset();

  cam_position = new PVector(0, 0, -8);
}

void reloadShaders(){
  fract = new PShader(this,
    load_vertex_shader(),
    load_fragment_shader(all_fractals[current_fractal])
  );
  fract.set("screen_ratio", (float)width/height);
  fract.set("iterations", iterations);
  fract.set("reflection_bounces", reflection_bounces);
  fract.set("cut_position", cut_position);
}

void mouseDragged(){
  if (keyPressed && (key == 'l' || key == 'L')){
    light_rot.y += (mouseX-pmouseX)*-.003; 
    light_rot.x += (mouseY-pmouseY)*-.003;  
    light_rot.x = constrain(light_rot.x, -PI/2, PI/2);
  }else if(keyPressed && (key == 'R' || key == 'r')){
    cam_rot2.y += (mouseX-pmouseX)*-.003; 
    cam_rot2.x += (mouseY-pmouseY)*-.003;  
    cam_rot2.x = constrain(cam_rot2.x, -PI/2, PI/2);
  }else if(keyPressed && (key == 'P' || key == 'p')){
    cut_rot.y += (mouseX-pmouseX)*-.003; 
    cut_rot.x += (mouseY-pmouseY)*-.003;  
    cut_rot.x = constrain(cut_rot.x, -PI/2, PI/2);
  }else{
    cam_rot.y += (mouseX-pmouseX)*-.003; 
    cam_rot.x += (mouseY-pmouseY)*-.003;  
    cam_rot.x = constrain(cam_rot.x, -PI/2, PI/2);
  }
}
void mouseWheel(MouseEvent event) {
  if (keys_pressed.contains((int)'i')){
    iterations += event.getCount();
    fract.set("iterations", iterations);
  }else if(keys_pressed.contains((int)'r')){
    reflection_bounces += event.getCount();
    fract.set("reflection_bounces", reflection_bounces);
  }else if(keys_pressed.contains((int)'p')){
    cut_position -= event.getCount()* (keys_pressed.contains(SHIFT) ? .05 : .005);
    fract.set("cut_position", cut_position);
  }else{
    cam_distance *= pow(2., event.getCount()*(keys_pressed.contains(SHIFT) ? .003 : .3));
  }
}
void keyPressed(){
  Integer key = keyCode >= 'A' && keyCode <= 'Z' ? keyCode+32 : keyCode;
  keys_pressed.add(key);

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
void keyReleased() {
  Integer key = keyCode >= 'A' && keyCode <= 'Z' ? keyCode+32 : keyCode;
  keys_pressed.remove(key);
}

void draw() {
  rotation_mat.reset();
  rotation_mat.rotateX(cam_rot.x+cam_rot2.x);
  rotation_mat.rotateY(cam_rot.y+cam_rot2.y);
  fract.set("cam_direction", rotation_mat);
  
  cam_position.set(0, 0, -cam_distance-1.5);
  rotation_mat.reset();
  rotation_mat.rotateX(cam_rot.x);
  rotation_mat.rotateY(cam_rot.y);
  rotation_mat.invert();
  rotation_mat.mult(cam_position, cam_position);
  fract.set("cam_position", cam_position);
  
  light_direction.set(0, 0, -1);
  rotation_mat.reset();
  rotation_mat.rotateY(light_rot.y);
  rotation_mat.rotateX(light_rot.x);
  rotation_mat.mult(light_direction, light_direction);
  fract.set("light_direction", light_direction);

  cut_direction.set(0, 0, -1);
  rotation_mat.reset();
  rotation_mat.rotateY(cut_rot.y);
  rotation_mat.rotateX(-cut_rot.x);
  rotation_mat.mult(cut_direction, cut_direction);
  fract.set("cut_direction", cut_direction);
  fract.set("cut_position", cut_position);
  
  fract.set("time", (float)millis()/1000.);
  
  shader(fract);
  background(0);
  quad(0, 0, width, 0, width, height, 0, height);
  //filter(fxaa);
}
