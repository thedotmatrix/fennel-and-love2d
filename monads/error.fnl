(local state {:msg "" :traceback "" :old-mode :intro})
(local explanation "Press escape to quit.
Press space to return to the previous mode after reloading in the repl.")

(fn draw []
  (love.graphics.clear 0.34 0.61 0.86)
  (love.graphics.setColor 0.9 0.9 0.9)
  (love.graphics.print explanation 15 10)
  (love.graphics.print state.msg 10 60)
  (love.graphics.print state.traceback 15 125))

(fn keypressed [key set-mode]
  (match key
    :escape (love.event.quit)
    :space (set-mode state.old-mode)))

(fn color-msg [msg]
  (case (msg:match "(.*)\027%[7m(.*)\027%[0m(.*)") ;; ansi -> love codes
    (pre selected post) 
    [ [1 1 1] pre
      [1 0.2 0.2] selected
      [1 1 1] post]
    _ msg))

(fn activate [old-mode msg traceback]
  (love.graphics.setNewFont 16) ; use a monospace font here if you have one
  (print msg)
  (print traceback)
  (set state.old-mode old-mode)
  (set state.msg (color-msg msg))
  (set state.traceback traceback))

{: draw : keypressed : activate}
