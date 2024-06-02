(local RST (require :classes.RST))
(local Empty (RST:extend))

(fn Empty.draw [! canvas]
  (love.graphics.clear)
  (love.graphics.print (..  "a is " (tostring (?. ! :a)) "\n"
                            "b is " (tostring (?. ! :b)))))

Empty
