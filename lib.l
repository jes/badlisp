(def length (lambda lst
    (if lst (+ 1 (length (cdr lst))) 0)))

(def max2 (lambda (a b)
    (if (> a b) a b)))

(def max (lambda lst
    (if lst
        (if (> (length lst) 1) (max2 (car lst) (max (cdr lst)))
                               (car lst))
        0)))
