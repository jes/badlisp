(def length (lambda lsta
    (if lsta (+ 1 (length (cdr lsta))) 0)))

(def max-helper (lambda (a b)
    (if (> a b) a b)))

(def max (lambda lst
    (if lst
        (if (> (length lst) 1) (max-helper (car lst) (max (cdr lst)))
                               (car lst))
        0)))

(def sqr (lambda x (* x x)))

(def sqrt-helper (lambda (x c)
    (if (>= (sqr c) x) c (sqrt-helper x (+ 1 c)))))

(def sqrt (lambda x
    (sqrt-helper x 0)
))

(def fact (lambda x
    (if (> x 1) (* x (fact (- x 1))) 1)
))

(def pe-1-helper (lambda x
    (if (> x 0)
          (if (or (= (modulo x 3) 0) (= (modulo x 5) 0)) (list x (pe-1-helper (- x 1))) (pe-1-helper (- x 1)))
          ())
))

(def project-euler-1 (lambda ()
    (+ (pe-1-helper 1000))
))
