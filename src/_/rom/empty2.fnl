(local ROM (require :src._.cls.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (print "tryload")
  (set !.a nil)
  (set !.b 69)
  (set !.next :main)
  (when (> (love.math.random -1 1) 0) 
        (error "random failure"))
  (print "success"))

Empty