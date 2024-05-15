(fn draw [w h] (fn []
  (love.graphics.clear 0.22 0.22 0.22 1)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.printf "sheepolution how to love" 0 (/ h 2) w :center)))

(fn update [dt])

(fn keypressed [key])

{: draw : update : keypressed}
