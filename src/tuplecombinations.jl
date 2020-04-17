combination(x) = combination_(x...)
combination_(x) = x
combination_(x,y) = (x,y,(x,y))
combination_(x,y...) = (x,combination(y)...,map(z->(x,z...),combination(y))...)


combination((1))
combination((2,3))
combination((2,3,4))
combination((1,2,3,4))
