#version 130

uniform mat4 transform;
in vec4 vertex;
in vec2 texCoord;
out vec2 vertTexCoord;
void main() {
   vertTexCoord = vec2(0, 1)+texCoord*vec2(1, -1);
   gl_Position = transform * vertex;
}