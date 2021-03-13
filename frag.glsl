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
uniform int reflection_bounces;

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

//this is going to paste in the fractal distance function
#fractalSDF_definition

struct PData{
    float D;
    vec3 COL;
};
PData map(vec3 P){
    // vec4 fractal = IFS(P, iterations);
    vec4 fractal = #fractalSDF_name(P, iterations);


    return PData(fractal.x, fractal.yzw);
}

struct MData{
    float D;
    float mn;
    vec3 COL;
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
    return MData(t, mn, d.COL);
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
    for(int B=0; B<reflection_bounces; B++){
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
            //const vec3 COL = vec3(.5, 1., .5);
            color.rgb += color_accumulator*
                (diffuse+specular)*mp.COL*SUN_COL*sh;
            color_accumulator *= mp.COL*
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