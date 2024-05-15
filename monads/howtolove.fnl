(import-macros {: incf : decf : clamp} :macros.math)
(local title "sheepolution how to love")
(local navi "<-- \t \t chapter %d \t \t -->")
(var chapter 1)

(fn init1 [] (print 123))
(fn draw1 [w h] (love.graphics.printf "Hello World!" 0 (/ h 2) w :center))

(fn init2 [] )
(fn draw2 [w h] )

(fn init [] 
  (case chapter
      1 (init1)
      2 (init2)))

(fn draw [w h] (fn []
  (let [fh (: (love.graphics.getFont) :getHeight)]
    (love.graphics.clear 0.22 0.22 0.22 1)
    (love.graphics.setColor 1 1 1 1)
    (case chapter
      1 (draw1 w h)
      2 (draw2 w h))
    (love.graphics.printf title 0 0 w :center)
    (love.graphics.printf (: navi :format chapter) 0 (- h fh) w :center))))

(fn update [dt])

(fn keypressed [key]
  (match key
    :left (do (decf chapter 1) (clamp chapter 1 24))
    :right (do (incf chapter 1) (clamp chapter 2 24)))
  (init))

{: init : draw : update : keypressed}
