# Fractal Viewer!

> This is a prototype! A version written in Rust using gfx-rs along with compute shaders for better performance is eventually planned.

This simple renderer uses GLSL accelerated Ray Marching and a host program written in the Processing language to display fractals.

It can render any fractal which can be defined with a signed distance function (SDF). 

Right now only some fractals defined with IFS are present by default.

## Running the program

Install Processing if you haven't already and run the program as any other Processing sketch. 

You can also download the prebuilt binaries located in releases.

## Controls

| key sequence | action  |
--- | ---
| right/left arrow | switch between fractals |
| drag mouse | rotate the fractal |
| drag mouse + L | change the light direction |
| drag mouse + R | rotate the camera |
| drag mouse + P | change the orientation of the cut plane |
| scroll | zoom in and out |
| scroll + shift | zoom in and out (slower) |
| scroll + I | change the number of iterations |
| scroll + R | change the number of reflection bounces |
| scroll + P | change the position of the cut plane |
| scroll + P + shift | change the position of the cut plane (slower) |
| S | reload shader |
| C | save screenshot |

# Gallery

## Menger Sponge

![menger1](/img/menger1.png)
![menger2](/img/menger2.png)
![menger5](/img/menger5.png)
![menger4](/img/menger4.jpeg)

## Koch Curve

![koch4](/img/koch4.png)
![koch1](/img/koch1.png)
![koch2](/img/koch2.png)

## Jerusalem Cube

![jerusalem1](/img/jerusalem1.png)
![jerusalem2](/img/jerusalem2.png)
![jerusalem3](/img/jerusalem3.png)
![jerusalem4](/img/jerusalem4.png)

## Experiment on your own

You can modify the shader to change the color and other attributes. Hit the S button on your keyboard once the program is running to reload the shader.

You can also add your own fractals just by adding another file inside the fractals folder.

