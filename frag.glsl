#version 130

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform int iterations;
uniform vec3 cam_position;
uniform mat4 cam_direction;
uniform vec3 light_direction;

uniform float screen_ratio;

in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;
in vec4 vertTexCoord;
out vec4 fragColor;

#define PI 3.14159265359
#define MAX_ITER 200
#define MIN_DIST .00001
#define MAX_DIST 500
#define EPS .00002
#define REFLETION_BOUNCES 2

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float truc(float x, float t, float s){
    if(abs(x) < s*.5 && abs(x) <= t) return 0;
    return x > 0 ? s : -s;
}
vec4 IFS(vec3 p, int n){
    p *= 1.5;
    float s = 1.;

    for(int i=0; i<n; i++){
        vec3 ap = abs(p);
        float mid = min(ap.x, min(ap.y, ap.z));
        vec3 boxP = vec3(
            truc(p.x, mid, s),
            truc(p.y, mid, s),
            truc(p.z, mid, s)
        );
        p = p-boxP;
        s *= 0.33333333333333;
    }
    s *= 3;
    vec3 N = round(p/s*(1.001));
    
    return vec4((sdBox(p, vec3(s*.48))-s*.02)/1.5, N);
}

struct PData{
    float D;
    vec3 N;
};
PData map(vec3 P){
    //float sphere = distance(P, light_direction*3.)-.2;
    vec4 menger = IFS(P, iterations);
    //float platform = sdBox(P-vec3(0, -3, 0), vec3(3, .2, 3));
    return PData(menger.x, menger.yzw);
}

struct MData{
    float D;
    float mn;
    vec3 N;
};
MData march(vec3 O, vec3 D){
    float t = 0;
    float mn = MAX_DIST;
    PData d;
    for(int i=0; i<MAX_ITER; i++){
        d = map(O + t*D);
        t += d.D;
        mn = min(mn, d.D);
        if(t > MAX_DIST) break;
        if(d.D < MIN_DIST) break; 
    }
    return MData(t, mn, d.N);
}

float softshadow(in vec3 ro, in vec3 rd, float mint, float maxt, float k ){
    float res = 1.0;
    for( float t=mint; t<maxt; ){
        float h = map(ro + rd*t).D;
        if( h<MIN_DIST ) return 0.0;
        res = min( res, k*h/t );
        t += h;
    }
    return res;
}
float softshadow2( in vec3 ro, in vec3 rd, float mint, float maxt, float k ){
    float res = 1.0;
    float ph = 1e20;
    for( float t=mint; t<maxt; ){
        float h = map(ro + rd*t).D;
        if( h<MIN_DIST ) return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        ph = h;
        t += h;
    }
    return res;
}

vec3 normal(vec3 p){
    const vec2 X = vec2(EPS, 0); 
    return (vec3(
        map(p + X.xyy).D, map(p + X.yxy).D, map(p + X.yyx).D
    )-vec3(map(p).D))/EPS;
}

void main() {
    vec3 color = vec3(0);

    vec2 uv = vertTexCoord.st*2.-vec2(screen_ratio, 1);
    uv.y *= -1;
    vec3 ro = cam_position;
    vec3 rd = (cam_direction * vec4(normalize(vec3(uv.xy, 3)), 1)).xyz;
    //vec3 rd = normalize(vec3(uv.xy, 3));

    //const vec3 SUN = normalize(vec3(1, 3, 1.5));
    vec3 SUN = light_direction;
    const vec3 SUN_COL = vec3(1, .8, .8);

    vec3 color_accumulator = vec3(1);
    for(int B=0; B<REFLETION_BOUNCES; B++){
        MData mp = march(ro, rd);
        vec3 P = ro + rd * mp.D;
        //vec3 N = mp.N; 
        vec3 N = normal(P);
        float sh = softshadow2(P + (MIN_DIST*3.)*N, SUN, 0., 50., 6.);
        
        float diffuse = max(0, dot(N, SUN));
        float specular = pow(clamp(dot(reflect(-SUN, N), -rd), 0, 1), 8.);

        if(mp.D < MAX_DIST){
            // const vec3 COL = vec3(1, .5, .5);
            //const vec3 COL = vec3(.5, .5, 1);
            const vec3 COL = vec3(.5, 1., .5);
            color.rgb += color_accumulator*
                (diffuse+specular)*COL*SUN_COL*sh;
            color_accumulator *= COL*
                mix(.2, .65, 1.-max(0., dot(-rd, N)));
            ro = P+N*(EPS*3);
            rd = reflect(rd, N);
        }else{
            color.rgb += color_accumulator*
                vec3(.3, .3, .5);
            color.rgb += color_accumulator*
                exp(1.-mp.mn*3.)*vec3(1, .5+.5*sin(time), 1)*.4;
            break;
        }
    }

    fragColor = vec4(color, 1);
}