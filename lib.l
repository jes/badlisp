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
          (if (or (= (modulo x 3) 0) (= (modulo x 5) 0)) (cons x (pe-1-helper (- x 1))) (pe-1-helper (- x 1)))
          ())
))

(def lst-add (lambda (lst)
    (if lst
        (+ (car lst) (lst-add (cdr lst)))
        0
    )
))

(def project-euler-1 (lambda ()
    (lst-add (pe-1-helper 999))
))

(def fib-upto-helper (lambda (max n1 n2)
    (if (<= (+ n1 n2) max)
        (cons (+ n1 n2) (fib-upto-helper max n2 (+ n1 n2)))
        ()
    )
))

(def fib-upto (lambda (x)
    (cons 1 (fib-upto-helper x 0 1))
))

(def even? (lambda (x)
    (if (= (modulo x 2) 0) #t #f)
))

(def filter (lambda (f lst)
    (if lst
        (if (f (car lst))
            (cons (car lst) (filter f (cdr lst)))
            (filter f (cdr lst))
        )
        ()
    )
))

(def even-terms (lambda (lst)
    (filter even? lst)
))

(def project-euler-2 (lambda ()
    (lst-add (even-terms (fib-upto 4000000)))
))

(def factors-helper (lambda (x n)
    (if (< (sqr n) x)
        (if (= (modulo x n) 0)
            (cons n (cons (/ x n) (factors-helper x (+ n 1))))
            (factors-helper x (+ n 1))
        )
        (if (= (sqr n) x)
            (cons n (factors-helper x (+ n 1)))
            ()
        )
    )
))

(def prime? (lambda (x)
    (= (length (factors x)) 0)
))

(def factors (lambda (x)
    (factors-helper x 2)
))

(def prime-factors (lambda (x)
    (filter prime? (factors x))
))

(def project-euler-3 (lambda ()
    (max (prime-factors 600851475143))
))
