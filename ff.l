((lambda (ff lst) (ff lst))
    (lambda (val)
        (cond ((atom val) val)
              (t (ff (car val)))
        )
    )

    (quote ((a) b c))))
)

