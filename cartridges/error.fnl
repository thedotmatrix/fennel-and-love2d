(local Cartridge (require :classes.cartridge))
(local Error (Cartridge:extend))
(local state {:msg "" :traceback "" :oldname nil})
(local explanation "Press escape to quit.
Press space to return to the previous mode after reloading in the repl.")

(fn draw [self w h]
  (love.graphics.clear 0.34 0.61 0.86)
  (love.graphics.setColor 0.9 0.9 0.9)
  (love.graphics.printf explanation     0 
                                        (math.floor (* h 0.08)) w :center)
  (love.graphics.printf state.msg       0
                                        (math.floor (* h 0.16)) w :center)
  (love.graphics.printf state.traceback (math.floor (* h 0.08)) 
                                        (math.floor (* h 0.32)) w :left))

(fn keypressed [self key scancode repeat] (match key
  :space (Error.super.load self state.oldname)))
                          
(fn color-msg [msg]
  (case (msg:match "(.*)\027%[7m(.*)\027%[0m(.*)") ;; ansi -> love codes
    (pre selected post) 
    [ [1 1 1] pre
      [1 0.2 0.2] selected
      [1 1 1] post]
    _ msg))

(fn stacktrace [oldname msg traceback]
  (set state.oldname oldname)
  (set state.msg (color-msg msg))
  (set state.traceback "")
  (each [v (traceback:gmatch "[^\n]+")]
    (when (not (v:find "fennel.lua"))
      (set state.traceback (.. state.traceback v "\n")))))

(tset Error :new (fn [self w h old]
  (Error.super.new self) ;; discard old state
  (tset self :draw draw)
  (tset self :keypressed keypressed)
  (tset self :stacktrace stacktrace)
  self))
Error
