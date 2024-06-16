(local RST (require :src._.cls.RST))
(local Error (RST:extend))

(fn Error.load [!]
  (set !.prettymsg (Error.color-msg !.errormessage))
  (set !.prettytrace "")
  (each [v (!.errortrace:gmatch "[^\n]+")]
    (when (not (v:find "fennel.lua"))
      (set !.prettytrace (.. !.prettytrace v "\n")))))

(fn Error.color-msg [msg]
  (case (msg:match "(.*)\027%[7m(.*)\027%[0m(.*)")
    (pre selected post) 
    [ [1 1 1] pre
      [1 0.2 0.2] selected
      [1 1 1] post]
    _ msg))

(fn Error.draw [! w h]
  (let [m "Press SPACE to reload last known safe state"]
    (love.graphics.setColor 0.34 0.61 0.86)
    (love.graphics.rectangle :fill 0 0 w h)
    (love.graphics.setColor 0.9 0.9 0.9)
    (love.graphics.printf   m             
                            (math.floor (* h 0.00))
                            (math.floor (* h 0.08)) 
                            w :center)
    (love.graphics.printf   !.prettymsg 
                            (math.floor (* h 0.00))
                            (math.floor (* h 0.16)) 
                            w :center)
    (love.graphics.printf   !.prettytrace 
                            (math.floor (* h 0.08))
                            (math.floor (* h 0.32)) 
                            w :left)))

Error
