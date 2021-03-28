
const mat2 rot60deg = mat2(cos(PI/3), -sin(PI/3), sin(PI/3), cos(PI/3));
const mat2 rotm60deg = mat2(cos(PI/3), sin(PI/3), -sin(PI/3), cos(PI/3));


float sdPolyhedron(vec3 p){
    // if(dot(normalize(p.xz), vec2(1, 0)) < 0.5){
    // if(abs(p.z) > p.x*tan(PI/3)){
    if(abs(p.z) > p.x*1.73205081){
        p.x *= -1;
        p.xz = (p.z > 0 ? rot60deg : rotm60deg) * p.xz;
    }
    // float D = abs(p.y)+0.75593*p.x-1.32287;
    // const float X2 = 0.75593;
    const float X2 = 1.15470053839;
    float D = abs(p.y)+X2*p.x-X2;
    const float X1 = 1/sqrt(1+X2*X2);
    D *= X1;
    return D;
}

// https://www.researchgate.net/publication/262600735_The_Koch_curve_in_three_dimensions
#main vec4 IFS(vec3 p, int n){
    //float s = 1.;
    float s2 = 1.;

    for(int i=0; i<n; i++){
        // reduce the size by 2/3
        const float X1 = 2./3;
        s2 *= X1;
        p /= X1;


        // which part are we in?
        // if(dot(normalize(p.xz), vec2(-1, 0)) < 0.5){
        // if(abs(p.z) > -p.x*tan(PI/3)){
        if(abs(p.z) > -p.x*1.73205081){
            // we are in one of the two rotated parts
            // ...so rotate by 180 degrees
            p.x *= -1;
            // the left or the right one? ...so rotate accordingly...
            p.xz = (p.z > 0 ? rotm60deg : rot60deg) * p.xz;
        }
        // rotate by 90 degrees on the x axis
        p.zy = p.yz;
        // offset the triangle to the side
        p.x += 1.;
    } // repeat...

    // calculate the distance...
    float polyhedron = sdPolyhedron(p)*s2;
    return vec4(polyhedron, vec3(.7, 1, .5));
}