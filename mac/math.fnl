(fn flip [value]      `(do (set ,value (not ,value)) ,value))

(fn coin [a b]        `(if (> (love.math.random -1 1) 0) ,a ,b))

(fn incf [value ?by]  `(set ,value (+ ,value (or ,?by 1))))

(fn decf [value ?by]  `(set ,value (- ,value (or ,?by 1))))

(fn lerp [a b alpha]  `(+ (* ,b ,alpha) (* ,a (- 1.0 ,alpha))))

(fn clamp [val ?low ?hi]
  `(let [lower# (or ,?low (* -1 math.huge))
         upper# (or ,?hi math.huge)
         old# ,val]
  (set ,val (math.min (math.max ,val lower#) upper#))
  (~= old# ,val)))

(fn arctan [x1 y1 x2 y2]
  `(- (math.atan2 (- ,x1 ,x2) (- ,y2 ,y1)) (/ math.pi 2)))

(fn digital [angle] 
  `(% (* (math.floor (/  (+ ,angle (/ math.pi 8)) 
                                (/ math.pi 4))) 
                      (/ math.pi 4))
      (* 2 math.pi)))

(fn with [t keys ?body]
  `(let [,keys ,t]
     (if ,?body
         ,?body
         ,keys)))

{: flip : coin : incf : decf : lerp : clamp : arctan : digital : with}
