# l-systems
Program to render fractal image from formal language

# Examples

## Fern
```racket
(define fern
  (hash 'word "G"
        'turn (* pi 5/36)
        'backtrack-turn 0
        'rotation (* (- pi) 1/3)
        'productions '((#\G "F+[[G]-G]-F[-FG]+G")
                       (#\F "FF"))))

(render fern 5)
```
![img](img/fern.png)


## Dragon fractal
```racket
(define dragon
  (hash 'word "F"
        'turn (/ pi 2)
        'backtrack-turn 0
        'rotation 0
        'productions '((#\F "F+G") 
                      (#\G "F-G"))))

(render dragon 8)
```
![img](img/dragon.png)

## Sierpinski triangle
```racket
(define sierpinski
  (hash 'word "F-G-G"
        'turn (* pi 2/3)
        'backtrack-turn 0
        'rotation pi
        'productions '((#\F "F-G+F+G-F")
                       (#\G "GG"))))

(render sierpinski 5)
```
![img](img/sierpinski.png)

## Binary tree
```racket
(define binary-tree
  (hash 'word "F"
        'turn 0
        'backtrack-turn (/ pi 3)
        'rotation (/ (- pi) 2)
        'productions '((#\F "G[F]F")
                       (#\G "GG"))))

(render binary-tree 6)
```
![img](img/tree.png)










