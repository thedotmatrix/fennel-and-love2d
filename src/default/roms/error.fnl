(local ROM (require :classes.ROM))
(local Error (ROM:extend))
                          
(fn color-msg [msg]
  (case (msg:match "(.*)\027%[7m(.*)\027%[0m(.*)")
    (pre selected post) 
    [ [1 1 1] pre
      [1 0.2 0.2] selected
      [1 1 1] post]
    _ msg))

(fn Error.load [!]
  (set !.prettymsg (color-msg !.errormessage))
  (set !.prettytrace "")
  (each [v (!.errortrace:gmatch "[^\n]+")]
    (when (not (v:find "fennel.lua"))
      (set !.prettytrace (.. !.prettytrace v "\n")))))

(fn Error.keypressed [!! ! key scancode repeat] 
  (match key :space (!!)))

Error
