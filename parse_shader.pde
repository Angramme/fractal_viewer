

String[] load_vertex_shader(){
    return loadStrings("vert.glsl");
}
String[] load_fragment_shader(String name){
    print("reloading shaders...");
    
    String fractal = join(loadStrings("fractals/"+name), "\n");
    String[] base = loadStrings("frag.glsl");
    
    String fractalSDF_name = match(fractal, "#main\\s+\\S+\\s+([a-zA-Z0-9]+)")[1];
    fractal = process_fractal_functions(fractal);

    String[] out = new String[base.length];
    int out_line = 0;

    for(int i=0; i<base.length; i++){
        if(match(base[i], "#fractalSDF_definition") != null){
            out[out_line] = fractal;
            out_line++;
        }else if(match(base[i], "#fractalSDF_name") != null){
            String[] thing = split(base[i], "#fractalSDF_name");
            out[out_line] = thing[0] + fractalSDF_name + thing[1];
            out_line++;
        }else{
            out[out_line] = base[i];
            out_line++;
        }
    }

    return out;
}
String process_fractal_functions(String original){
    // also add parameters etc
    return join(split(original, "#main"), "");
}
