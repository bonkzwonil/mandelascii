# Realtime ascii mandelbrot zoomer in Common Lisp (sbcl)

## Usage
start.sh [startpoint] [iter] [threads]

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
This increases the speed by factor 10.
Another factor of 10 is achieved by parralel rendering with 10 Threads (on hardware with cores>=10)

## TODO
Cuarrent Multiprocessing is starting n Threads per frame and joining them, which is working surprisingly good in sbcl, but could maybe be optimized longer lifecycle workers.

## GFX
create a video with mencoder like this:
(make-video)
