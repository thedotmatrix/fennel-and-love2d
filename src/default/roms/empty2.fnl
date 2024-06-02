(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.a nil)
  (set !.b 69))

(fn Empty.keypressed [!! ! key scancode repeat?] 
  (match key
    :space (if  (> (love.math.random -1 1) 0) 
                (!! :main)
                (error "here"))))

Empty
