((lambda (pairlis) (pairlis (quote (1 2 3)) (quote (a b c))))

    (lambda (x y)
          (cond ((eq x ()) ())
                ((quote t) (cons (cons (car x) (cons (car y) ()))
                                 (pairlis (cdr x) (cdr y))))))
)
