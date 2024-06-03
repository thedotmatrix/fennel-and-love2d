(fn flip [value]  `(do (set ,value (not ,value)) ,value))

(fn coin [a b]    `(if (> (love.math.random -1 1) 0) ,a ,b))

{: flip : coin}
