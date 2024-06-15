(local ROM (require :src._.cls.ROM))
(local Empty (ROM:extend))

(fn Empty.update [!! ! dt] (when (not !.loaded) (do
  (set !.b 42)
  (set !.next :empty2)
  (set !.loaded true))))

Empty
