{:draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (love.graphics.print "Hello World"))
 :update (fn update [dt set-mode])
 :keypressed (fn keypressed [key set-mode])}
