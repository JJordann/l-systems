(require opengl)
(require opengl/util)
(require racket/draw)
(require racket/block)




(define (indexOf ele lst) 
  (let loop ((lst lst)
             (i 0))
  (cond ((empty? lst) #f)
        ((equal? (first lst) ele) i)
        (else (loop (rest lst) (add1 i))))))



(define (flattenProductions state)
  (let ([p (hash-ref state 'productions)])
    (map car p))) 



(define (produce state c)
  (let ([i (indexOf c (flattenProductions state))])
    (cond ((equal? i #f) (string c))
          (else (last (list-ref (hash-ref state 'productions) i))))))



(define (expandOnce state)
    (hash-set state 'word 
      (string-append* 
        (map (lambda (c) (produce state c))
           (string->list (hash-ref state 'word))))))



(define (expand-n state n)
  (cond ((equal? n 0) state)
        (else (expand-n (expandOnce state) (- n 1)))))



(define (handleF turtle) 
  (let* ([pace (hash-ref turtle 'pace)]
         [dir (hash-ref turtle 'dir)]
         [mx (+ (hash-ref turtle 'x) (* pace (cos dir)))] 
         [my (+ (hash-ref turtle 'y) (* pace (sin dir)))])
    (hash-set* turtle
               'x mx
               'y my
               'trail (cons (list mx my #f) (hash-ref turtle 'trail)) )))


(define handleG handleF)


(define (handle+ turtle)
  (hash-set* turtle 
             'dir (- (hash-ref turtle 'dir) 
                     (hash-ref turtle 'turn))))


(define (handle- turtle)
  (hash-set* turtle 
             'dir (+ (hash-ref turtle 'dir) 
                     (hash-ref turtle 'turn))))


; memorize state
(define (handleM turtle)
  (let ([pos (list (hash-ref turtle 'x) 
                   (hash-ref turtle 'y) 
                   (hash-ref turtle 'dir))])
      (hash-set* turtle
                 'dir (+ (hash-ref turtle 'dir) 
                         (hash-ref turtle 'backtrack-turn))
                 'backtrack (cons pos 
                                  (hash-ref turtle 'backtrack)))))


; backtrack
(define (handleB turtle)
  (match-let* ([(list x xs ...) (hash-ref turtle 'backtrack)]
              [new-dir (- (third x) (hash-ref turtle 'backtrack-turn))])
     (hash-set* turtle
                'backtrack xs 
                'dir new-dir
                'x (first x)
                'y (second x)
                'trail (cons (list (first x) (second x) #t) 
                             (hash-ref turtle 'trail)))))
    


(define (step turtle command)
  (match command
         [#\F (handleF turtle)]
         [#\G (handleG turtle)]
         [#\+ (handle+ turtle)]
         [#\- (handle- turtle)]
         [#\[ (handleM turtle)]
         [#\] (handleB turtle)]))



(define (compute-path state steps)
  (let* ([expanded (expand-n state steps)]
        [commands (string->list (hash-ref expanded 'word))]
        [turtle (hash 'x 0 'y 0 
                    'dir (hash-ref state 'rotation)
                    'pace 12
                    'turn (hash-ref state 'turn)
                    'backtrack-turn (hash-ref state 'backtrack-turn)
                    'backtrack '()
                    'trail (list (list 0 0 0 #t)))]
        [endState (foldl (lambda (c turtle) (step turtle c)) turtle commands)])
    (hash-ref endState 'trail)))




(define (find-bounds path)
  (let ([x-low (first (argmin first path))]
        [x-high (first (argmax first path))]
        [y-low (second (argmin second path))]
        [y-high (second (argmax second path))]) 
    (list x-low y-low x-high y-high)))



(define (fit-image path)
  (match-let* 
    ([(list xmin ymin xmax ymax) (find-bounds path)]
     [padding (/ (- xmax xmin) 20)]) 
    (hash 'width  (+ (- xmax xmin) (* 2 padding))
          'height (+ (- ymax ymin) (* 2 padding))
          'path (map (lambda (t) 
                       (list (+ padding (- (first t) xmin)) 
                             (+ padding (- (second t) ymin))
                             (third t))) path))))



(define (draw-path path dc target)
  (match-let* 
    ([(list x xs ...) path])
      (block
        (cond [(false? (third x)) (send dc draw-line (first x) (second x) 
              (first (first xs)) (second (first xs)))] )
        (cond
          [(> (length xs) 1)  (draw-path xs dc target)] 
          [else (send target save-file "img.png" 'png)]))))



(define (render rules iters)
  (let* ([path (compute-path rules iters)]
         [translated (fit-image path)]
         [img-width (exact-ceiling (hash-ref translated 'width))]
         [img-height (exact-ceiling (hash-ref translated 'height))]
         [path (hash-ref translated 'path)]) 
    (block
      (define target (make-bitmap img-width img-height))
      (define dc (new bitmap-dc% [bitmap target]))
      (send dc set-pen "green" 1 'solid)
      (draw-path path dc target))))





; --- examples --- ;


(define sierpinski
  (hash 'word "F-G-G"
        'turn (* pi 2/3)
        'backtrack-turn 0
        'rotation pi
        'productions '((#\F "F-G+F+G-F")
                       (#\G "GG"))))

; (render sierpinski 5)



(define binary-tree
  (hash 'word "F"
        'turn 0
        'backtrack-turn (/ pi 3)
        'rotation (/ (- pi) 2)
        'productions '((#\F "G[F]F")
                       (#\G "GG"))))

; (render binary-tree 6)



(define fern
  (hash 'word "G"
        'turn (* pi 5/36)
        'backtrack-turn 0
        'rotation (* (- pi) 1/3)
        'productions '((#\G "F+[[G]-G]-F[-FG]+G")
                       (#\F "FF"))))

; (render fern 5)



(define dragon
  (hash 'word "F"
        'turn (/ pi 2)
        'backtrack-turn 0
        'rotation 0
        'productions '((#\F "F+G") 
                      (#\G "F-G"))))

; (render dragon 8)








