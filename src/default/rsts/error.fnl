(local RST (require :classes.RST))
(local Error (RST:extend))

(fn Error.draw [! canvas]
  (let [w (canvas:getWidth)
        h (canvas:getHeight)
        m "Press SPACE to reload the erroneous ROM"]
    (love.graphics.clear 0.34 0.61 0.86)
    (love.graphics.setColor 0.9 0.9 0.9)
    (love.graphics.printf m             (math.floor (* h 0.00))
                                        (math.floor (* h 0.08)) w :center)
    (love.graphics.printf !.prettymsg   (math.floor (* h 0.00))
                                        (math.floor (* h 0.16)) w :center)
    (love.graphics.printf !.prettytrace (math.floor (* h 0.08))
                                        (math.floor (* h 0.32)) w :left)))

Error
