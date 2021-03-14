# Fractal Viewer!

This simple renderer uses GLSL accelerated Ray Marching and a host program written in the Processing language to display fractals.

It can render any fractal which can be defined with a signed function distance (SDF). 

Right now only some fractals defined with IFS are present.

# Gallery

## Menger Sponge

![menger1](/img/menger1.jpeg)
![menger2](/img/menger2.png)
![menger3](/img/menger3.jpeg)
![menger4](/img/menger4.jpeg)

## Koch Curve

![koch1](/img/koch1.png)
![koch2](/img/koch2.png)
![koch3](/img/koch3.png)

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

## Experiment on your own

If you run the code with the Processing environnement, you can modify the shader to change the color and other attributes. Hit the S button on your keyboard once the program is running to reload the shader.

You can also add your own fractals just by adding another file inside teh fractals folder.
