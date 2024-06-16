(local RST (require :src._.cls.RST))
(local Empty (RST:extend))

(fn Empty.draw [! w h]
  (love.graphics.setColor 0.1 0.1 0.1 1)
  (love.graphics.rectangle :fill 0 0 w h)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.print (..  "a is " (tostring (?. ! :a)) "\n"
                            "b is " (tostring (?. ! :b))))
  (when (and !.mx !.my)
    (love.graphics.circle "fill" !.mx !.my 2)))

Empty
