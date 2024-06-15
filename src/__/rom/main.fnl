(local ROM (require :src._.cls.ROM))
(local Empty (ROM:extend))

(fn Empty.update [!! ! dt] (when (not !.loaded) (do
  (set !.a 42)
  (set !.next :empty)
  (set !.loaded true))))

(fn Empty.keypressed [!! ! key scancode repeat?]
  (match key :space (do (set !.loaded false) (!! !.next))))

(fn Empty.mousemoved [!! ! x y ...]
  (set !.mx x)
  (set !.my y))

Empty
