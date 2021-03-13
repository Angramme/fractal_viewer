
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float truc(float x, float t, float s){
    if(abs(x) < s*.5 && abs(x) <= t) return 0;
    return x > 0 ? s : -s;
}

#main vec4 IFS(vec3 p, int n){
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
    // vec3 N = round(p/s*(1.001));
    
    return vec4(
        // (sdBox(p, vec3(s*.48))-s*.02)/1.5, //distance
        (sdBox(p, vec3(s)))/1.5, //distance
        vec3(.5, 1, .5)); //color
}