uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;
uniform mat4 texMatrix;
uniform float screen_ratio;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertTexCoord;


void main() {
  gl_Position = transform * position;
  vertColor = color;
  vertNormal = normalize(normalMatrix * normal);
  vertLightDir = -lightNormal;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
  vertTexCoord.x *= screen_ratio;
  // vertTexCoord = texMatrix* vec4(texCoord*vec2(screen_size.x/screen_size.y, 1.), 1.0, 1.0);
//   vertTexCoord = texCoord;
}