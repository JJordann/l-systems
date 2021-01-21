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

; turtle: (x y dir)
(define turtle (list (/ h 2) (/ w 2) 0))

(define (drawOnce turtle c dist)
  (match c
         [#\F 
          (let ([mx (+ (first turtle) (* dist (cos (third turtle))))]
                [my (+ (second turtle) (* dist (sin (third turtle))))])
            (block 
              (send dc draw-line (first turtle) (second turtle) mx my)
              (list mx my (third turtle))))]
         [#\G 
          (let ([mx (+ (first turtle) (* dist (cos (third turtle))))]
                [my (+ (second turtle) (* dist (sin (third turtle))))])
            (block 
              (send dc draw-line (first turtle) (second turtle) mx my)
              (list mx my (third turtle))))]
         [#\+ 
          (list 
            (first turtle) 
            (second turtle)
            (+ (third turtle) (* pi 2/3)))]
         [#\-
          (list
            (first turtle)
            (second turtle)
            (- (third turtle) (* pi 2/3)))]))


(define (render state scale)
  (let ([turtle (list 0 700 0)]
        [cmds (string->list (hash-ref state 'word))])
    (foldr (lambda (c turtle) (drawOnce turtle c scale)) turtle cmds)))


(define main
  (let ([state (expand-n sierpinski 7)])
      (block (render state 6)
             (send target save-file "img.png" 'png))))







