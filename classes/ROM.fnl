(local Object (require :lib.classic))
(local ROM (Object:extend))

(fn load [!])
(set ROM.load nil)

(fn update [!! ! dt])
(set ROM.update nil)

;; TODO add all love events to main/console + here w/ [!! ! ...]

ROM
