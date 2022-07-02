(def length (lambda lst
    (if lst (+ 1 (length (cdr lst))) 0)))
