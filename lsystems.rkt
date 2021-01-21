(require opengl)
(require opengl/util)
(require racket/draw)
(require racket/block)


(define state 
  (hash 'word "A"
        'productions '((#\A "AB") 
                      (#\B "A"))))
                

(define sierpinski
  (hash 'word "F-G-G"
        'productions '((#\F "F-G+F+G-F")
                       (#\G "GG"))))


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


(define h 768)
(define w 768)

(define target (make-bitmap w h))
(define dc (new bitmap-dc% [bitmap target]))
(send dc set-pen "gray" 1 'solid)


; get value:    (hash-ref t 'x)
; change value: (hash-set t 'x 100)




; calculate next position 
(define (handleF turtle) 
  (let* ([pace (hash-ref turtle 'pace)]
         [dir (hash-ref turtle 'dir)]
         [mx (+ (hash-ref turtle 'x) (* pace (cos dir)))] 
         [my (+ (hash-ref turtle 'y) (* pace (sin dir)))])
    (hash-set* turtle
               'x mx
               'y my
               'trail (cons (list mx my) (hash-ref turtle 'trail)) )))


(define handleG handleF)


(define (handle+ turtle)
  (hash-set* turtle 
             'dir (+ (hash-ref turtle 'dir) (* pi 2/3))))


(define (handle- turtle)
  (hash-set* turtle 
             'dir (- (hash-ref turtle 'dir) (* pi 2/3))))


(define (step turtle command)
  (match command
         [#\F (handleF turtle)]
         [#\G (handleG turtle)]
         [#\+ (handle+ turtle)]
         [#\- (handle- turtle)]))



(define (compute-path state steps)
  (let* ([expanded (expand-n state steps)]
        [commands (string->list (hash-ref expanded 'word))]
        [endState (foldr (lambda (c turtle) (step turtle c)) turtle commands)])
    (hash-ref endState 'trail)))


(define (render-path path)
  (match-let ([(list x xs ...) path])
             (block
               (send dc draw-line (first x) (second x) 
                     (first (first xs)) (second (first xs))) 
               (cond
                 [(> (length xs) 1)  (render-path xs)] 
                 [else (send target save-file "img.png" 'png)]))))

(define turtle 
  (hash 'x 0
        'y 500
        'dir 0
        'pace 15
        'backtrack '()
        'trail (list (list 0 500))))

(define main
  (let ([path (compute-path sierpinski 5)])
    (render-path path)))







