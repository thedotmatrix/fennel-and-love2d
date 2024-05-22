(fn draw [_ _] (fn []
  (local w 400) ;; FIXME passing in [w h] breaks web
  (local h 300)
  (love.graphics.clear 0.8 0.8 0.8 1)
  (love.graphics.setColor 0 0 0 1)))

(fn update [dt])

(fn keypressed [key])

{: draw : update : keypressed}
