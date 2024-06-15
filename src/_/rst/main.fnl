(local RST (require :src._.cls.RST))
(local Empty (RST:extend))

(fn Empty.load [!] )

(fn Empty.draw [! canvas]
  (love.graphics.clear 0.1 0.1 0.1 1)
  (love.graphics.print (..  "a is " (tostring (?. ! :a)) "\n"
                            "b is " (tostring (?. ! :b))))
  (when (and !.mx !.my)
    (love.graphics.circle "fill" !.mx !.my 2)))

Empty
