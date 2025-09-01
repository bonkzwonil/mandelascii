# Realtime ascii mandelbrot zoomer in Common Lisp (sbcl)
``
.............../////////////////////..............
...........///////////////////0/////////..........
........//////////////////////0010/////////.......
......///////////////////////119300//////////.....
....////////////////////////00   300///////////...
...////////////////////0; 1^        10311///////..
..////////////////////01              40/////////.
.///////////000010//00=                 40////////
.///////////01 4   603                  3/////////
./////////600                           0/////////
.                     asciimandel!    10//////////
./////////600                           0/////////
.///////////01 4   603                  3/////////
.///////////000010//00=                 40////////
..////////////////////01              40/////////.
...////////////////////0; 1^        10311///////..
....////////////////////////00   300///////////...
......///////////////////////119300//////////.....
........//////////////////////0010/////////.......
...........///////////////////0/////////..........
``

## Usage
start.sh [startpoint] [iter] [threads]

This compiles and starts the ascii zoomer

- startpoint -  a startpoint from the list of nice locations (below), or `list` for a list
- iter       -  max iterations (Default 1000)
- threads    -  number of Threads. (Default 10)


## nice Startpoints

- spirals
- trunks
- starfish
- julia
- flower
- home
- seahorse
- sun
- tendrils

## Optimizations
Some optimized algorithm, with a lot of `(declares)` .
core calc loop is with double-precision floats instead of complex's.
This increases the speed by factor ~20.
Another factor of 10 is achieved by parallel rendering with 10 Threads (on hardware with cores>=10)

## TODO
Current Multiprocessing is starting n Threads per frame and joining them, which is working surprisingly good in sbcl, but could maybe be optimized longer lifecycle workers.

## GFX
create a video with mencoder like this:
`(make-movie-mp)`
This creates images of form: image0000.png.

Rendering will stop as soon as there is only one color in the whole image or after 8000 frames.
### Encode
`mencoder mf://image*.png -mf fps=25 -ovc x264 -oac copy -o output.avi`


# 
