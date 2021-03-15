float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

#define vB 0.42
#define vA (1.-2*vB)

#main
vec4 IFS(vec3 P, int N){
    float S = 1.;

    for(int i=0; i<N; i++){
        P = abs(P);
        if(P.x < P.z) P.xz = P.zx;
        if(P.y < P.z) P.zy = P.yz;
        if(P.x < P.y) P.xy = P.yx;

        if(P.z > .5*vA || P.z > P.y + 3./2.*vA-.5){
            P -= vec3(.5-.5*vB);
            P *= 1/vB;
            S *= vB;
        }else{
            P -= vec3(vec2(.5-.5*vA), 0);
            P *= 1/vA;
            S *= vA;
        }
    }


    float cube = sdBox(P, vec3(.5))*S;

    return vec4(cube, vec3(1, 1, .5));
}