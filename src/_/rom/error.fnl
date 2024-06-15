(local ROM (require :src._.cls.ROM))
(local Error (ROM:extend))

(fn Error.keypressed [!! ! key scancode repeat] 
  (match key :space (!!)))

Error
