(fn incf [value ?by]
  `(set ,value (+ ,value (or ,?by 1))))

(fn decf [value ?by]
  `(set ,value (- ,value (or ,?by 1))))

(fn clamp [val ?low ?hi]
  `(let [lower# (or ,?low (* -1 math.huge))
         upper# (or ,?hi math.huge)
         old# ,val]
  (set ,val (math.min (math.max ,val lower#) upper#))
  (~= old# ,val)))

(fn arctan [x1 y1 x2 y2]
  `(- (math.atan2 (- ,x1 ,x2) (- ,y2 ,y1)) (/ math.pi 2)))

(fn with [t keys ?body]
  `(let [,keys ,t]
     (if ,?body
         ,?body
         ,keys)))

{: incf : decf : clamp : arctan : with}
