(local ROM (require :src._.cls.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.a 42)
  (set !.next :empty))

(fn Empty.keypressed [!! ! key scancode repeat?]
  (match key :space (!! !.next)))

(fn Empty.mousemoved [!! ! x y ...]
  (set !.mx x)
  (set !.my y))

Empty
