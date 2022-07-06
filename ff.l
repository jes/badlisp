((lambda (ff lst) (ff lst))
    (quote (lambda (val)
        (cond ((atom val) val)
              ((quote t) (ff (car val)))
        )
    ))

    (quote ((a) b c))
)

